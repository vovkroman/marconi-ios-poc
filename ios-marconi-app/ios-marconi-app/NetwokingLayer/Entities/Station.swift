//
//  Station.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct Station {
    
    struct Stream: Decodable {
        enum Category: String, Decodable {
            case mp3, m3u8, aac
        }
        let type: Category
        let url: String
    }
    
    let id: Int
    let name: String
    
    let streams: [Stream]?
    let square_logo_large: String?
}

extension Station: Decodable {
    private enum CodingKeys: String, CodingKey {
        case station
        case id
        case name
        case logo = "square_logo_large"
        case stream = "station_stream"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let station = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .station)
        
        let id = try station.decode(Int.self, forKey: .id)
        let name = try station.decode(String.self, forKey: .name)
        
        let square_logo_large = try? station.decode(String.self, forKey: .logo)
        let streams = try? station.decode([Stream].self, forKey: .stream)
        
        self.init(id: id, name: name, streams: streams, square_logo_large: square_logo_large)
    }
}
