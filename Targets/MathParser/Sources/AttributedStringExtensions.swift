import AttributedString
import UIKit

extension NSAttributedString {
    func foregroundColor(at location: Int, defaultValue: UIColor = .black) -> UIColor {
        attribute(.foregroundColor, at: location, effectiveRange: nil) as? UIColor ?? defaultValue
    }

    func font(at location: Int, defaultValue: UIFont = .systemFont(ofSize: 15)) -> UIFont {
        attribute(.font, at: location, effectiveRange: nil) as? UIFont ?? defaultValue
    }
}

extension ASAttributedString {
    mutating func replace(in range: NSRange, with attr: ASAttributedString) {
        let origin = NSMutableAttributedString(attributedString: value)
        origin.replaceCharacters(in: range, with: attr.value)
        self = ASAttributedString(origin)
    }
}
