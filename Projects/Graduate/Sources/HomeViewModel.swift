import AttributedString
import Combine
import Foundation
import MathParser

class HomeViewModel: ObservableObject {
    @Published var content = ASAttributedString(string: "")

    private let parser = MathParser()

    init() {
        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path),
           let text = String(data: data, encoding: .utf8),
           let attr = parser.parse(text) {
            content = attr
        }
    }
}
