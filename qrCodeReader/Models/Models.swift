//
//  Models.swift
//  qrCodeReader
//
//  Created by Alexey on 13.02.2022.
//

import Foundation


struct Answer: Codable {

    var valid: Bool

}

enum ReadState {

    case success
    case invalid
    case invalidQr
    case empty
    
}
