//
//  MetaDataParser.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

struct MetaDataParser {
    
    var artistName: String? {
        return _dict[Identifier.artist] as? String
    }
    
    var song: String? {
        return _dict[Identifier.title] as? String
    }
    
    private var _dict: [AVMetadataIdentifier: AnyObject] = [:]
    
    init(_ items: [AVMetadataItem]) {
        for item in items {
            if let identifier = item.identifier, let value = item.value {
                _dict[identifier] = value
            }
        }
    }
}
