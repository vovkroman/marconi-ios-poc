//
//  ImageAPI.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct ImageApi {
    let url: URL
}

extension ImageApi: EndPointType {
    
    var baseURL: URL {
        return url
    }
    
    var path: String? { return nil }
    
    var httpMethod: HTTPMethod {
        return .get
    }

    var task: HTTPTask {
        return .request
    }
    
    var authenticationHeaders: [String : String]? { return nil }
    
    var headers: HTTPHeaders? { return nil }
    
    var cachePolicy: NSURLRequest.CachePolicy {
        return .returnCacheDataElseLoad
    }
}
