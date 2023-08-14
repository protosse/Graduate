import AttributedString
import Combine
import Down
import Foundation

public protocol MathParserProtocol {
    @discardableResult
    func parseText(_ text: ASAttributedString) -> ASAttributedString
}

public class MathParser {
    public enum Style: String {
        case `default`
        case default_dark

        public var css: String? {
            if let path = Bundle.module.path(forResource: "\(self)", ofType: "css"),
               let content = try? String(contentsOfFile: path) {
                return content
            }
            return nil
        }
    }

    public var style: Style

    public lazy var latexParser = LatexParser()
    public lazy var questionParser = QuestionParser()

    public lazy var parser: [MathParserProtocol] = [latexParser, questionParser]

    public var originText: String
    public var content = CurrentValueSubject<ASAttributedString, Never>("")

    public init(style: Style = .default, text: String) {
        self.style = style
        originText = text
        content.send(parse(text))
        questionParser.delegate = self
    }

    func parse(_ text: String) -> ASAttributedString {
        originText = text
        guard let markDown = parse(markDown: text) else {
            return ""
        }

        var attr = ASAttributedString(markDown)

        parser.forEach {
            attr = $0.parseText(attr)
        }

        return attr
    }

    func parse(markDown: String) -> NSAttributedString? {
        let down = Down(markdownString: markDown)
        guard let re = try? down.toAttributedString(.normalize, stylesheet: style.css) else {
            return nil
        }

        return re
    }
}

extension MathParser: QuestionParserDelegate {
    public func questionParserChoiceDidClick(_ entity: ChoiceItemEntity, range: NSRange) {
        let value = questionParser.setChoice(text: content.value, range: range, type: .highlight, entity: entity)
        content.send(value)
    }
}
