import Foundation
import CFNetwork
import Darwin

struct WorkbenchError: LocalizedError {
    let message: LocalizedMessage

    init(_ key: String, _ arguments: String...) {
        message = LocalizedMessage(key, arguments: arguments)
    }

    init(message: LocalizedMessage) {
        self.message = message
    }

    var errorDescription: String? { WebbieStrings(.simplifiedChinese)(message) }
}

enum OutputKind: String, CaseIterable, Codable {
    case mp4, mp3, m4a
    var title: String { rawValue.uppercased() }
    var isVideo: Bool { self == .mp4 }
}

struct Clip: Codable, Equatable {
    let start: Double
    let end: Double
    var duration: Double { end - start }
    var label: String { "\(Self.display(start))–\(Self.display(end))" }
    var fileLabel: String { label.replacingOccurrences(of: ":", with: "-") }
    var section: String { "*\(Self.decimal(start))-\(Self.decimal(end))" }

    init(start: String, end: String, duration: Double?) throws {
        guard let lower = Self.parse(start), let upper = Self.parse(end) else {
            throw WorkbenchError("请输入有效的时间，例如 00:03:00 或 180。")
        }
        guard upper > lower else { throw WorkbenchError("结束时间需要晚于开始时间。") }
        if let duration, upper > duration + 0.001 {
            throw WorkbenchError("结束时间超出素材时长（%@）。", Self.display(duration))
        }
        self.start = lower
        self.end = min(upper, duration ?? upper)
        guard self.end > self.start else { throw WorkbenchError("所选片段超出素材时长。") }
    }

    static func parse(_ input: String) -> Double? {
        let parts = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":", omittingEmptySubsequences: false)
        guard (1...3).contains(parts.count),
              let last = parts.last, last.range(of: #"^[0-9]+(\.[0-9]{1,3})?$"#, options: .regularExpression) != nil,
              let seconds = Double(last), seconds.isFinite, seconds < 360_000 else { return nil }
        guard parts.count > 1 else { return seconds }
        guard seconds < 60, let minutes = Int(parts[parts.count - 2]), minutes >= 0, minutes < 6000,
              parts[parts.count - 2].allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        if parts.count == 2 { return Double(minutes * 60) + seconds }
        guard minutes < 60, let hours = Int(parts[0]), (0..<100).contains(hours),
              parts[0].allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return Double(hours * 3600 + minutes * 60) + seconds
    }

    static func display(_ seconds: Double) -> String {
        let ms = Int((max(0, seconds) * 1000).rounded())
        let whole = ms / 1000
        let suffix = ms % 1000 == 0 ? "" : String(format: ".%03d", ms % 1000)
        return String(format: "%02d:%02d:%02d", whole / 3600, (whole / 60) % 60, whole % 60) + suffix
    }

    static func decimal(_ seconds: Double) -> String {
        String(format: "%.3f", locale: Locale(identifier: "en_US_POSIX"), seconds)
    }
}

struct YouTubeLink: Equatable {
    let id: String
    var canonical: String { "https://www.youtube.com/watch?v=\(id)" }

    init(_ input: String) throws {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URLComponents(string: address), let host = url.host?.lowercased(),
              ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
              url.user == nil, url.password == nil, url.port == nil else {
            throw WorkbenchError("请粘贴有效的 YouTube 视频链接。")
        }
        let path = url.path.split(separator: "/")
        var candidate: String?
        if ["youtu.be", "www.youtu.be"].contains(host), path.count == 1 {
            candidate = String(path[0])
        } else if ["youtube.com", "www.youtube.com", "m.youtube.com", "music.youtube.com", "www.youtube-nocookie.com", "youtube-nocookie.com"].contains(host) {
            if url.path == "/watch" {
                candidate = url.queryItems?.first(where: { $0.name == "v" })?.value
            } else if path.count == 2, ["shorts", "live", "embed", "v"].contains(String(path[0])) {
                candidate = String(path[1])
            }
        }
        guard let candidate, candidate.range(of: #"^[A-Za-z0-9_-]{11}$"#, options: .regularExpression) != nil else {
            throw WorkbenchError("请粘贴单个 YouTube 视频链接，支持普通视频、短链接和 Shorts。")
        }
        id = candidate
    }
}

struct MediaLink: Equatable {
    let url: URL
    var canonical: String { url.absoluteString }
    var canRetryDirect: Bool {
        isOn("bilibili.com") || isOn("douyin.com") || isOn("xiaohongshu.com")
    }

    func isOn(_ domain: String) -> Bool {
        let host = url.host?.lowercased() ?? ""
        return host == domain || host.hasSuffix(".\(domain)")
    }

    init(_ text: String) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sharedURL = trimmed.range(of: #"(?i)https?://[^\s<>"“”‘’，。！？、；：…]+"#, options: .regularExpression)
            .map { String(trimmed[$0]).trimmingCharacters(in: CharacterSet(charactersIn: ".,;!)]}")) }
        let candidate = sharedURL ?? trimmed
        let address = candidate.contains("://") ? candidate : "https://\(candidate)"
        guard !candidate.contains(where: \.isWhitespace),
              var components = URLComponents(string: address),
              let scheme = components.scheme?.lowercased(), ["http", "https"].contains(scheme),
              let host = components.host?.lowercased(), host.contains("."),
              components.user == nil, components.password == nil else {
            throw WorkbenchError("请粘贴视频网页的链接，或复制平台提供的分享文案。")
        }
        if let youtube = try? YouTubeLink(address), let normalized = URL(string: youtube.canonical) {
            url = normalized
            return
        }
        if ["m.bilibili.com", "bilibili.com"].contains(host), components.path.hasPrefix("/video/") {
            components.host = "www.bilibili.com"
        } else if host == "xiaohongshu.com" {
            components.host = "www.xiaohongshu.com"
        } else if host == "tiktok.com", components.path.hasPrefix("/@") {
            components.host = "www.tiktok.com"
        } else if ["www.iesdouyin.com", "iesdouyin.com", "www.douyin.com", "douyin.com"].contains(host) {
            let parts = components.path.split(separator: "/")
            if parts.count == 3, parts[0] == "share", parts[1] == "video",
               parts[2].allSatisfy({ $0.isASCII && $0.isNumber }) {
                components.host = "www.douyin.com"
                components.path = "/video/\(parts[2])"
            }
        }
        guard let normalized = components.url else {
            throw WorkbenchError("这个视频链接的格式不正确。")
        }
        url = normalized
    }

    func expanded() async -> Self {
        guard let host = url.host?.lowercased(),
              ["b23.tv", "v.douyin.com", "xhslink.com", "www.xhslink.com",
               "xhslink.cn", "www.xhslink.cn"].contains(host) else { return self }
        var request = URLRequest(url: url, timeoutInterval: 8)
        request.httpMethod = "HEAD"
        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let destination = response.url, destination.host != url.host,
              let link = try? Self(destination.absoluteString) else { return self }
        return link
    }
}

struct StreamFormat: Decodable {
    let format_id: String
    let width: Int?
    let height: Int?
    let fps: Double?
    let vcodec: String?
    let acodec: String?
    let vbr: Double?
    let tbr: Double?
    let abr: Double?
    let audio_channels: Int?
    let ext: String?
    let has_drm: Bool?
    let protocolName: String?

    enum CodingKeys: String, CodingKey {
        case format_id, width, height, fps, vcodec, acodec, vbr, tbr, abr, audio_channels, ext, has_drm
        case protocolName = "protocol"
    }

    var hasVideo: Bool {
        if let vcodec { return vcodec != "none" }
        return width != nil || height != nil ||
            ["mp4", "webm", "mov", "mkv", "flv", "m4v", "avi", "ts"].contains(ext?.lowercased() ?? "")
    }
    var hasAudio: Bool {
        if let acodec { return acodec != "none" }
        return hasVideo || ["m4a", "aac", "mp3", "opus", "ogg", "flac", "wav", "weba"].contains(ext?.lowercased() ?? "")
    }
    var shortEdge: Int? {
        guard let height, height > 0 else { return nil }
        guard let width, width > 0 else { return height }
        return min(width, height)
    }
    var h264: Bool { vcodec?.hasPrefix("avc") == true || vcodec?.hasPrefix("h264") == true }
    var usable: Bool {
        has_drm != true && format_id.range(of: #"^[A-Za-z0-9_][A-Za-z0-9._-]*$"#, options: .regularExpression) != nil
    }
    var supportsClip: Bool {
        ["http", "https", "m3u8", "m3u8_native", "http_dash_segments"].contains(protocolName ?? "")
    }
    var stereoAAC: Bool { acodec?.hasPrefix("mp4a") == true && (audio_channels ?? 9) <= 2 }

    static func better(_ lhs: Self, _ rhs: Self) -> Bool {
        if (lhs.fps ?? 0) != (rhs.fps ?? 0) { return (lhs.fps ?? 0) > (rhs.fps ?? 0) }
        if lhs.h264 != rhs.h264 { return lhs.h264 }
        let lhsDirect = lhs.protocolName == "https" || lhs.protocolName == "http"
        let rhsDirect = rhs.protocolName == "https" || rhs.protocolName == "http"
        if lhsDirect != rhsDirect { return lhsDirect }
        return (lhs.vbr ?? lhs.tbr ?? 0) > (rhs.vbr ?? rhs.tbr ?? 0)
    }
}

struct MediaInfo: Decodable {
    let title: String
    let duration: Double?
    let thumbnail: URL?
    let uploader: String?
    let channel: String?
    let live_status: String?
    private let tracks: [StreamFormat]?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case title, duration, thumbnail, uploader, channel, live_status
        case tracks = "formats"
        case type = "_type"
    }

    var formats: [StreamFormat] { (tracks ?? []).filter(\.usable) }
    var channelsLabel: String? { channel ?? uploader }
    var hasVideo: Bool { formats.contains(where: \.hasVideo) }
    var hasUnknownResolution: Bool { formats.contains { $0.hasVideo && $0.shortEdge == nil } }
    var canExtractAudio: Bool { formats.contains(where: \.hasAudio) }
    var resolutions: [Int] {
        Array(Set(formats.filter(\.hasVideo).compactMap(\.shortEdge))).sorted(by: >)
    }

    func selector(kind: OutputKind, resolution: Int, clip: Bool = false) throws -> String {
        let usable = clip ? formats.filter(\.supportsClip) : formats
        let audio = usable.filter { $0.hasAudio && !$0.hasVideo }.sorted {
            if $0.stereoAAC != $1.stereoAAC { return $0.stereoAAC }
            return ($0.abr ?? $0.tbr ?? 0) > ($1.abr ?? $1.tbr ?? 0)
        }
        let cannotClip = WorkbenchError("当前链接的所选格式无法直接下载片段，可以切换格式或选择「完整素材」。")
        if !kind.isVideo {
            guard canExtractAudio else { throw WorkbenchError("这个视频没有可用的音轨。") }
            let combined = usable.filter { $0.hasAudio && $0.hasVideo }.sorted(by: StreamFormat.better)
            let ids = (audio + combined).map(\.format_id)
            guard !ids.isEmpty else { throw cannotClip }
            return ids.joined(separator: "/")
        }
        let matches = usable.filter { $0.hasVideo && ($0.shortEdge ?? 0) == resolution }
        guard let video = matches.sorted(by: StreamFormat.better).first else {
            if clip { throw cannotClip }
            throw WorkbenchError("所选分辨率当前不可用，请重新解析链接。")
        }
        let id = video.format_id
        if video.hasAudio { return id }
        var candidates = audio.map { "\(id)+\($0.format_id)" }
        if let combined = matches.filter(\.hasAudio).sorted(by: StreamFormat.better).first {
            candidates.append(combined.format_id)
        }
        if candidates.isEmpty {
            if clip && canExtractAudio { throw cannotClip }
            candidates.append(id)
        }
        return candidates.joined(separator: "/")
    }
}

struct DownloadSpec: Codable {
    let source: String
    let title: String
    let thumbnail: URL?
    let kind: OutputKind
    let resolution: Int
    let videoBitrate: Int
    let audioBitrate: Int
    let selector: String
    let clip: Clip?
    let duration: Double?
    let folder: URL
    var directConnection: Bool?

    func detail(in strings: WebbieStrings) -> String {
        var pieces = [kind.title]
        if kind.isVideo {
            pieces.append(resolution > 0 ? "\(resolution)p" : strings("源分辨率"))
            if videoBitrate > 0 { pieces.append("\(videoBitrate) kbps") }
        } else {
            pieces.append("\(audioBitrate) kbps")
        }
        pieces.append(clip?.label ?? strings("完整素材"))
        return pieces.joined(separator: "  ·  ")
    }
}

struct RuntimeTools {
    let directory: URL
    private static let names = ["yt-dlp", "ffmpeg", "ffprobe", "deno"]
    var downloader: URL { directory.appendingPathComponent("yt-dlp") }
    var ffmpeg: URL { directory.appendingPathComponent("ffmpeg") }
    var ffprobe: URL { directory.appendingPathComponent("ffprobe") }
    var deno: URL { directory.appendingPathComponent("deno") }

    init(directory: URL) {
        let homebrew = URL(fileURLWithPath: "/opt/homebrew/bin", isDirectory: true)
        self.directory = Self.missing(in: directory).isEmpty ? directory : homebrew
    }

    private static func missing(in directory: URL) -> [String] {
        names.filter {
            !FileManager.default.isExecutableFile(atPath: directory.appendingPathComponent($0).path)
        }
    }

    func validate() throws {
        let missing = Self.missing(in: directory)
        if !missing.isEmpty {
            throw WorkbenchError("缺少下载组件（%@）。请在终端运行 brew install yt-dlp ffmpeg deno。", missing.joined(separator: ", "))
        }
    }

    func baseArguments(for source: String, directConnection: Bool = false) -> [String] {
        var args = ["--ignore-config", "--no-plugin-dirs", "--no-playlist", "--playlist-items", "1", "--no-cache-dir",
         "--no-colors", "--no-update", "--socket-timeout", "20", "--extractor-retries", "2",
         "--ffmpeg-location", directory.path, "--no-js-runtimes", "--js-runtimes", "deno:\(deno.path)"]
        if directConnection {
            args += ["--proxy", ""]
        } else if let url = URL(string: source), let proxy = Self.systemWebProxy(for: url) {
            args += ["--proxy", proxy]
        }
        return args
    }

    private static func systemWebProxy(for url: URL) -> String? {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue(),
              let proxies = CFNetworkCopyProxiesForURL(url as CFURL, settings).takeRetainedValue() as? [[String: Any]],
              let proxy = proxies.first,
              let type = proxy[kCFProxyTypeKey as String] as? String,
              type == kCFProxyTypeHTTP as String || type == kCFProxyTypeHTTPS as String,
              let host = proxy[kCFProxyHostNameKey as String] as? String,
              let port = proxy[kCFProxyPortNumberKey as String] as? Int else { return nil }
        var address = URLComponents()
        address.scheme = "http"
        address.host = host
        address.port = port
        return address.string
    }
}

struct CommandResult {
    let output: Data
    let diagnostics: Data
    let status: Int32

    private var errorLog: String { String(decoding: diagnostics, as: UTF8.self).lowercased() }

    var proxyConnectionFailed: Bool {
        guard status != 0 else { return false }
        let log = errorLog
        return ["unexpected_eof_while_reading", "proxy error", "proxyerror", "proxy connect",
                "connection refused", "timed out"].contains { log.contains($0) }
    }

    var retryableNetworkFailure: Bool {
        guard status != 0 else { return false }
        let log = errorLog
        return ["403 forbidden", "http error 403", "http error 429", "http error 502", "http error 503",
                "http error 504", "timed out", "connection reset", "temporary failure"]
            .contains { log.contains($0) }
    }

    func detectionMessage(for source: MediaLink) -> String {
        let log = errorLog
        if source.isOn("douyin.com") && log.contains("fresh cookies") {
            return "抖音要求额外的网页验证，当前下载组件未能读取这条视频。"
        }
        if source.isOn("xiaohongshu.com") && log.contains("no video formats") {
            return "小红书未返回可用的视频流。可以在视频笔记里重新复制完整分享链接。"
        }
        return "无法解析这个视频链接。"
    }

    func requireSuccess(_ context: String, _ arguments: String...) throws {
        guard status != 0 else { return }
        let lines = String(decoding: diagnostics.suffix(12000), as: UTF8.self)
            .split(whereSeparator: \.isNewline).map(String.init)
        let useful = lines.last(where: { $0.contains("ERROR:") }) ?? lines.last
        let transport = lines.last {
            let line = $0.lowercased()
            return line.contains("operation timed out") || line.contains("connection refused") || line.contains("server returned")
        }
        let details = [transport == useful ? nil : transport, useful].compactMap { $0 }
        let detail = details.isEmpty ? nil : details.joined(separator: "\n")
            .replacingOccurrences(of: #"\b[a-zA-Z][a-zA-Z0-9+.-]*://[^\s]+"#, with: "[URL]", options: .regularExpression)
        throw WorkbenchError(message: LocalizedMessage(context, arguments: arguments,
            detail: detail.map { String($0.prefix(700)) }, exitCode: status))
    }
}

final class CommandCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var process: Process?
    private var cancelled = false

    func launch(_ process: Process) throws {
        lock.lock()
        defer { lock.unlock() }
        if cancelled { throw CancellationError() }
        try process.run()
        self.process = process
    }

    func finish(_ process: Process) throws {
        lock.lock()
        defer { lock.unlock() }
        if self.process === process { self.process = nil }
        if cancelled { throw CancellationError() }
    }

    func check() throws {
        lock.lock()
        defer { lock.unlock() }
        if cancelled { throw CancellationError() }
    }

    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        cancelled = true
        guard let process, process.isRunning else { return }
        let pid = process.processIdentifier
        let target = getpgid(pid) == pid ? -pid : pid
        kill(target, SIGTERM)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self, weak process] in
            guard let self, let process else { return }
            self.lock.lock()
            defer { self.lock.unlock() }
            if self.process === process, process.isRunning { kill(target, SIGKILL) }
        }
    }
}

private final class PipeRead: @unchecked Sendable {
    private(set) var data = Data()

    func drain(_ pipe: Pipe, limit: Int?, onLine: ((String) -> Void)?) {
        let handle = pipe.fileHandleForReading
        defer { try? handle.close() }
        var buffer = Data()
        while let chunk = try? handle.read(upToCount: 32_768), !chunk.isEmpty {
            data.append(chunk)
            if let limit, data.count > limit { data = Data(data.suffix(limit)) }
            guard let onLine else { continue }
            buffer.append(chunk)
            var start = buffer.startIndex
            for i in buffer.indices where buffer[i] == 10 || buffer[i] == 13 {
                if i > start { onLine(String(decoding: buffer[start..<i], as: UTF8.self)) }
                start = i + 1
            }
            buffer = Data(buffer[start...].suffix(16_384))
        }
        if !buffer.isEmpty { onLine?(String(decoding: buffer, as: UTF8.self)) }
    }
}

enum Command {
    static func run(_ tool: URL, _ args: [String], cancellation: CommandCancellation,
                    captureOutput: Bool = false, onLine: (@Sendable (String) -> Void)? = nil) async throws -> CommandResult {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let process = Process()
                    let stdout = Pipe()
                    let stderr = Pipe()
                    process.executableURL = tool
                    process.arguments = args
                    process.standardInput = FileHandle.nullDevice
                    process.standardOutput = stdout
                    process.standardError = stderr
                    try cancellation.launch(process)
                    let output = PipeRead(), diagnostics = PipeRead()
                    let drains = DispatchGroup()
                    let queue = DispatchQueue.global(qos: .utility)
                    queue.async(group: drains) { output.drain(stdout, limit: captureOutput ? nil : 96_000, onLine: onLine) }
                    queue.async(group: drains) { diagnostics.drain(stderr, limit: 96_000, onLine: nil) }
                    process.waitUntilExit()
                    drains.wait()
                    try cancellation.finish(process)
                    continuation.resume(returning: CommandResult(output: output.data, diagnostics: diagnostics.data, status: process.terminationStatus))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct MediaEngine {
    let tools: RuntimeTools

    func inspect(_ link: MediaLink, cancellation: CommandCancellation) async throws
        -> (info: MediaInfo, source: MediaLink, directConnection: Bool) {
        try tools.validate()
        let source = await link.expanded()
        if (source.isOn("xiaohongshu.com") || source.isOn("rednote.com")), source.url.path == "/login" {
            throw WorkbenchError("这个小红书分享链接打开后进入了登录页。请从视频笔记重新复制完整分享链接。")
        }
        let suffix = ["--skip-download", "--dump-single-json", "--", source.canonical]
        let route = tools.baseArguments(for: source.canonical)
        var result = try await Command.run(tools.downloader, route + suffix, cancellation: cancellation, captureOutput: true)
        var directConnection = false
        if source.canRetryDirect && route.contains("--proxy") && result.proxyConnectionFailed {
            let alternative = tools.baseArguments(for: source.canonical, directConnection: true)
            let direct = try await Command.run(tools.downloader, alternative + suffix, cancellation: cancellation, captureOutput: true)
            if direct.status == 0 || !direct.proxyConnectionFailed {
                result = direct
                directConnection = true
            }
        }
        try result.requireSuccess(result.detectionMessage(for: source))
        let info: MediaInfo
        do { info = try JSONDecoder().decode(MediaInfo.self, from: result.output) }
        catch { throw WorkbenchError("无法读取这个视频的清晰度和音轨信息。") }
        if info.type == "playlist" || info.type == "multi_video" {
            throw WorkbenchError("请粘贴单个视频链接。若是分集视频，请先打开要下载的一集。")
        }
        if ["is_live", "is_upcoming", "post_live"].contains(info.live_status ?? "") {
            throw WorkbenchError("请等直播结束且回放处理完成后再下载。")
        }
        guard info.hasVideo || info.canExtractAudio else {
            throw WorkbenchError("这个链接没有可用的视频或音频格式。")
        }
        return (info, source, directConnection)
    }

    func sourceArguments(_ spec: DownloadSpec, stagedAt working: URL) -> [String] {
        let output = working.path.replacingOccurrences(of: "%", with: "%%") + "/source.%(ext)s"
        var args = tools.baseArguments(for: spec.source, directConnection: spec.directConnection == true) + [
            "--format", spec.selector, "--merge-output-format", "mkv", "--fixup", "never",
            "--no-mtime", "--restrict-filenames", "--newline", "--progress", "--progress-delta", "0.3",
            "--abort-on-unavailable-fragments",
            "--progress-template", "download:MEDIA|%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s",
            "--output", output,
        ]
        if let clip = spec.clip {
            var options = "-nostats -loglevel error -progress pipe:1 -f matroska"
            if spec.kind.isVideo {
                options += " -c:v libx264 -pix_fmt yuv420p -preset veryfast -c:a aac -b:a 192k"
                options += spec.videoBitrate > 0 ? " -b:v \(spec.videoBitrate)k" : " -crf 18"
            } else {
                options += " -vn -c:a flac"
            }
            args += ["--download-sections", clip.section, "--force-keyframes-at-cuts",
                     "--downloader-args", "ffmpeg_i:-rw_timeout 20000000",
                     "--downloader-args", "ffmpeg_o:\(options)"]
        }
        return args + ["--", spec.source]
    }

    func download(_ spec: DownloadSpec, id: UUID, cancellation: CommandCancellation,
                  update: @escaping @Sendable (EngineUpdate) -> Void) async throws -> URL {
        try tools.validate()
        try cancellation.check()
        let files = FileManager.default
        try files.createDirectory(at: spec.folder, withIntermediateDirectories: true)
        let working = spec.folder.appendingPathComponent(".素材下载-\(id.uuidString)", isDirectory: true)
        try files.createDirectory(at: working, withIntermediateDirectories: false)
        defer { try? files.removeItem(at: working) }

        update(.downloading(nil, "连接来源网站…"))
        let args = sourceArguments(spec, stagedAt: working)
        let report: @Sendable (String) -> Void = { line in
            if let progress = EngineUpdate.downloadLine(line, duration: spec.clip?.duration) { update(progress) }
        }
        var result = try await Command.run(tools.downloader, args, cancellation: cancellation, onLine: report)
        if result.retryableNetworkFailure {
            update(.downloading(nil, "网络连接中断，正在重试…"))
            try await Task.sleep(for: .seconds(2))
            try cancellation.check()
            for item in try files.contentsOfDirectory(at: working, includingPropertiesForKeys: nil) {
                try files.removeItem(at: item)
            }
            result = try await Command.run(tools.downloader, args, cancellation: cancellation, onLine: report)
        }
        try result.requireSuccess("下载素材失败。")

        let intermediates = try files.contentsOfDirectory(at: working, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.range(of: #"^source\.[A-Za-z0-9]+$"#, options: .regularExpression) != nil }
        guard intermediates.count == 1, let source = intermediates.first,
              files.isReadableFile(atPath: source.path) else {
            throw WorkbenchError("下载引擎没有生成可用的素材文件。")
        }
        update(.exporting(nil))
        let staged = try await export(source, spec: spec, working: working, cancellation: cancellation, update: update)
        try cancellation.check()
        return try publish(staged, spec: spec)
    }

    func export(_ source: URL, spec: DownloadSpec, working: URL, cancellation: CommandCancellation,
                update: @escaping @Sendable (EngineUpdate) -> Void) async throws -> URL {
        let probe = try await Command.run(tools.ffprobe,
            ["-v", "error", "-show_entries", "stream=codec_type,codec_name", "-of", "json", source.path],
            cancellation: cancellation, captureOutput: true)
        try probe.requireSuccess("无法识别下载文件的音视频编码。")
        let streams = try JSONDecoder().decode(Probe.self, from: probe.output).streams
        let staged = working.appendingPathComponent("export.\(spec.kind.rawValue)")
        var args = ["-nostdin", "-hide_banner", "-loglevel", "error", "-nostats",
                    "-progress", "pipe:1", "-i", source.path]
        if spec.kind.isVideo {
            guard let video = streams.first(where: { $0.codec_type == "video" }) else {
                throw WorkbenchError("下载文件没有可用的视频轨。")
            }
            let audio = streams.first(where: { $0.codec_type == "audio" })
            args += ["-map", "0:v:0", "-map", "0:a:0?"]
            if video.codec_name == "h264", spec.videoBitrate == 0 || spec.clip != nil {
                args += ["-c:v", "copy"]
            } else {
                args += ["-c:v", "libx264", "-pix_fmt", "yuv420p", "-preset", "veryfast"]
                args += spec.videoBitrate == 0 ? ["-crf", "18"] : ["-b:v", "\(spec.videoBitrate)k"]
            }
            args += audio?.codec_name == "aac" ? ["-c:a", "copy"] : ["-c:a", "aac", "-b:a", "192k"]
            args += ["-movflags", "+faststart"]
        } else {
            guard streams.contains(where: { $0.codec_type == "audio" }) else {
                throw WorkbenchError("下载文件没有可用的音频轨。")
            }
            args += ["-map", "0:a:0", "-vn", "-c:a", spec.kind == .mp3 ? "libmp3lame" : "aac",
                     "-b:a", "\(spec.audioBitrate)k"]
            if spec.kind == .m4a { args += ["-movflags", "+faststart"] }
        }
        if let clip = spec.clip { args += ["-t", Clip.decimal(clip.duration)] }
        args += [staged.path]
        let result = try await Command.run(tools.ffmpeg, args, cancellation: cancellation) { line in
            if let value = EngineUpdate.ffmpegProgress(line, duration: spec.clip?.duration ?? spec.duration) {
                update(.exporting(value))
            }
        }
        try result.requireSuccess("导出 %@ 文件失败。", spec.kind.title)
        let size = try staged.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0 else { throw WorkbenchError("导出的素材文件为空。") }
        return staged
    }

    private func publish(_ staged: URL, spec: DownloadSpec) throws -> URL {
        let reserved = CharacterSet(charactersIn: "/\\:*?\u{22}<>|").union(.controlCharacters)
        let safe = spec.title.components(separatedBy: reserved).joined(separator: " ")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ".")))
        let limited = String(decoding: safe.utf8.prefix(150), as: UTF8.self).replacingOccurrences(of: "\u{FFFD}", with: "")
        let base = (limited.isEmpty ? "视频素材" : limited)
            + (spec.clip.map { " [\($0.fileLabel)]" } ?? "")
            + (spec.kind.isVideo && spec.resolution > 0 ? " [\(spec.resolution)p]" : "")
        let files = FileManager.default
        for attempt in 1...1000 {
            let name = attempt == 1 ? base : "\(base) (\(attempt))"
            let destination = spec.folder.appendingPathComponent(name).appendingPathExtension(spec.kind.rawValue)
            do {
                try files.moveItem(at: staged, to: destination)
                return destination
            } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileWriteFileExistsError {
                continue
            }
        }
        throw WorkbenchError("目标文件夹中有太多同名文件。")
    }

    private struct Probe: Decodable {
        struct Stream: Decodable {
            let codec_type: String
            let codec_name: String?
        }
        let streams: [Stream]
    }
}

enum EngineUpdate: Sendable {
    case downloading(Double?, String)
    case exporting(Double?)

    static func downloadLine(_ line: String, duration: Double?) -> EngineUpdate? {
        if line.hasPrefix("MEDIA|") {
            let fields = line.split(separator: "|", omittingEmptySubsequences: false)
            guard fields.count == 4 else { return nil }
            let percent = Double(fields[1].replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces))
            let speed = fields[2].trimmingCharacters(in: .whitespaces)
            return .downloading(percent.map { min(0.99, $0 / 100) }, speed.isEmpty || speed == "Unknown" || speed == "NA" ? "下载素材流" : speed)
        }
        if let progress = ffmpegProgress(line, duration: duration) {
            return .downloading(progress, "读取所选片段")
        }
        return nil
    }

    static func ffmpegProgress(_ line: String, duration: Double?) -> Double? {
        let prefix = "out_time_us="
        guard let duration, duration > 0, line.hasPrefix(prefix),
              let microseconds = Double(line.dropFirst(prefix.count)) else { return nil }
        return max(0, min(0.99, microseconds / 1_000_000 / duration))
    }
}
