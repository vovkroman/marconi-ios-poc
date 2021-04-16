//
//  PreferenceEntity.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 15.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct PreferenceEntity {
    let status: Int
    let message: String?
    let track: String?
    let napsterPlaylistId: String?
    let preference: String?
    let data: String?
}

extension PreferenceEntity: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
        case message
        case track
        case napsterPlaylistId
        case preference
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Int.self, forKey: .status)
        let message = try? container.decode(String.self, forKey: .message)
        let track = try? container.decode(String.self, forKey: .track)
        let napsterPlaylistId = try? container.decode(String.self, forKey: .napsterPlaylistId)
        let preference = try? container.decode(String.self, forKey: .preference)
        let data = try? container.decode(String.self, forKey: .data)
        self.init(status: status,
                  message: message,
                  track: track,
                  napsterPlaylistId: napsterPlaylistId,
                  preference: preference,
                  data: data)
    }
}

extension PreferenceEntity: CustomStringConvertible {
    var description: String {
        return """
        
        Feedback has been left with list of data:
        
        'status': \(status),
        'message': \(String(describing: message)),
        'track': \(String(describing: track)),
        'napsterPlaylistId': \(String(describing: napsterPlaylistId)),
        'preference': \(String(describing: preference)),
        
        'data': \(String(describing: data)),
        """
    }
}
