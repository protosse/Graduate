import AttributedString
import UIKit

public protocol QuestionParserDelegate: AnyObject {
    func questionParserChoiceDidClick(_ entity: ChoiceItemEntity, range: NSRange)
}

public class QuestionParser: MathParserProtocol {
    weak var delegate: QuestionParserDelegate?

    public var choiceConfig = ChoiceConfig()
    public var choiceEntitys = [String: ChoiceEntity]()

    public init() {}

    public func parseText(_ text: ASAttributedString) -> ASAttributedString {
        var text = text

        let str = text.value.string

        var cutLength = 0
        var choiceItems = [ChoiceItemEntity]()
        QuestionType.allCases.forEach { type in
            type.regex.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
                if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
                    var range = result.range
                    range.location -= cutLength

                    let (param, value) = paramAndValue(from: str, checkingResult: result)
                    switch type {
                    case .choice:
                        if let entity = ChoiceItemEntity.from(param: param, value: value) {
                            text = setChoice(text: text, range: range, type: .normal, entity: entity)
                            cutLength += range.length - 1
                            choiceItems.append(entity)
                        }
                    }
                }
            }
        }

        choiceEntitys = choiceItems.reduce(into: [String: ChoiceEntity]()) { partialResult, item in
            let entity = partialResult[item.id] ?? ChoiceEntity(id: item.id)
            var items = entity.items
            items.append(item)
            var coreect = entity.correct
            if item.correct {
                coreect.append(item)
            }
            partialResult[item.id] = entity
        }

        return text
    }

    func paramAndValue(from string: String, checkingResult: NSTextCheckingResult) -> (String, String) {
        let temp = [2, 3].map { string.subString(withNSRange: checkingResult.range(at: $0)) }
        return (temp[0], temp[1])
    }

    public func setChoice(text: ASAttributedString, range: NSRange, type: ChoiceType, entity: ChoiceItemEntity) -> ASAttributedString {
        var text = text
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
        return text
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
