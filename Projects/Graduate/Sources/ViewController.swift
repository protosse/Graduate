import MathParser
import PinLayout
import UIKit

class ViewController: BaseViewController {
    private lazy var richTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }()

    private lazy var mathParser = MathParser()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        if let path = Bundle.main.url(forResource: "2022数学一", withExtension: "md"),
           let data = try? Data(contentsOf: path), let text = String(data: data, encoding: .utf8) {
            richTextView.attributedText = mathParser.parse(string: text)
            view.addSubview(richTextView)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        richTextView.pin.all(view.pin.safeArea)
    }
}
