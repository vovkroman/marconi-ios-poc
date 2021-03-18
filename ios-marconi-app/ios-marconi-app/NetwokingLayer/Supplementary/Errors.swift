import Foundation

public enum DataError: Error {
    case httpResponseFailed
}

public enum ResponseError: Error {
    case `default`
    case authenticationFailed
    case badRequest
    case outdated
}
