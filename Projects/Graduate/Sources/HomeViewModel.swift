import Combine
import Foundation
import MathParser

class HomeViewModel: ObservableObject {
    @Published var content = NSAttributedString()

    private lazy var mathParser = MathParser()

    init() {
        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path), let text = String(data: data, encoding: .utf8),
           let attributedText = mathParser.parse(string: text) {
            content = attributedText
        }
    }
}
