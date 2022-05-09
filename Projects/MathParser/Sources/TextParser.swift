import Foundation

public protocol TextParser {
    @discardableResult
    func parseText(_ text: NSMutableAttributedString?) -> Bool
}
