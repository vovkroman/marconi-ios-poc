//
//  MarconiMetaDatas.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public enum MetaData {
        case none
        case live(id: String?,
                   artist: String?,
                    song: String?)
        case digit(trackId: String?,
                    playId: String?,
                    artist: String?,
                    song: String?,
                    offset: TimeInterval?,
                    duration: TimeInterval?,
                    url: URL?,
                    skips: Int,
                    isSkippable: Bool)
        
        public var song: String? {
            switch self {
            case .live(_, _, let song):
                return song
            case .digit(_, _, _, let song, _, _, _, _, _):
                return song
            case .none:
                return nil
            }
        }
        
        public var imageUrl: URL? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_, _, _, _, _, _, let url, _, _):
                return url
            }
        }
        
        public var artist: String? {
            switch self {
            case .live(_, let artist, _):
                return artist
            case .digit(_, _, let artist, _, _, _, _, _, _):
                return artist
            case .none:
                return nil
            }
        }
        
        public var duration: TimeInterval? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_, _, _, _, _, let duration, _, _, _):
                return duration
            }
        }
        
        public var offset: TimeInterval? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_, _ ,_ ,_, let offset, _, _, _, _):
                return offset
            }
        }
        
        public var trackId: String? {
            switch self {
            case .live, .none:
                return nil
            case .digit(let trackId, _, _, _, _, _, _, _, _):
                return trackId
            }
        }
        
        public var playId: String? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_, let playId, _, _, _, _, _, _, _):
                return playId
            }
        }
        
        public var isSkippbale: Bool {
            switch self {
            case .digit(_, _, _, _, _, _, _, let skips, let isSkippable):
                return isSkippable && skips > 0
            default:
                return false
            }
        }
        
        init(_ parser: Live.DataParser) {
            self = .live(id: parser.Id, artist: parser.song, song: parser.artist)
        }
        
        init(_ parser: Digit.DataParser) {
            self = .digit(trackId: parser.trackId,
                          playId: parser.playId,
                          artist: parser.artist,
                          song: parser.song,
                          offset: parser.offset,
                          duration: parser.duration,
                          url: parser.url,
                          skips: parser.skips ?? 0,
                          isSkippable: parser.isSkippable ?? false)
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        switch (lhs, rhs) {
        case (.live(let lId, let lArtist, let rArtist), .live(let rId, let lSong, let rSong)):
            return lId == rId &&
                    lArtist == rArtist &&
                    lSong == rSong
        case (.live(_,_, _), .digit(_, _, _, _, _, _, _, _, _)), (.digit(_ ,_ , _, _, _, _, _, _, _), .live(_ ,_ ,_ )):
            return false
        case (.digit(let lTrackId, let lPlayId, let lArtist, let lSong, let lOffset ,_, _, let lSkips, let lisSkippable),
              .digit(let rTrackId, let rPlayId,  let rArtist, let rSong, let rOffset, _, _, let rSkips, let risSkippable)):
            return lPlayId == rPlayId &&
                    lTrackId == rTrackId &&
                    lArtist == rArtist &&
                    lSong == rSong &&
                    lOffset == rOffset &&
                    lSkips == rSkips &&
                    lisSkippable == risSkippable
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
