import Foundation

public protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var authenticationHeaders: [String: String]? { get }
    //plz get acquated https://stackoverflow.com/questions/12381991/ios-cache-policy if using NSURLRequestUseProtocolCachePolicy
    var cachePolicy: NSURLRequest.CachePolicy { get }
    var headers: HTTPHeaders? { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
}

