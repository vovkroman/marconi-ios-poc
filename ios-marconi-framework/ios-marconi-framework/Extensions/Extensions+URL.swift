//
//  URL+Query.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 27.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension URL {
    var queryParams: [String: String] {
        var dict: [String: String] = [:]
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                for item in queryItems {
                  dict[item.name] = item.value!
                }
            }
        }
        return dict
    }
    
    func updateQueryParams(key: String, value: String) -> URL {
        var params = queryParams
        params[key] = value
        
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        components.queryItems = params.map{ URLQueryItem(name: $0, value: $1) }
        return components.url!
    }
}
