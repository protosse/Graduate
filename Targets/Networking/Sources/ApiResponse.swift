import SwiftyJSON

class ApiResponse {
    var code: Int
    var msg: String
    var data: JSON

    init(code: Int, msg: String, data: JSON) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}
