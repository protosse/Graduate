import AttributedString
import UIKit

public protocol QuestionParserDelegate: AnyObject {
    func questionParserChoiceDidClick(_ entity: ChoiceEntity, range: NSRange)
}

public class QuestionParser: MathParserProtocol {
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

    public class ChoiceConfig {
        var circleColor: UIColor = .yellow
        var circleHighlightColor: UIColor = .red.withAlphaComponent(0.1)
        var circleCorrectColor: UIColor = .green.withAlphaComponent(0.5)
        var circleErrorColor: UIColor = .red.withAlphaComponent(0.5)

        var fontName: String = "GillSans"
        var digitColor: UIColor = .black
        var digitHighlightColor: UIColor = .black
        var digiCorrectColor: UIColor = .black
        var digiErrorColor: UIColor = .black
    }

    public enum ChoiceType {
        case normal
        case highlight
        case correct
        case error
    }

    weak var delegate: QuestionParserDelegate?

    public var choiceConfig = ChoiceConfig()

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

                    let (param, value) = paramAndValue(from: str, checkingResult: result)

                    switch type {
                    case .choice:
                        if let entity: ChoiceEntity = type.transfer(param, value: value) {
                            setChoice(text: &text, range: range, type: .normal, entity: entity)
                            cutLength += range.length - 1
                        }
                    }
                }
            }
        }

        return text
    }

    func paramAndValue(from string: String, checkingResult: NSTextCheckingResult) -> (String, String) {
        let temp = [2, 3].map { string.subString(withNSRange: checkingResult.range(at: $0)) }
        return (temp[0], temp[1])
    }

    public func setChoice(text: inout ASAttributedString, range: NSRange, type: ChoiceType, entity: ChoiceEntity) {
        let font = text.value.font(at: range.location)
        let attrRange = NSRange(location: range.location, length: 1)

        let circleColor: UIColor
        let digitColor: UIColor
        switch type {
        case .normal:
            circleColor = choiceConfig.circleColor
            digitColor = choiceConfig.digitColor
        case .highlight:
            circleColor = choiceConfig.circleHighlightColor
            digitColor = choiceConfig.digitHighlightColor
        case .correct:
            circleColor = choiceConfig.circleCorrectColor
            digitColor = choiceConfig.digiCorrectColor
        case .error:
            circleColor = choiceConfig.circleErrorColor
            digitColor = choiceConfig.digiErrorColor
        }

        let im = circleAroundDigit(
            entity.id,
            circleColor: circleColor,
            digitColor: digitColor,
            font: UIFont(name: choiceConfig.fontName, size: font.pointSize)!
        )

        let attr = ASAttributedString(.image(im, .original(.center))) { [weak self] in
            self?.delegate?.questionParserChoiceDidClick(entity, range: attrRange)
        }

        text.replace(in: range, with: attr)
    }

    private func circleAroundDigit(
        _ num: String,
        circleColor: UIColor,
        digitColor: UIColor,
        diameter: CGFloat? = nil,
        font: UIFont
    ) -> UIImage {
        let diameter = diameter ?? (font.pointSize + 10)
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        let s = NSAttributedString(string: num, attributes: [.font: font, .foregroundColor: digitColor, .paragraphStyle: p])
        let r = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return r.image { con in
            circleColor.setFill()
            con.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            s.draw(in: CGRect(x: 0, y: diameter / 2 - font.lineHeight / 2, width: diameter, height: diameter))
        }
    }
}

public struct ChoiceEntity: Codable {
    public let id: String
    public var value: String
}
