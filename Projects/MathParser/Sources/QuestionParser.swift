import UIKit

public class QuestionParser: TextParser {
    public enum QuestionType: String, CaseIterable {
        case choice

        public var regex: NSRegularExpression {
            let pattern = #"<(\#(self)\$*(.*)>(.+?)<\/\1>"#
            return try! NSRegularExpression(pattern: pattern, options: [])
        }

        public func attributes<T: QuestionProtocol>(_ text: String, value: String) -> T? {
            let dic = text.components(separatedBy: " ").map {
                $0.components(separatedBy: "=")
            }.reduce([String: String]()) { partialResult, group in
                var partialResult = partialResult
                if group.count == 2 {
                    let key = group[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = group[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    partialResult[key] = value
                }
                return partialResult
            }

            guard let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                  var model = try? JSONDecoder().decode(T.self, from: data) else {
                return nil
            }
            model.value = value
            return model
        }
    }

    public init() {
        NSTextAttachment.registerViewProviderClass(ChoiceNSTextAttachmentViewProvider.self, forFileType: ChoiceNSTextAttachmentViewProvider.type)
    }

    public func parseText(_ text: NSMutableAttributedString?) -> Bool {
        guard let text = text, text.length > 0 else {
            return false
        }

        let str = text.string

        var cutLength = 0
        QuestionType.allCases.forEach { type in
            type.regex.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
                if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
                    var range = result.range
                    range.location -= cutLength
                    let textColor = text.foregroundColor(at: range.location)
                    let font = text.font(at: range.location)

                    let attr = str.subString(withNSRange: result.range(at: 2))
                    let value = str.subString(withNSRange: result.range(at: 3))

                    switch type {
                    case .choice:
                        let entity: ChoiceEntity = type.attributes(attr, value: value)
                    }

                    if let image = getImage(from: label) {
                        let icon = NSTextAttachment(image: image)
                        icon.bounds = CGRect(
                            x: 0,
                            y: (font.capHeight - image.size.height).rounded() / 2,
                            width: image.size.width,
                            height: image.size.height
                        )
                        let iconString = NSAttributedString(attachment: icon)
                        text.replaceCharacters(in: range, with: iconString)
                        cutLength += range.length - 1
                    }
                }
            }
        }

        return true
    }
}

public protocol QuestionProtocol: Codable {
    var value: String { get set }

    static func decode(_ tags: String, value: String) -> QuestionProtocol
}

extension QuestionProtocol {
    static func decode(_: String, value _: String) -> QuestionProtocol {}
}

public struct ChoiceEntity: QuestionProtocol {
    public let id: String
    public var value: String
}

public class ChoiceNSTextAttachmentViewProvider: NSTextAttachmentViewProvider {
    public static let type = "choice"

    override public func loadView() {
        super.loadView()
    }
}
