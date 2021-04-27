//
//  MarconiMetaDatas.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public struct LiveItem {
        let id: String?
        let artist: String?
        let song: String?
        let image: URL?
    }
    
    public struct DigitaItem {
        let trackId: String?
        let playId: String?
        let artist: String?
        let stationId: String?
        let song: String?
        let datumTime: TimeInterval
        let datumStartTime: TimeInterval
        let duration: TimeInterval?
        let playlistStartTime: TimeInterval
        let url: URL?
        let skips: Int
        let isSkippable: Bool
    }
    
    public enum MetaData {
        case none
        case live(LiveItem)
        case digit(DigitaItem, Date)
        
        public var song: String? {
            switch self {
            case .live(let item):
                return item.song
            case .digit(let item, _):
                return item.song
            case .none:
                return nil
            }
        }
        
        public var imageUrl: URL? {
            switch self {
            case .live(let item):
                return item.image
            case .digit(let item, _):
                return item.url
            case .none:
                return nil
            }
        }
        
        public var artist: String? {
            switch self {
            case .live(let item):
                return item.artist
            case .digit(let item, _):
                return item.artist
            case .none:
                return nil
            }
        }
        
        public var duration: TimeInterval? {
            switch self {
            case .live, .none:
                return nil
            case .digit(let item, _):
                return item.duration
            }
        }
        
        public var stationId: String? {
            switch self {
            case .live, .none:
                return nil
            case .digit(let item, _):
                return item.stationId
            }
        }
        
        public var datumTime: TimeInterval {
            switch self {
            case .live, .none:
                return 0.0
            case .digit(let item, _):
                return item.datumTime
            }
        }
        
        public var trackId: String? {
            switch self {
            case .live, .none:
                return nil
            case .digit(let item, _):
                return item.trackId
            }
        }
        
        public var playId: String? {
            switch self {
            case .live, .none:
                return nil
            case .digit(let item, _):
                return item.playId
            }
        }
        
        public var datumStartTime: TimeInterval {
            switch self {
            case .live, .none:
                return 0.0
            case .digit(let item, _):
                return item.datumStartTime
            }
        }
        
        public var playlistStartTime: TimeInterval {
            switch self {
            case .live, .none:
                return 0.0
            case .digit(let item, _):
                return item.playlistStartTime
            }
        }
        
        public var isSkippbale: Bool {
            switch self {
            case .digit(let item, _):
                return item.isSkippable && item.skips > 0
            default:
                return false
            }
        }
        
        public var startTrackDate: Date? {
            switch self {
            case .digit(_, let startDate):
                return startDate
            default:
                return nil
            }
        }
        
        init(_ parser: Live.DataParser) {
            self = .live(.init(id: parser.Id,
                         artist: parser.song,
                         song: parser.artist,
                         image: parser.image))
        }
        
        init(_ parser: Digit.DataParser, startDate: Date) {
            self = .digit(.init(trackId: parser.trackId,
                          playId: parser.playId,
                          artist: parser.artist,
                          stationId: parser.stationId,
                          song: parser.song,
                          datumTime: parser.datumTime ?? 0.0,
                          datumStartTime: parser.datumStartTime ?? 0.0,
                          duration: parser.duration,
                          playlistStartTime: parser.playlistStartTime ?? 0.0,
                          url: parser.url,
                          skips: parser.skips ?? 0,
                          isSkippable: parser.isSkippable ?? false),
                          startDate)
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        switch (lhs, rhs) {
        case (.live(let lhs), .live(let rhs)):
            return lhs.id == rhs.id &&
                lhs.artist == rhs.artist &&
                lhs.song == rhs.song &&
                lhs.image == rhs.image
        case (.live, .digit), (.digit, .live):
            return false
        case (.digit(let lhs, let lDate), .digit(let rhs, let rDate)):
            return lhs.trackId == rhs.trackId &&
                    lhs.playId == rhs.playId &&
                    lhs.artist == rhs.artist &&
                    lhs.stationId == rhs.stationId &&
                    lhs.song == rhs.song &&
                    lhs.datumTime == rhs.datumTime &&
                    lhs.skips == rhs.skips &&
                    lhs.isSkippable == rhs.isSkippable &&
                    lhs.duration == rhs.duration &&
                    lhs.playlistStartTime == rhs.playlistStartTime &&
                    lhs.url == rhs.url &&
                    lDate == rDate
        case (.none, .none):
            return true
        case (_, .none):
            // if new item is none, not to update UI
            return true
        case (.none, _):
            return false
        }
    }
}

extension Marconi.MetaData: CustomStringConvertible {
    public var description: String {
        switch self {
        case .digit(let item, let startDate):
            return """
            Metadata for Digital Station has came with following list of properties:
            
            lsdr/X-SONG-ID: \(String(describing: item.trackId)),
            lsdr/X-SESSION-PLAY-ID: \(String(describing: item.playId)),
            lsdr/X-SONG-ARTIST: \(String(describing: item.artist)),
            lsdr/X-SONG-STATION-ID: \(String(describing: item.stationId)),
            lsdr/X-SONG-TITLE: \(String(describing: item.song)),
            lsdr/X-DATUM-TIME: \(String(describing: item.datumTime)),
            lsdr/X-SONG-DURATION: \(String(describing: item.duration)),
            lsdr/X-PLAYLIST-TRACK-START-TIME: \(String(describing: item.playlistStartTime)),
            lsdr/X-SONG-ALBUM-ART-URL: \(String(describing: item.url)),
            lsdr/X-SESSION-SKIPS: \(item.skips),
            lsdr/X-SONG-IS-SKIPPABLE: \(item.isSkippable),
            START-DATE: \(startDate)
            
            """
        case .live(let item):
            return """
            Metadata for Live Station has came with following list of properties:
            
            lsdr/X-TITLE: \(String(describing: item.song)),
            lsdr/X-ARTIST: \(String(describing: item.artist)),
            lsdr/X-PLAY-ID: \(String(describing: item.id)),
            lsdr/X-IMAGE: \(String(describing: item.image))
            
            """
        case .none:
            return "Metadata haven't came"
        }
    }
}
