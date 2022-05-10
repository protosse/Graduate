import UIKit

extension NSAttributedString {
    func foregroundColor(at location: Int, defaultValue: UIColor = .black) -> UIColor {
        attribute(.foregroundColor, at: location, effectiveRange: nil) as? UIColor ?? defaultValue
    }

    func font(at location: Int, defaultValue: UIFont = .systemFont(ofSize: 15)) -> UIFont {
        attribute(.font, at: location, effectiveRange: nil) as? UIFont ?? defaultValue
    }
}
