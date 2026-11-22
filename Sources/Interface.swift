import AppKit
import SwiftUI

private enum Palette {
    static let workspace = Color(hex: 0xF6F7F9)
    static let surface = Color.white
    static let field = Color(hex: 0xF9FAFC)
    static let quiet = Color(hex: 0xF0F2F5)
    static let line = Color(hex: 0xE3E7ED)
    static let ink = Color(hex: 0x172234)
    static let muted = Color(hex: 0x526074)
    static let icon = Color(hex: 0x6D7B8D)
    static let accent = Color(hex: 0x1558D6)
    static let accentPressed = Color(hex: 0x1048B2)
    static let paleBlue = Color(hex: 0xEAF2FF)
    static let green = Color(hex: 0x1C7052)
    static let paleGreen = Color(hex: 0xE9F5EF)
    static let red = Color(hex: 0xAD3938)
    static let paleRed = Color(hex: 0xFFF0EF)
}

private enum AppIdentity {
    static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Webbie"
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.5.1"
    static let logo = Bundle.main.url(forResource: "Webbie", withExtension: "png").flatMap(NSImage.init(contentsOf:))
}

private struct WebbieStringsKey: EnvironmentKey {
    static let defaultValue = WebbieStrings(.simplifiedChinese)
}

private extension EnvironmentValues {
    var webbieStrings: WebbieStrings {
        get { self[WebbieStringsKey.self] }
        set { self[WebbieStringsKey.self] = newValue }
    }
}

@main
struct MaterialsApp: App {
    @StateObject private var model = Workbench()

    var body: some Scene {
        Window(AppIdentity.name, id: "workbench") {
            WorkbenchScreen(model: model)
                .frame(minWidth: 900, minHeight: 650)
                .environment(\.webbieStrings, model.strings)
                .environment(\.locale, model.language.locale)
                .preferredColorScheme(.light)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1160, height: 800)
    }
}

private enum WorkspacePage: CaseIterable {
    case workspace, history, about, settings

    var title: String {
        switch self {
        case .workspace: "下载工作台"
        case .history: "下载记录"
        case .about: "关于"
        case .settings: "设置"
        }
    }

    var symbol: String {
        switch self {
        case .workspace: "tray.and.arrow.down"
        case .history: "clock"
        case .about: "info.circle"
        case .settings: "gearshape"
        }
    }
}

private struct WorkbenchScreen: View {
    @Environment(\.webbieStrings) private var tr
    @ObservedObject var model: Workbench
    @State private var page: WorkspacePage = .workspace

    var body: some View {
        HStack(spacing: 0) {
            sidebar.frame(width: 206)
            Rectangle().fill(Palette.line).frame(width: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heading
                    switch page {
                    case .about:
                        AboutPage()
                    case .settings:
                        SettingsPage(model: model)
                    case .workspace, .history:
                        if page == .workspace { DownloadComposer(model: model) }
                        DownloadList(model: model, isHistory: page == .history) {
                            model.filter = .all
                            page = .history
                        }
                    }
                }
                .frame(maxWidth: 1020)
                .padding(.horizontal, 32)
                .padding(.top, 49)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
            .id(page)
            .background(Palette.workspace)
        }
        .foregroundStyle(Palette.ink)
        .background(Palette.workspace)
        .tint(Palette.accent)
        .ignoresSafeArea(edges: .top)
        .alert(AppIdentity.name, isPresented: Binding(
            get: { model.alert != nil },
            set: { if !$0 { model.alert = nil } }
        )) {
            Button(tr("好")) { model.alert = nil }
        } message: {
            Text(model.alert.map { tr($0) } ?? "")
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                WebbieMark(size: 31)
                Text(AppIdentity.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 9)
            .padding(.bottom, 23)

            ForEach([WorkspacePage.workspace, .history], id: \.self) { destination in
                Button { page = destination } label: {
                    sidebarLabel(tr(destination.title), icon: destination.symbol) {
                        if destination == .history, model.pendingCount > 0 {
                            Text(model.pendingCount.formatted(.number.locale(tr.language.locale))).monospacedDigit()
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Palette.surface, in: Capsule())
                                .accessibilityLabel(tr("%@ 个待处理任务", model.pendingCount.formatted(.number.locale(tr.language.locale))))
                        }
                    }
                }
                .buttonStyle(SidebarButton(selected: destination == page))
                .accessibilityAddTraits(destination == page ? .isSelected : [])
                .padding(.bottom, 4)
            }

            Spacer(minLength: 20)
            Divider().overlay(Palette.line).padding(.horizontal, 8).padding(.bottom, 9)
            Button { model.openFolder() } label: {
                sidebarLabel(tr("打开下载文件夹"), icon: "folder") {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.icon)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(SidebarButton())
            ForEach([WorkspacePage.settings, .about], id: \.self) { destination in
                Button { page = destination } label: {
                    sidebarLabel(tr(destination.title), icon: destination.symbol) { EmptyView() }
                }
                .buttonStyle(SidebarButton(selected: page == destination))
                .accessibilityAddTraits(page == destination ? .isSelected : [])
                .padding(.top, 3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 49)
        .padding(.bottom, 19)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.surface)
    }

    private func sidebarLabel<Trailing: View>(_ title: String, icon: String,
                                             @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon).font(.system(size: 14, weight: .medium)).frame(width: 20)
                .accessibilityHidden(true)
            Text(title).lineLimit(1)
            Spacer(minLength: 3)
            trailing()
        }
    }

    private var heading: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(tr(page.title))
                    .font(.system(size: 27, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                if page == .workspace {
                    Text(tr("从视频链接下载完整素材，或直接保存需要的片段。"))
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.muted)
                }
            }
            Spacer()
            if page == .history {
                Button { page = .workspace } label: {
                    Label(tr("新建下载"), systemImage: "plus")
                }
                .buttonStyle(ActionButton(.primary))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 1)
    }
}

private struct SettingsPage: View {
    @ObservedObject var model: Workbench
    @Environment(\.webbieStrings) private var tr

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeading(tr("界面语言"))
            VStack(spacing: 4) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    let selected = model.language == language
                    Button {
                        model.selectLanguage(language)
                    } label: {
                        HStack {
                            Text(language.name)
                            Spacer()
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .buttonStyle(SidebarButton(selected: selected))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
        .padding(22)
        .card()
        .frame(maxWidth: 460, alignment: .leading)
    }
}

private struct WebbieMark: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let logo = AppIdentity.logo {
                Image(nsImage: logo).resizable().scaledToFit()
            } else {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: size * 0.46))
                    .foregroundStyle(Palette.ink)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private enum CreatorProfile: String, CaseIterable {
    case github = "GitHub"
    case rednote = "小红书"
    case x = "X"

    var symbol: String {
        switch self {
        case .github: "chevron.left.forwardslash.chevron.right"
        case .rednote: "book.closed"
        case .x: "bubble.left"
        }
    }

    var url: URL? {
        let key: String
        let domains: [String]
        switch self {
        case .github:
            key = "CreatorGitHubURL"
            domains = ["github.com"]
        case .rednote:
            key = "CreatorRedNoteURL"
            domains = ["xiaohongshu.com", "xhslink.com", "xhslink.cn", "rednote.com", "bit.ly"]
        case .x:
            key = "CreatorXURL"
            domains = ["x.com", "twitter.com", "bit.ly"]
        }
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              let url = URL(string: value),
              let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme),
              let host = url.host?.lowercased(), url.user == nil, url.password == nil,
              domains.contains(where: { host == $0 || host == "www.\($0)" }),
              !url.pathComponents.dropFirst().isEmpty else { return nil }
        return url
    }
}

private struct AboutPage: View {
    @Environment(\.webbieStrings) private var tr
    private let titleColumnWidth: CGFloat = 308
    private let titles: [(emoji: String, text: String)] = [
        ("🤵", "增长运营专家"),
        ("🎮", "某 ARR 一亿产品全球营销操盘手"),
        ("🦹", "ENTP"),
        ("💻", "Vibe Coding中"),
        ("✍️", "小红书 500 粉主理人（到千粉会更新 :)）"),
        ("☕️", "Coffee Chat 爱好者"),
        ("🌴", "为旅行而生"),
        ("🫘", "豆瓣鹅组 & 踩组成员"),
        ("💿", "欧美音乐发烧友"),
        ("❌", "这辈子不会再搞 AI 音乐"),
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            titleColumn
            VStack(alignment: .leading, spacing: 20) {
                introduction
                Divider().overlay(Palette.line)
                profiles
            }
            .padding(25)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(alignment: .leading) {
            Palette.field.frame(width: titleColumnWidth)
                .overlay(alignment: .trailing) { Palette.line.frame(width: 1) }
        }
        .card()
        .frame(maxWidth: 840, alignment: .leading)
    }

    private var titleColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rayn")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 5) {
                ForEach(titles.indices, id: \.self) { index in
                    let title = titles[index]
                    HStack(spacing: 9) {
                        Text(title.emoji)
                            .font(.system(size: 15))
                            .frame(width: 21)
                            .accessibilityHidden(true)
                        Text(tr(title.text))
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(minHeight: 20)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(tr("Rayn 的头衔"))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(width: titleColumnWidth, alignment: .leading)
    }

    private var introduction: some View {
        HStack(spacing: 11) {
            WebbieMark(size: 51)
            VStack(alignment: .leading, spacing: 5) {
                Text(AppIdentity.name)
                    .font(.system(size: 20, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Text(tr("由 Rayn 开发 · 版本 %@", AppIdentity.version))
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    private var profiles: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tr("欢迎关注，我会继续 Build in Public，分享现在做的产品开发过程和每次更新。"))
                .font(.system(size: 13))
                .foregroundStyle(Palette.muted)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                ForEach(CreatorProfile.allCases, id: \.self) { profile in
                    if profile != .github { Divider().overlay(Palette.line) }
                    if let url = profile.url {
                        Link(destination: url) { profileRow(profile, available: true) }
                            .buttonStyle(SidebarButton())
                            .accessibilityLabel(tr("打开 Rayn 的 %@ 主页", tr(profile.rawValue)))
                    } else {
                        profileRow(profile, available: false)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 8)
                            .frame(height: 36)
                    }
                }
            }
        }
    }

    private func profileRow(_ profile: CreatorProfile, available: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: profile.symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(available ? Palette.muted : Palette.icon)
                .frame(width: 17)
                .accessibilityHidden(true)
            Text(tr(profile.rawValue)).foregroundStyle(Palette.ink)
            Spacer()
            if available {
                Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .medium))
                    .accessibilityHidden(true)
            } else {
                Text(tr("待补充")).font(.system(size: 11)).foregroundStyle(Palette.icon)
            }
        }
    }
}

private struct DownloadComposer: View {
    @Environment(\.webbieStrings) private var tr
    @ObservedObject var model: Workbench
    @FocusState private var linkFocused: Bool

    private var hasLink: Bool { !model.link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 13) {
                cardHeading(tr("新建下载"))
                linkControl
                if let info = model.info { sourcePreview(info) }
                if let message = model.inspectError { InlineError(message: tr(message)) }
            }
            .padding(22)

            Divider().overlay(Palette.line)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 24) {
                    formatSettings
                    rangeSettings
                }
                if let message = model.readinessError { InlineError(message: tr(message)) }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 19)

            Divider().overlay(Palette.line)

            footer
        }
        .card()
    }

    private var linkControl: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "link").font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.icon)
                    .accessibilityHidden(true)
                TextField(tr("粘贴视频链接或分享文案"), text: Binding(
                    get: { model.link },
                    set: { updateLink($0) }
                ), prompt: Text(tr("粘贴视频链接或分享文案")).foregroundStyle(Palette.icon))
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($linkFocused)
                .onSubmit { if hasLink { model.inspect() } }
                .accessibilityLabel(tr("视频链接或分享文案"))

                if hasLink {
                    Button { model.paste() } label: {
                        Image(systemName: "document.on.clipboard")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.icon)
                            .frame(width: 20, height: 24)
                    }
                    .buttonStyle(.plain)
                    .help(tr("粘贴并解析剪贴板中的链接"))
                    .accessibilityLabel(tr("粘贴并解析新链接"))

                    Button {
                        updateLink("")
                        linkFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.icon)
                            .frame(width: 20, height: 24)
                    }
                    .buttonStyle(.plain)
                    .help(tr("清空链接"))
                    .accessibilityLabel(tr("清空链接"))
                }
            }
            .padding(.horizontal, 11)
            .frame(height: 40)
            .fieldSurface(focused: linkFocused)

            Button {
                if hasLink {
                    model.inspect()
                } else {
                    model.paste()
                    if !hasLink { linkFocused = true }
                }
            } label: {
                if model.inspecting {
                    HStack(spacing: 7) {
                        ProgressView().controlSize(.small)
                        Text(tr("解析中"))
                    }
                    .frame(minWidth: 71)
                } else if hasLink {
                    Label(model.resolved ? tr("重新解析") : tr("解析链接"), systemImage: "arrow.right")
                        .frame(minWidth: 71)
                } else {
                    Label(tr("粘贴链接"), systemImage: "document.on.clipboard")
                        .frame(minWidth: 71)
                }
            }
            .buttonStyle(ActionButton(model.resolved || model.inspecting ? .secondary : .primary, height: 40))
            .disabled(model.inspecting)
            .help(hasLink ? tr("解析当前链接") : tr("粘贴并解析剪贴板中的链接"))
        }
    }

    private func updateLink(_ text: String) {
        guard text != model.link else { return }
        model.sourceChanged()
        model.link = text
    }

    private func sourcePreview(_ info: MediaInfo) -> some View {
        HStack(spacing: 10) {
            Thumbnail(url: info.thumbnail, kind: .mp4, width: 66, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(info.title).font(.system(size: 13, weight: .semibold)).lineLimit(2)
                    .help(info.title)
                HStack(spacing: 8) {
                    if let duration = info.duration {
                        Text(Clip.display(duration)).monospacedDigit()
                    }
                    if let channel = info.channelsLabel { Text(channel).lineLimit(1) }
                }
                .font(.system(size: 11)).foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 8)
            Label(tr("已解析"), systemImage: "checkmark.circle.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Palette.green)
        }
        .padding(9)
        .background(Palette.field, in: RoundedRectangle(cornerRadius: 8))
    }

    private var formatSettings: some View {
        VStack(alignment: .leading, spacing: 9) {
            fieldLabel(tr("导出格式"))
            HStack(spacing: 3) {
                ForEach(OutputKind.allCases, id: \.self) { kind in
                    Button { model.kind = kind } label: {
                        Label(kind.title, systemImage: kind.isVideo ? "film" : "waveform")
                    }
                    .buttonStyle(SegmentButton(selected: model.kind == kind))
                    .disabled(model.info.map { kind.isVideo ? !$0.hasVideo : !$0.canExtractAudio } ?? false)
                    .accessibilityAddTraits(model.kind == kind ? .isSelected : [])
                }
            }
            .segmentGroup()
            if model.kind.isVideo {
                HStack(alignment: .top, spacing: 9) {
                    let options = model.info?.resolutions ?? []
                    optionField(tr("分辨率"), selection: $model.resolution,
                                options: options + (model.info?.hasUnknownResolution == true || options.isEmpty ? [0] : [])) {
                        $0 > 0 ? "\($0)p" : model.resolved ? tr("源分辨率") : tr("解析后可选")
                    }
                    .disabled(!model.resolved)
                    optionField(tr("视频码率"), selection: $model.videoBitrate,
                                options: [0, 1200, 2500, 5000, 8000, 12000, 20000]) {
                        $0 == 0 ? tr("自动") : "\($0) kbps"
                    }
                }
                .padding(.top, 3)
            } else {
                optionField(tr("音频码率"), selection: $model.audioBitrate,
                            options: [64, 96, 128, 160, 192, 256, 320]) { "\($0) kbps" }
                    .padding(.top, 3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rangeSettings: some View {
        VStack(alignment: .leading, spacing: 9) {
            fieldLabel(tr("下载范围"))
            HStack(spacing: 3) {
                Button { model.isClipping = false } label: { Label(tr("完整素材"), systemImage: "rectangle") }
                    .buttonStyle(SegmentButton(selected: !model.isClipping))
                    .accessibilityAddTraits(model.isClipping ? [] : .isSelected)
                Button { model.isClipping = true } label: { Label(tr("指定片段"), systemImage: "scissors") }
                    .buttonStyle(SegmentButton(selected: model.isClipping))
                    .accessibilityAddTraits(model.isClipping ? .isSelected : [])
            }
            .segmentGroup()
            if model.isClipping {
                HStack(alignment: .top, spacing: 9) {
                    timeField(tr("开始时间"), input: $model.clipStart)
                    timeField(tr("结束时间"), input: $model.clipEnd)
                }
                .padding(.top, 3)
            }

            HStack(spacing: 7) {
                Button(tr("前 30 秒")) { model.preset(30) }
                    .buttonStyle(ActionButton(.subtle, height: 28))
                Button(tr("前 3 分钟")) { model.preset(180) }
                    .buttonStyle(ActionButton(.subtle, height: 28))
            }
            .padding(.top, model.isClipping ? 0 : 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func optionField(_ label: String, selection: Binding<Int>, options: [Int],
                             title: @escaping (Int) -> String) -> some View {
        OptionField(label: label, selection: selection, options: options, title: title)
    }

    private func timeField(_ label: String, input: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(label)
            TextField("00:00:00", text: input)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10)
                .frame(height: 34)
                .fieldSurface()
                .accessibilityLabel(label)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        HStack(spacing: 9) {
            Image(systemName: "folder").font(.system(size: 13)).foregroundStyle(Palette.icon)
                .accessibilityHidden(true)
            Text(tr("保存到"))
                .font(.system(size: 12)).foregroundStyle(Palette.muted)
                .fixedSize()
            Text((model.folder.path as NSString).abbreviatingWithTildeInPath)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1).truncationMode(.middle)
                .help(model.folder.path)
            Button(tr("更改")) { model.selectFolder() }
                .buttonStyle(ActionButton(.text, height: 28))
                .accessibilityLabel(tr("更改保存位置"))
                .fixedSize()
            Spacer(minLength: 12)
            Button { model.add() } label: {
                Label(tr("加入下载队列"), systemImage: "arrow.down.to.line")
            }
            .buttonStyle(ActionButton(.primary))
            .disabled(!model.resolved || model.readinessError != nil)
            .keyboardShortcut(.return, modifiers: .command)
            .fixedSize()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 13)
        .background(Palette.field)
    }
}

private struct OptionField: View {
    let label: String
    @Binding var selection: Int
    let options: [Int]
    let title: (Int) -> String
    @Environment(\.isEnabled) private var enabled
    @State private var showing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(label)
            Button { showing.toggle() } label: {
                HStack(spacing: 6) {
                    Text(title(selection)).lineLimit(1)
                    Spacer(minLength: 6)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Palette.icon)
                        .accessibilityHidden(true)
                }
                .font(.system(size: 12))
                .foregroundStyle(enabled ? Palette.ink : Palette.icon)
                .padding(.horizontal, 10)
                .frame(height: 34)
                .fieldSurface(focused: showing)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
            .accessibilityValue(title(selection))
            .popover(isPresented: $showing, arrowEdge: .top) {
                VStack(spacing: 2) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selection = option
                            showing = false
                        } label: {
                            HStack(spacing: 14) {
                                Text(title(option))
                                Spacer(minLength: 0)
                                if option == selection {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .semibold))
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        .buttonStyle(ActionButton(option == selection ? .selected : .plain, height: 30))
                        .accessibilityAddTraits(option == selection ? .isSelected : [])
                    }
                }
                .frame(width: 148)
                .padding(6)
                .onExitCommand { showing = false }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DownloadList: View {
    @Environment(\.webbieStrings) private var tr
    @ObservedObject var model: Workbench
    let isHistory: Bool
    let openHistory: () -> Void

    private var jobs: [DownloadJob] {
        isHistory ? model.byFilter : Array(model.jobs.prefix(4))
    }

    var body: some View {
        let visibleJobs = jobs
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                if isHistory {
                    ForEach(QueueFilter.allCases, id: \.self) { filter in
                        Button(tr(filter.rawValue)) { model.filter = filter }
                            .buttonStyle(ActionButton(model.filter == filter ? .selected : .plain, height: 31))
                            .accessibilityAddTraits(model.filter == filter ? .isSelected : [])
                    }
                    Spacer()
                    Text(tr("%@ 条任务", visibleJobs.count.formatted(.number.locale(tr.language.locale)))).font(.system(size: 12)).foregroundStyle(Palette.muted)
                } else {
                    cardHeading(tr("最近任务"))
                    Spacer()
                    if !model.jobs.isEmpty {
                        Button(action: openHistory) {
                            HStack(spacing: 5) {
                                Text(tr("查看全部"))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 8, weight: .semibold))
                                    .accessibilityHidden(true)
                            }
                        }
                        .buttonStyle(ActionButton(.text, height: 28))
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 15)

            Divider().overlay(Palette.line)

            if visibleJobs.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(visibleJobs) { job in
                        jobRow(job)
                        if job.id != visibleJobs.last?.id { Divider().overlay(Palette.line) }
                    }
                }
            }
        }
        .card()
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Palette.accent)
                .frame(width: 40, height: 40)
                .background(Palette.paleBlue, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
            Text(model.jobs.isEmpty ? tr("还没有下载任务") : tr("此筛选下没有任务"))
                .font(.system(size: 13, weight: .semibold))
            if model.jobs.isEmpty {
                Text(tr("下载进度和导出文件会显示在这里。"))
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
            } else {
                Button(tr("查看全部任务")) { model.filter = .all }
                    .buttonStyle(ActionButton(.text, height: 27))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func jobRow(_ job: DownloadJob) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Thumbnail(url: job.spec.thumbnail, kind: job.spec.kind, width: 60, height: 37)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 5) {
                Text(job.spec.title)
                    .font(.system(size: 13, weight: .semibold)).lineLimit(2)
                    .help(job.spec.title)
                Text(job.spec.detail(in: tr))
                    .font(.system(size: 11)).monospacedDigit().foregroundStyle(Palette.muted)
                    .lineLimit(2)
                if job.status.active {
                    HStack(spacing: 8) {
                        if let fraction = job.progress {
                            GeometryReader { track in
                                Capsule().fill(Palette.quiet).overlay(alignment: .leading) {
                                    Capsule().fill(Palette.accent)
                                        .frame(width: track.size.width * max(0, min(fraction, 1)))
                                }
                            }
                            .frame(width: 104, height: 4)
                            .accessibilityHidden(true)
                            Text("\(Int(fraction * 100))%").monospacedDigit()
                        }
                        if let note = job.transferNote { Text(tr(note)).lineLimit(1) }
                    }
                    .font(.system(size: 11)).foregroundStyle(Palette.muted)
                }
                if let message = job.error {
                    Text(tr(message))
                        .font(.system(size: 11)).foregroundStyle(Palette.red)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            StatusLabel(status: job.status, isCancelling: model.cancelling == job.id)
                .padding(.top, 3)
            HStack(spacing: 5) {
                rowAction(job)
                if !job.status.pending { jobMenu(job) }
            }
            .frame(width: 108, alignment: .trailing)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 11)
    }

    @ViewBuilder
    private func rowAction(_ job: DownloadJob) -> some View {
        switch job.status {
        case .complete:
            Button { model.reveal(job) } label: { Label("Finder", systemImage: "folder") }
                .buttonStyle(ActionButton(.secondary, height: 29))
                .help(tr("在 Finder 中显示文件"))
                .accessibilityLabel(tr("在 Finder 中显示文件"))
        case .queued, .downloading, .exporting:
            Button(tr("取消")) { model.cancel(job.id) }
                .buttonStyle(ActionButton(.secondary, height: 29))
                .disabled(model.cancelling == job.id)
        case .failed, .cancelled:
            Button(tr("重试")) { model.retry(job) }
                .buttonStyle(ActionButton(.secondary, height: 29))
        }
    }

    private func jobMenu(_ job: DownloadJob) -> some View {
        Menu {
            if let file = job.file {
                Button(tr("打开文件")) {
                    if FileManager.default.fileExists(atPath: file.path) { NSWorkspace.shared.open(file) }
                    else { model.alert = LocalizedMessage("素材文件已移动或删除。") }
                }
            }
            Button(tr("复制源链接")) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(job.spec.source, forType: .string)
            }
            Divider()
            Button(tr("移除任务记录")) { model.removeRecord(job) }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 24, height: 28)
                .foregroundStyle(Palette.muted)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .tint(Palette.muted)
        .fixedSize()
        .accessibilityLabel(tr("更多任务操作"))
    }
}

private struct StatusLabel: View {
    @Environment(\.webbieStrings) private var tr
    let status: JobStatus
    let isCancelling: Bool

    private var colors: (ink: Color, fill: Color) {
        switch status {
        case .complete: (Palette.green, Palette.paleGreen)
        case .failed: (Palette.red, Palette.paleRed)
        case .downloading, .exporting: (Palette.accent, Palette.paleBlue)
        case .queued, .cancelled: (Palette.muted, Palette.quiet)
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(colors.ink).frame(width: 5, height: 5).accessibilityHidden(true)
            Text(isCancelling ? tr("正在取消") : tr(status.title))
                .font(.system(size: 11, weight: .medium)).fixedSize()
        }
        .foregroundStyle(colors.ink)
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(colors.fill, in: Capsule())
    }
}

private struct Thumbnail: View {
    let url: URL?
    let kind: OutputKind
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Color.clear.frame(width: width, height: height)
            .overlay {
                if let url {
                    AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                    placeholder: { fallback }
                } else {
                    fallback
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .accessibilityHidden(true)
    }

    private var fallback: some View {
        Rectangle().fill(Palette.quiet)
            .overlay {
                Image(systemName: kind.isVideo ? "film" : "waveform")
                    .font(.system(size: 14)).foregroundStyle(Palette.icon)
            }
    }
}

private struct InlineError: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle")
            .font(.system(size: 12))
            .foregroundStyle(Palette.red)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(9)
            .background(Palette.paleRed, in: RoundedRectangle(cornerRadius: 7))
    }
}

private struct ActionButton: ButtonStyle {
    enum Tone { case primary, secondary, subtle, text, selected, plain }
    let tone: Tone
    var height: CGFloat
    @Environment(\.isEnabled) private var enabled

    init(_ tone: Tone = .secondary, height: CGFloat = 35) {
        self.tone = tone
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: height <= 29 ? 11 : 12, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, height <= 29 ? 8 : 11)
            .frame(height: height)
            .background(background(pressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 7))
            .overlay {
                if tone == .secondary {
                    RoundedRectangle(cornerRadius: 7).strokeBorder(Palette.line).allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
    }

    private var foreground: Color {
        guard enabled else { return Palette.icon }
        switch tone {
        case .primary: return Palette.surface
        case .text, .selected: return Palette.accent
        case .secondary, .subtle, .plain: return Palette.ink
        }
    }

    private func background(pressed: Bool) -> Color {
        guard enabled else { return Palette.quiet }
        switch tone {
        case .primary: return pressed ? Palette.accentPressed : Palette.accent
        case .secondary: return pressed ? Palette.quiet : Palette.surface
        case .subtle: return pressed ? Palette.line : Palette.quiet
        case .text, .plain: return pressed ? Palette.quiet : .clear
        case .selected: return pressed ? Palette.line : Palette.paleBlue
        }
    }
}

private struct SegmentButton: ButtonStyle {
    let selected: Bool
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(enabled ? (selected ? Palette.accent : Palette.muted) : Palette.icon)
            .lineLimit(1)
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity)
            .frame(height: 29)
            .background(configuration.isPressed ? Palette.line : selected ? Palette.surface : .clear,
                        in: RoundedRectangle(cornerRadius: 5))
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 5).strokeBorder(Palette.line.opacity(0.75))
                        .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
    }
}

private struct SidebarButton: ButtonStyle {
    var selected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: selected ? .semibold : .medium))
            .foregroundStyle(selected ? Palette.accent : Palette.muted)
            .padding(.horizontal, 8)
            .frame(height: 36)
            .background(configuration.isPressed ? Palette.quiet : selected ? Palette.paleBlue : .clear,
                        in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
    }
}

private func cardHeading(_ title: String) -> some View {
    Text(title)
        .font(.system(size: 16, weight: .semibold))
        .accessibilityAddTraits(.isHeader)
}

private func fieldLabel(_ title: String) -> some View {
    Text(title).font(.system(size: 12, weight: .medium)).foregroundStyle(Palette.muted)
}

private extension View {
    func card() -> some View {
        background(Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Palette.line).allowsHitTesting(false))
    }

    func fieldSurface(focused: Bool = false) -> some View {
        background(Palette.field, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7)
                .strokeBorder(focused ? Palette.accent : Palette.line).allowsHitTesting(false))
    }

    func segmentGroup() -> some View {
        padding(3).background(Palette.quiet, in: RoundedRectangle(cornerRadius: 8))
    }
}

private extension Color {
    init(hex value: UInt32) {
        self.init(
            red: Double((value >> 16) & 255) / 255,
            green: Double((value >> 8) & 255) / 255,
            blue: Double(value & 255) / 255
        )
    }
}
