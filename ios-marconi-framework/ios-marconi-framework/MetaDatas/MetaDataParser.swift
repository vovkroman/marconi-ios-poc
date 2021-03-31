//
//  MetaDataParser.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    public enum Live {}
    public enum Digit {}
}

extension Marconi.Digit {
    struct DataParser {
        var artist: String? {
            return _dict[Identifier.songArtist] as? String
        }
        
        var song: String? {
            return _dict[Identifier.songTitle] as? String
        }
        
        var duration: TimeInterval? {
            let value = _dict[Identifier.songDuration]
            return value?.doubleValue
        }
        
        var offset: TimeInterval? {
            let value = _dict[Identifier.datumStartTime]
            return value?.doubleValue
        }
        
        var url: URL? {
            guard let value = _dict[Identifier.songAlbumArtURL] as? String else {
                return nil
            }
            return URL(string: value)
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
}

extension Marconi.Live {
    struct DataParser {
        var artist: String? {
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
}
