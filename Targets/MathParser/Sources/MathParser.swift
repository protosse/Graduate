import AttributedString
import Down
import Foundation

public protocol MathParserProtocol {
    @discardableResult
    func parseText(_ text: ASAttributedString?) -> ASAttributedString?
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

    public var originText: String?

    public init(style: Style = .default, questionParserDelegate: QuestionParserDelegate? = nil) {
        self.style = style
        questionParser.delegate = questionParserDelegate
    }

    public func parse(_ text: String?) -> ASAttributedString? {
        originText = text
        guard let markDown = parse(markDown: text) else {
            return nil
        }

        var attr: ASAttributedString? = ASAttributedString(markDown)

        parser.forEach {
            attr = $0.parseText(attr)
        }

        return attr
    }

    func parse(markDown: String?) -> NSAttributedString? {
        guard let markDown = markDown else {
            return nil
        }

        let down = Down(markdownString: markDown)
        guard let re = try? down.toAttributedString(.normalize, stylesheet: style.css) else {
            return nil
        }

        return re
    }
}
