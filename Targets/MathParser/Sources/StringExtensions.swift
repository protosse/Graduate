import Foundation

extension String {
    func subString(withNSRange range: NSRange) -> String {
        return subString(start: range.location, end: range.location + range.length)
    }

    func subString(start: Int, end: Int) -> String {
        #if swift(>=5.0)
            let startIndex = String.Index(utf16Offset: start, in: self)
            let endIndex = String.Index(utf16Offset: end, in: self)
        #else
            let startIndex = String.Index(encodedOffset: start)
            let endIndex = String.Index(encodedOffset: end)
        #endif
        return String(self[startIndex ..< endIndex])
    }
}
