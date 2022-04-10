import Foundation

extension Array {

    subscript(safe index: Int) -> Element? {
        guard index < endIndex, index >= startIndex else { return nil}
        return self[index]
    }

}

