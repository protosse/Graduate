import AttributedString
import Combine
import Foundation
import MathParser

class HomeViewModel: ObservableObject {
    @Published var content = ASAttributedString(string: "")

    private var parser: MathParser!

    init() {
        parser = MathParser(style: .default, questionParserDelegate: self)
        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path),
           let text = String(data: data, encoding: .utf8),
           let attr = parser.parse(text) {
            content = attr
        }
    }
}

extension HomeViewModel: QuestionParserDelegate {
    func questionParserChoiceDidClick(_ entity: ChoiceEntity, range: NSRange) {
        parser.questionParser.setChoice(text: &content, range: range, type: .highlight, entity: entity)
    }
}
