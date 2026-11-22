import SwiftUI
import AppKit

enum JobStatus: String, Codable {
    case queued, downloading, exporting, complete, failed, cancelled

    var title: String {
        switch self {
        case .queued: "排队中"
        case .downloading: "下载中"
        case .exporting: "导出中"
        case .complete: "已完成"
        case .failed: "失败"
        case .cancelled: "已取消"
        }
    }
    var pending: Bool { self == .queued || self == .downloading || self == .exporting }
    var active: Bool { self == .downloading || self == .exporting }
}

struct DownloadJob: Identifiable, Codable {
    var id = UUID()
    let spec: DownloadSpec
    var created = Date()
    var status: JobStatus = .queued
    var file: URL?
    var error: LocalizedMessage?

    // The queue saves stage changes. Transfer updates stay in memory.
    var progress: Double?
    var transferNote: String?

    enum CodingKeys: String, CodingKey {
        case id, spec, created, status, file, error
    }
}

enum QueueFilter: String, CaseIterable {
    case all = "全部", pending = "进行中", complete = "已完成", failed = "失败"

    func includes(_ status: JobStatus) -> Bool {
        switch self {
        case .all: true
        case .pending: status.pending
        case .complete: status == .complete
        case .failed: status == .failed
        }
    }
}

@MainActor
final class Workbench: ObservableObject {
    @Published var link = ""
    @Published private(set) var info: MediaInfo?
    @Published private(set) var inspecting = false
    @Published private(set) var inspectError: LocalizedMessage?
    @Published private(set) var jobs: [DownloadJob] = []

    @Published var kind: OutputKind = .mp4
    @Published var resolution = 0
    @Published var videoBitrate = 0
    @Published var audioBitrate = 192
    @Published var isClipping = false
    @Published var clipStart = "00:00:00"
    @Published var clipEnd = "00:03:00"
    @Published var filter: QueueFilter = .all
    @Published private(set) var folder: URL
    @Published private(set) var language: AppLanguage
    @Published var alert: LocalizedMessage?

    var strings: WebbieStrings { WebbieStrings(language, resources: resources) }
    private let resources: Bundle
    @Published private(set) var cancelling: UUID?

    private let engine: MediaEngine
    private let dataDirectory: URL
    private var history: URL { dataDirectory.appendingPathComponent("history.json") }
    private var preferences: URL { dataDirectory.appendingPathComponent("settings.json") }
    private var inspectCancellation: CommandCancellation?
    private var resolvedSource: MediaLink?
    private var directConnection = false
    private var active: (id: UUID, cancellation: CommandCancellation)?

    var byFilter: [DownloadJob] { jobs.filter { filter.includes($0.status) } }
    var pendingCount: Int { jobs.filter { $0.status.pending }.count }
    var resolved: Bool { info != nil && !inspecting }
    var readinessError: LocalizedMessage? {
        if inspecting || info == nil { return nil }
        do { _ = try specification(); return nil }
        catch { return LocalizedMessage(error: error) }
    }

    private struct Settings: Codable {
        let folder: URL
        let language: AppLanguage
    }

    init(resources: Bundle = .main) {
        self.resources = resources
        let files = FileManager.default
        let support = files.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let downloads = files.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let qaDirectory = ProcessInfo.processInfo.environment["MATERIAL_WORKBENCH_TEST_ROOT"]
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
        dataDirectory = qaDirectory?.appendingPathComponent("工作台数据", isDirectory: true)
            ?? support.appendingPathComponent("MaterialWorkbench", isDirectory: true)
        let root = qaDirectory ?? downloads
        let previousFolder = root.appendingPathComponent("YouTube 素材", isDirectory: true)
        let defaultFolder = files.fileExists(atPath: previousFolder.path) ? previousFolder
            : root.appendingPathComponent("剪辑素材", isDirectory: true)
        let saved = try? Data(contentsOf: dataDirectory.appendingPathComponent("settings.json"))
        let settings = saved.flatMap { try? JSONDecoder().decode(Settings.self, from: $0) }
        let legacyFolder = saved.flatMap { try? JSONDecoder().decode(URL.self, from: $0) }
        folder = settings?.folder ?? legacyFolder ?? defaultFolder
        language = settings?.language ?? .simplifiedChinese
        let binaries = resources.resourceURL!.appendingPathComponent("Runtime", isDirectory: true)
        engine = MediaEngine(tools: RuntimeTools(directory: binaries))

        if files.fileExists(atPath: history.path) {
            do {
                jobs = try JSONDecoder().decode([DownloadJob].self, from: Data(contentsOf: history))
                var interrupted = false
                for index in jobs.indices where jobs[index].status.active {
                    let job = jobs[index]
                    let staged = job.spec.folder.appendingPathComponent(".素材下载-\(job.id.uuidString)", isDirectory: true)
                    try? files.removeItem(at: staged)
                    jobs[index].status = .failed
                    jobs[index].error = "上次退出时任务仍在运行，你可以重新下载。"
                    interrupted = true
                }
                if interrupted { saveHistory() }
            } catch {
                alert = "读取任务记录失败。"
            }
        }
        Task { @MainActor [weak self] in self?.startNext() }
    }

    func sourceChanged() {
        inspectCancellation?.cancel()
        inspectCancellation = nil
        resolvedSource = nil
        inspecting = false
        info = nil
        inspectError = nil
        resolution = 0
    }

    func paste() {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        if link != text { sourceChanged() }
        link = text.trimmingCharacters(in: .whitespacesAndNewlines)
        inspect()
    }

    func inspect() {
        guard !inspecting else { return }
        inspectError = nil
        info = nil
        resolvedSource = nil
        let source: MediaLink
        do { source = try MediaLink(link) }
        catch { inspectError = LocalizedMessage(error: error); return }

        let cancellation = CommandCancellation()
        inspectCancellation = cancellation
        inspecting = true
        Task {
            do {
                let inspected = try await engine.inspect(source, cancellation: cancellation)
                guard inspectCancellation === cancellation else { return }
                let media = inspected.info
                resolvedSource = inspected.source
                directConnection = inspected.directConnection
                info = media
                resolution = media.resolutions.first(where: { $0 <= 1080 }) ?? media.resolutions.last ?? 0
                if !media.hasVideo { kind = .m4a }
                else if !media.canExtractAudio { kind = .mp4 }
                if let duration = media.duration, (Clip.parse(clipEnd) ?? .infinity) > duration {
                    clipEnd = Clip.display(duration)
                }
            } catch {
                guard inspectCancellation === cancellation else { return }
                inspectError = LocalizedMessage(error: error)
            }
            inspectCancellation = nil
            inspecting = false
        }
    }

    func preset(_ seconds: Double) {
        isClipping = true
        clipStart = "00:00:00"
        clipEnd = Clip.display(min(seconds, info?.duration ?? seconds))
    }

    func add() {
        do {
            let job = DownloadJob(spec: try specification())
            jobs.insert(job, at: 0)
            if filter == .complete || filter == .failed { filter = .all }
            saveHistory()
            startNext()
        } catch {
            alert = LocalizedMessage(error: error)
        }
    }

    func retry(_ job: DownloadJob) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }),
              jobs[index].status == .failed || jobs[index].status == .cancelled else { return }
        jobs[index].status = .queued
        jobs[index].error = nil
        jobs[index].progress = nil
        jobs[index].transferNote = nil
        if filter == .failed { filter = .all }
        saveHistory()
        startNext()
    }

    func cancel(_ id: UUID) {
        if let active, active.id == id {
            cancelling = id
            active.cancellation.cancel()
        } else if let index = jobs.firstIndex(where: { $0.id == id }), jobs[index].status == .queued {
            jobs[index].status = .cancelled
            saveHistory()
        }
    }

    func removeRecord(_ job: DownloadJob) {
        guard !job.status.pending else { return }
        jobs.removeAll { $0.id == job.id }
        saveHistory()
    }

    func selectFolder() {
        let picker = NSOpenPanel()
        picker.canChooseFiles = false
        picker.canChooseDirectories = true
        picker.canCreateDirectories = true
        picker.message = strings("选择新下载任务的素材保存位置")
        picker.prompt = strings("选择文件夹")
        picker.directoryURL = FileManager.default.fileExists(atPath: folder.path) ? folder : folder.deletingLastPathComponent()
        guard picker.runModal() == .OK, let selected = picker.url else { return }
        updateSettings(folder: selected, language: language)
    }

    func selectLanguage(_ language: AppLanguage) {
        guard self.language != language else { return }
        updateSettings(folder: folder, language: language)
    }

    private func updateSettings(folder: URL, language: AppLanguage) {
        do {
            try write(Settings(folder: folder, language: language), to: preferences)
            self.folder = folder
            self.language = language
        } catch {
            alert = LocalizedMessage("保存设置失败。", detail: error.localizedDescription)
        }
    }

    func openFolder() {
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            NSWorkspace.shared.open(folder)
        } catch { alert = LocalizedMessage("无法打开下载文件夹。", detail: error.localizedDescription) }
    }

    func reveal(_ job: DownloadJob) {
        guard let file = job.file else { return }
        if FileManager.default.fileExists(atPath: file.path) {
            NSWorkspace.shared.activateFileViewerSelecting([file])
        } else {
            if FileManager.default.fileExists(atPath: job.spec.folder.path) { NSWorkspace.shared.open(job.spec.folder) }
            alert = "素材文件已移动或删除。"
        }
    }

    private func specification() throws -> DownloadSpec {
        guard let info, let source = resolvedSource else { throw WorkbenchError("请先解析视频链接。") }
        let clip = isClipping ? try Clip(start: clipStart, end: clipEnd, duration: info.duration) : nil
        let selector = try info.selector(kind: kind, resolution: resolution, clip: clip != nil)
        return DownloadSpec(source: source.canonical, title: info.title, thumbnail: info.thumbnail,
            kind: kind, resolution: resolution, videoBitrate: videoBitrate, audioBitrate: audioBitrate,
            selector: selector, clip: clip, duration: info.duration, folder: folder,
            directConnection: directConnection ? true : nil)
    }

    private func write<T: Encodable>(_ value: T, to file: URL) throws {
        try FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
        try JSONEncoder().encode(value).write(to: file, options: .atomic)
    }

    private func saveHistory() {
        do { try write(jobs, to: history) }
        catch { alert = LocalizedMessage("保存任务记录失败。", detail: error.localizedDescription) }
    }

    private func startNext() {
        guard active == nil, let index = jobs.lastIndex(where: { $0.status == .queued }) else { return }
        let job = jobs[index]
        let cancellation = CommandCancellation()
        active = (job.id, cancellation)
        jobs[index].status = .downloading
        jobs[index].transferNote = "连接来源网站…"
        saveHistory()
        Task {
            let result: Result<URL, Error>
            do {
                let file = try await engine.download(job.spec, id: job.id, cancellation: cancellation) { [weak self] update in
                    Task { @MainActor [weak self] in self?.receive(update, for: job.id) }
                }
                result = .success(file)
            } catch {
                result = .failure(error)
            }
            finish(job.id, result: result)
        }
    }

    private func receive(_ update: EngineUpdate, for id: UUID) {
        guard active?.id == id, cancelling != id, let index = jobs.firstIndex(where: { $0.id == id }) else { return }
        switch update {
        case let .downloading(progress, note):
            guard jobs[index].status == .downloading else { return }
            jobs[index].progress = progress
            jobs[index].transferNote = note
        case let .exporting(progress):
            let changed = jobs[index].status != .exporting
            jobs[index].status = .exporting
            jobs[index].progress = progress
            jobs[index].transferNote = nil
            if changed { saveHistory() }
        }
    }

    private func finish(_ id: UUID, result: Result<URL, Error>) {
        guard active?.id == id, let index = jobs.firstIndex(where: { $0.id == id }) else { return }
        switch result {
        case let .success(file):
            jobs[index].file = file
            jobs[index].status = .complete
        case let .failure(error):
            if error is CancellationError {
                jobs[index].status = .cancelled
            } else {
                jobs[index].status = .failed
                jobs[index].error = LocalizedMessage(error: error)
            }
        }
        jobs[index].progress = nil
        jobs[index].transferNote = nil
        active = nil
        cancelling = nil
        saveHistory()
        startNext()
    }
}
