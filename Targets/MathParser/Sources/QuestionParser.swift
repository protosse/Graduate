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
    }

    public class ChoiceConfig {
        var circleColor: UIColor = .yellow.withAlphaComponent(0.2)
        var circleHighlightColor: UIColor = .red.withAlphaComponent(0.1)
        var circleCorrectColor: UIColor = .green.withAlphaComponent(0.5)
        var circleErrorColor: UIColor = .red.withAlphaComponent(0.5)

        var fontName: String = "GillSans"
        var textColor: UIColor = .black
        var textHighlightColor: UIColor = .black
        var textCorrectColor: UIColor = .black
        var textErrorColor: UIColor = .black
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

    public func parseText(_ text: ASAttributedString) -> ASAttributedString {
        var text = text

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
                        if let entity = ChoiceEntity.from(param: param, value: value) {
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
        let textColor: UIColor
        switch type {
        case .normal:
            circleColor = choiceConfig.circleColor
            textColor = choiceConfig.textColor
        case .highlight:
            circleColor = choiceConfig.circleHighlightColor
            textColor = choiceConfig.textHighlightColor
        case .correct:
            circleColor = choiceConfig.circleCorrectColor
            textColor = choiceConfig.textCorrectColor
        case .error:
            circleColor = choiceConfig.circleErrorColor
            textColor = choiceConfig.textErrorColor
        }

        let im = circleAroundChar(
            entity.value,
            circleColor: circleColor,
            textColor: textColor,
            font: UIFont(name: choiceConfig.fontName, size: font.pointSize)!
        )

        let attr = ASAttributedString(.image(im, .original(.center))) { [weak self] in
            self?.delegate?.questionParserChoiceDidClick(entity, range: attrRange)
        }

        text.replace(in: range, with: attr)
    }

    private func circleAroundChar(
        _ text: String,
        circleColor: UIColor,
        textColor: UIColor,
        diameter: CGFloat? = nil,
        font: UIFont
    ) -> UIImage {
        let diameter = diameter ?? (font.pointSize + 10)
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        let s = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: textColor, .paragraphStyle: p])
        let r = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return r.image { con in
            circleColor.setFill()
            con.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            s.draw(in: CGRect(x: 0, y: diameter / 2 - font.lineHeight / 2, width: diameter, height: diameter))
        }
    }
}

public struct ChoiceEntity: Codable {
    public var id: String
    public var value: String
    public var correct: Bool

    static func from(param: String, value: String) -> ChoiceEntity? {
        var dic: [String: Any] = param.components(separatedBy: " ").map {
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
        dic["correct"] = dic["correct"] != nil

        guard let data = try? JSONSerialization.data(withJSONObject: dic),
              let model = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        return model
    }
}
