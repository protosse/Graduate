import Combine
import CombineMoya
import Foundation
import Logger
import Moya
import SwiftyJSON

private var requestTimeOut: Double = 15
private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = requestTimeOut
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

class NetworkManager {
    static let share = NetworkManager()

    /// 一些没必要打印的接口
    var ignoreLogApi: [Api] = []

    private lazy var loggerPlugin = NetworkLoggerPlugin(configuration: .init(output: { [unowned self] targetType, items in
        guard !items.isEmpty, !ignoreLogApi.contains(where: { $0.path == targetType.path }) else { return }

        // response
        if items.count == 2 {
            var url = targetType.baseURL.absoluteString
            if !url.hasSuffix("/") {
                url += "/"
            }
            log.verbose("\(url + targetType.path) \(items[1])")
        } else if items.count == 3 {
            let method = items[2][(items[2].lastIndex(of: ":") ?? items[2].startIndex) ..< items[2].endIndex]
            if let regex = try? NSRegularExpression(pattern: "\\{[\\w\\W]*\\}") {
                let matches = regex.matches(in: items[1], range: NSRange(location: 0, length: items[1].count))
                if let matchRange = matches.first?.range, let substringRange = Range(matchRange, in: items[1]) {
                    let str = String(items[1][substringRange])
                    log.verbose(String(format: "%@ %@ %@", items[0], String(method), str))
                }
            }
        }
    }, logOptions: [.requestMethod, .requestBody, .successResponseBody, .errorResponseBody]))

    #if DEBUG
        lazy var provider = MoyaProvider<Api>(requestClosure: requestClosure, plugins: [loggerPlugin])
    #else
        lazy var provider = MoyaProvider<Api>(requestClosure: requestClosure)
    #endif

    class func request(_ api: Api) -> AnyPublisher<ApiResponse, NetError> {
        return NetworkManager.share.provider.requestPublisher(api).mapApiResponse()
    }
}
