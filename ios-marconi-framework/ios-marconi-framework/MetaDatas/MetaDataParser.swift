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
        
        var trackId: String? {
            return _dict[Identifier.songID] as? String
        }
        
        var playId: String? {
            return _dict[Identifier.sessionPlayID] as? String
        }
        
        var stationId: String? {
            return _dict[Identifier.stationID] as? String
        }
        
        var artist: String? {
            return _dict[Identifier.songArtist] as? String
        }
        
        var song: String? {
            return _dict[Identifier.songTitle] as? String
        }
        
        var skips: Int? {
            let value = _dict[Identifier.skips] as? String
            return value.flatMap(Int.init)
        }
        
        var isSkippable: Bool? {
            let value = _dict[Identifier.skips] as? NSString
            return value?.boolValue
        }
        
        var duration: TimeInterval? {
            let value = _dict[Identifier.songDuration]
            return value?.doubleValue
        }
        
        var playlistOffset: TimeInterval? {
            let value = _dict[Identifier.datumTime]
            return value?.doubleValue
        }
        
        var playlistStartTime: TimeInterval? {
            let value = _dict[Identifier.playlistTrackStartTime]
            return value?.doubleValue
        }
        
        var songID: String? {
            return _dict[Identifier.songID] as? String
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
        
        var Id: String? {
            return _dict[Identifier.playID] as? String
        }
        
        var song: String? {
            return _dict[Identifier.title] as? String
        }
        
        var image: URL? {
            guard let value = _dict[Identifier.image] as? String else {
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
