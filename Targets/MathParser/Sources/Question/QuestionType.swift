import UIKit

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
