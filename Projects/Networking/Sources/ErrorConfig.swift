import Foundation

enum NetError: Error {
    case none
    /// code and msg
    case tip(Int, String)

    case map
    case net

    var code: Int {
        switch self {
        case let .tip(c, _):
            return c
        default:
            return -1
        }
    }
}

extension NetError {
    init(_ error: Error) {
        if let e = error as? NetError {
            self = e
        } else {
            self = NetError.tip(-1, error.localizedDescription)
        }
    }
}

extension NetError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .tip(_, string):
            return string
        case .net:
            return "网络错误"
        default:
            return ""
        }
    }
}
