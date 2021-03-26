//
//  Errors.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 24.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation


// Networking Errors
public enum DataError: Error {
    case httpResponseFailed
}

public enum ResponseError: Error {
    case `default`
    case authenticationFailed
    case badRequest
    case outdated
}

// Station Errors
extension Live {
    enum ErrorType: Error {
        case noHls(stationName: String)
        case error(error: Error)
    }
}

extension Live.ErrorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .noHls(let stationName):
            return "\(stationName) doesn't contain HLS stream"
        case .error(error: let error):
            return error.localizedDescription
        }
    }
}
