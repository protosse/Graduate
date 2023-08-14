import Foundation
import Moya

enum Api {
    case paperList
    case none
}

extension Api: TargetType {
    var baseURL: URL {
        #if targetEnvironment(simulator)
            return URL(string: "http://0.0.0.0:8080/api")!
        #else
            return URL(string: "http://192.168.0.189:8080/api")!
        #endif
    }

    var path: String {
        switch self {
        case .paperList:
            return "paper/list"
        default:
            return ""
        }
    }

    var parameters: [String: Any] {
        let param = [String: Any]()
        return param
    }

    var method: Moya.Method {
        switch self {
        case .paperList:
            return .get
        default:
            return .post
        }
    }

    var sampleData: Data {
        switch self {
        default:
            return "{}".data(using: .utf8)!
        }
    }

    var task: Task {
        switch self {
        case .paperList:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            return nil
        }
    }
}
