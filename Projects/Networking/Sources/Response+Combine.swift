import Combine
import Foundation
import Moya
import SwiftyJSON

extension Response {
    func mapApiResponse() throws -> ApiResponse {
        let json = JSON(data)
        return try json.mapApiResponse()
    }

    func mapSwiftyJSON() -> JSON {
        return JSON(data)
    }
}

extension JSON {
    func mapApiResponse() throws -> ApiResponse {
        let codeStr = self["code"].stringValue
        guard !codeStr.isEmpty else {
            throw NetError.net
        }
        let code = Int(codeStr) ?? 0
        let msg = self["msg"].stringValue

        guard code == 0 || code == 200 else {
            throw NetError.tip(code, msg)
        }

        let data = self["data"]
        return ApiResponse(code: code, msg: msg, data: data)
    }
}

extension AnyPublisher where Output == Response {
    func mapApiResponse() -> AnyPublisher<ApiResponse, NetError> {
        return tryMap({ try $0.mapApiResponse() })
            .mapError({ NetError($0) })
            .eraseToAnyPublisher()
    }

    func mapSwiftyJSON() -> AnyPublisher<JSON, NetError> {
        return map({ $0.mapSwiftyJSON() })
            .mapError({ NetError($0) })
            .eraseToAnyPublisher()
    }
}
