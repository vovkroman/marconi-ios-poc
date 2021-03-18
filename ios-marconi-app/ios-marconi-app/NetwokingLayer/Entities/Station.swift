//
//  Station.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct Station {
    
    struct Stream: Codable {
        let type: String?
        let url: String?
    }
    
    let stream: [Stream]?
    
    let id: Int
    let square_logo_large: String?
}

extension Station: Codable {
    private enum CodingKeys: String, CodingKey {
        case station
        case id
        case square_logo_large = "square_logo_large"
        case station_stream = "station_stream"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let station = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .station)
        let id = try station.decode(Int.self, forKey: .id)
        let square_logo_large = try? station.decode(String.self, forKey: .square_logo_large)
        let streams = try? station.decode([Stream].self, forKey: .station_stream)
        self.init(stream: streams, id: id, square_logo_large: square_logo_large)
    }
    
    func encode(to encoder: Encoder) throws {}
}
