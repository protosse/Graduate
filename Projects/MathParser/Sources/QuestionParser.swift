import Foundation

public class QuestionParser: TextParser {
    public enum QuestionType {
        case choice
        case fill
        case answer

        var regex: NSRegularExpression {
            let pattern: String
            switch self {
            case .choice:
                pattern = ""
            case .fill:
                pattern = ""
            case .answer:
                pattern = ""
            }
            return try! NSRegularExpression(pattern: pattern, options: [])
        }
    }

    public init() {
    }

    public func parseText(_ text: NSMutableAttributedString?) -> Bool {
        guard let text = text, text.length > 0 else {
            return false
        }
        return true
    }
}
