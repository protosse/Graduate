import AttributedString
import Down
import Foundation

public protocol MathParserProtocal {
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

    lazy var latexParser = LatexParser()
    lazy var questionParser = QuestionParser()

    lazy var parser: [MathParserProtocal] = [latexParser, questionParser]

    public init(style: Style = .default) {
        self.style = style
    }

    public func parse(_ text: String?) -> ASAttributedString? {
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
