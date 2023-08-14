import AttributedString
import Combine
import Foundation
import MathParser

class HomeViewModel: ObservableObject {
    @Published var content = ASAttributedString(string: "")

    private var parser: MathParser!

    init() {
        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path),
           let text = String(data: data, encoding: .utf8) {
            parser = MathParser(style: .default, text: text)
            parser.content.assign(to: &$content)
        }
    }
}
