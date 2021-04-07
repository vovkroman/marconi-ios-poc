import Foundation

enum StationApi {
    case getStation(Id: Int)
}

extension StationApi: EndPointType {
    
    var baseURL: URL {
        guard let url = NetworkConfig.baseURL else {
            fatalError("Failed to load base URL")
        }
        return url
    }
    
    var path: String? {
        switch self {
        case .getStation(let id):
            return "stations/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }

    var task: HTTPTask {
        switch self {
        case .getStation(_):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["feature_flags": "false",
                                                      "utterances": "false",
                                                      "show_hidden": "false",
                                                      "modules": "false"])
        }
    }
    
    var authenticationHeaders: [String : String]? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var cachePolicy: NSURLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
}
