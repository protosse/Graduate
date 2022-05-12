import AttributedString
import UIKit

public protocol QuestionParserDelegate: AnyObject {
    func questionParserDidClick(_ entity: ChoiceEntity, range: NSRange)
}

public class QuestionParser: MathParserProtocal {
    public enum QuestionType: String, CaseIterable {
        case choice

        public var regex: NSRegularExpression {
            let pattern = #"\{(\#(self))\s+(.*)\}(.*?)\{\/\1\}"#
            return try! NSRegularExpression(pattern: pattern, options: [])
        }

        public func transfer<T: Codable>(_ param: String, value: String) -> T? {
            var dic = param.components(separatedBy: " ").map {
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

            dic["value"] = value

            guard let data = try? JSONSerialization.data(withJSONObject: dic),
                  let model = try? JSONDecoder().decode(T.self, from: data) else {
                return nil
            }
            return model
        }
    }

    weak var delegate: QuestionParserDelegate?

    public init() {}

    public func parseText(_ text: ASAttributedString?) -> ASAttributedString? {
        guard var text = text, text.length > 0 else {
            return nil
        }

        let str = text.value.string

        var cutLength = 0
        QuestionType.allCases.forEach { type in
            type.regex.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
                if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
                    var range = result.range
                    range.location -= cutLength

                    let param = str.subString(withNSRange: result.range(at: 2))
                    let value = str.subString(withNSRange: result.range(at: 3))
                    let attributes = text.value.attributes(at: range.location, effectiveRange: nil)

                    switch type {
                    case .choice:
                        if let entity: ChoiceEntity = type.transfer(param, value: value) {
                            let placeHolder = "choice"
                            let attrRange = NSRange(location: range.location, length: placeHolder.count)
                            let attr = ASAttributedString("\(placeHolder)", .custom(attributes), .action { [weak self] in
                                print("choice click")
                                self?.delegate?.questionParserDidClick(entity, range: attrRange)
                            })
                            text.replace(in: range, with: attr)
                            cutLength += range.length - attrRange.length
                        }
                    }
                }
            }
        }

        return text
    }
}

public struct ChoiceEntity: Codable {
    public let id: String
    public var value: String
}
