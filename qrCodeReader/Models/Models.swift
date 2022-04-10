import Foundation

struct Answer: Codable {

    var valid: Bool

}

enum ReadState {

    case success
    case invalid
    case invalidQr
    case networkRequest
    case empty
    
}
