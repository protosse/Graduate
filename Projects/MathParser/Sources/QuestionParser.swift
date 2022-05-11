import AttributedString
import UIKit

public class QuestionParser: MathParserProtocal {
    public enum QuestionType: String, CaseIterable {
        case choice

        public var regex: NSRegularExpression {
            let pattern = #"\{(\#(self))\s+(.*)\}(.+?)\{\/\1\}"#
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

            guard let data = try? JSONEncoder().encode(dic),
                  let model = try? JSONDecoder().decode(T.self, from: data) else {
                return nil
            }
            return model
        }
    }

    public init() {}

    public func parseText(_ text: ASAttributedString?) -> ASAttributedString? {
        guard let text = text, text.length > 0 else {
            return nil
        }

//        let str = text.string
//
//        var cutLength = 0
//        QuestionType.allCases.forEach { type in
//            type.regex.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
//                if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
//                    var range = result.range
//                    range.location -= cutLength
//
//                    let param = str.subString(withNSRange: result.range(at: 2))
//                    let value = str.subString(withNSRange: result.range(at: 3))
//
//                    switch type {
//                    case .choice:
//                        if let entity: ChoiceEntity = type.transfer(param, value: value) {
//                            let label = UILabel()
//                            label.textColor = .red
//                            label.text = entity.value
//                            label.sizeToFit()
//                            let attachment = ViewAttachment.view(label)
//                            let attr = NSAttributedString(attachment: attachment)
//                            text.replaceCharacters(in: range, with: attr)
//                            cutLength += range.length - 1
//                        }
//                    }
//                }
//            }
//        }

        return text
    }
}

public struct ChoiceEntity: Codable {
    public let id: Int
    public var value: String
}
