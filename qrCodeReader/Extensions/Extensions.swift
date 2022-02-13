//
//  Extensions.swift
//  qrCodeReader
//
//  Created by Alexey on 13.02.2022.
//

import Foundation

extension Array {

    subscript(safe index: Int) -> Element? {
        guard index < endIndex, index >= startIndex else { return nil}
        return self[index]
    }

}

