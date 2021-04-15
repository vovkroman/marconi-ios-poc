//
//  SkipSongApi.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 05.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

enum Feedback: String {
    case like = "like"
    case dilike = "dislike"
}

struct Song {
    let stationId: Int
    let playId: String
    let trackId: String
}

enum SessionApi {
    case skip(song: Song)
    case preference(song: Song, feedback: Feedback)
}


extension SessionApi: EndPointType {
    var baseURL: URL {
        guard let url = URL("https://smartstreams.radio-stg.com") else {
            fatalError("Failed to load base URL")
        }
        return url
    }
    
    var path: String? {
        switch self {
        case .skip(let song):
            return "session/\(song.playId)/\(song.stationId)/skip"
        case .preference(let song, let feedback):
            return "session/\(song.playId)/\(song.stationId)/feedback/\(feedback)"
        }
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
        switch self {
        case .skip(let song), .preference(let song, _):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["trackId": song.trackId])
        }
    }
}
