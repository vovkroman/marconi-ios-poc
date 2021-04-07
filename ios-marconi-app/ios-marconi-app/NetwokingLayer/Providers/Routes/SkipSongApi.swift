//
//  SkipSongApi.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 05.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct SkipApi {
    let stationId: Int
    let playId: String
    let trackId: String
}

extension SkipApi: EndPointType {
    var baseURL: URL {
        guard let url = URL("https://smartstreams.radio-stg.com") else {
            fatalError("Failed to load base URL")
        }
        return url
    }
    
    var path: String? {
        return "session/\(playId)/\(stationId)/skip"
    }
    
    var authenticationHeaders: [String : String]? {
        nil
    }
    
    var cachePolicy: NSURLRequest.CachePolicy {
       return .reloadIgnoringCacheData
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        return .requestParameters(bodyParameters: nil,
                                  bodyEncoding: .urlEncoding,
                                  urlParameters: ["trackId": trackId])
    }
}
