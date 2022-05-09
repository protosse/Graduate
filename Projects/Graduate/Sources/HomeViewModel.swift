import Combine
import Foundation
import MathParser

class HomeViewModel: ObservableObject {
    @Published var content = NSAttributedString()

    private lazy var mathParser = MathParser()
    private lazy var questionParser = QuestionParser()

    private lazy var parserSequence: [TextParser] = [
        mathParser, questionParser,
    ]

    init() {
        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path), let text = String(data: data, encoding: .utf8) {
            let attr = NSMutableAttributedString(string: text)
            parserSequence.forEach {
                $0.parseText(attr)
            }
            content = attr
        }
    }
}
