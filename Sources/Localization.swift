import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case simplifiedChinese = "zh-Hans"
    case english = "en"
    case japanese = "ja"

    var name: String {
        switch self {
        case .simplifiedChinese: "简体中文"
        case .english: "English"
        case .japanese: "日本語"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

// Keep the app's message separate from system and downloader diagnostics.
struct LocalizedMessage: Codable, Sendable, ExpressibleByStringLiteral {
    let key: String
    let arguments: [String]
    let detail: String?
    let exitCode: Int32?

    init(_ key: String, arguments: [String] = [], detail: String? = nil, exitCode: Int32? = nil) {
        self.key = key
        self.arguments = arguments
        self.detail = detail
        self.exitCode = exitCode
    }

    init(stringLiteral value: String) {
        self.init(value)
    }

    init(error: Error) {
        if let error = error as? WorkbenchError {
            self = error.message
        } else {
            self.init("", detail: error.localizedDescription)
        }
    }

    enum CodingKeys: String, CodingKey { case key, arguments, detail, exitCode }

    init(from decoder: Decoder) throws {
        if let legacy = try? decoder.singleValueContainer().decode(String.self) {
            let parts = legacy.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
            self.init(parts.first.map(String.init) ?? "", detail: parts.dropFirst().first.map(String.init))
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(try container.decode(String.self, forKey: .key),
                  arguments: try container.decodeIfPresent([String].self, forKey: .arguments) ?? [],
                  detail: try container.decodeIfPresent(String.self, forKey: .detail),
                  exitCode: try container.decodeIfPresent(Int32.self, forKey: .exitCode))
    }
}

struct WebbieStrings {
    let language: AppLanguage
    private let bundle: Bundle?

    init(_ language: AppLanguage, resources: Bundle = .main) {
        self.language = language
        bundle = resources.url(forResource: language.rawValue, withExtension: "lproj").flatMap(Bundle.init(url:))
    }

    func callAsFunction(_ key: String, _ arguments: String...) -> String {
        self(LocalizedMessage(key, arguments: arguments))
    }

    func callAsFunction(_ message: LocalizedMessage) -> String {
        let template = message.key.isEmpty ? "" :
            bundle?.localizedString(forKey: message.key, value: message.key, table: nil) ?? message.key
        let title = message.arguments.isEmpty ? template :
            String(format: template, locale: language.locale, arguments: message.arguments.map { $0 as CVarArg })
        let detail = message.detail ?? message.exitCode.map { self("退出码 %@", String($0)) }
        return [title, detail].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "\n")
    }
}
