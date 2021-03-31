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
        case live(artist: String?, song: String?)
        case digit(artist: String?, song: String?, offset: TimeInterval?, duration: TimeInterval?, url: URL?)
        
        public var song: String? {
            switch self {
            case .live(_, let song):
                return song
            case .digit( _, let song, _, _, _):
                return song
            case .none:
                return nil
            }
        }
        
        public var imageUrl: URL? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_, _, _, _, let url):
                return url
            }
        }
        
        public var artist: String? {
            switch self {
            case .live(let artist, _):
                return artist
            case .digit(let artist, _, _, _, _):
                return artist
            case .none:
                return nil
            }
        }
        
        public var duration: TimeInterval? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_ , _, _, let duration, _):
                return duration
            }
        }
        
        public var offset: TimeInterval? {
            switch self {
            case .live, .none:
                return nil
            case .digit(_ , _, let offset, _, _):
                return offset
            }
        }
        
        init(_ parser: Live.DataParser) {
            self = .live(artist: parser.song, song: parser.artist)
        }
        
        init(_ parser: Digit.DataParser) {
            self = .digit(artist: parser.artist,
                          song: parser.song,
                          offset: parser.offset,
                          duration: parser.duration,
                          url: parser.url)
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        switch (lhs, rhs) {
        case (.live(let lArtist, let rArtist), .live(let lSong, let rSong)):
            return lArtist == rArtist && lSong == rSong
        case (.live(_, _), .digit(_, _, _, _, _)), (.digit(_, _, _, _, _), .live(_, _)):
            return false
        case (.digit(let lArtist, let lSong, let lOffset ,_, _ ), .digit(let rArtist, let rSong, let rOffset, _, _)):
            return lArtist == rArtist && lSong == rSong && lOffset == rOffset
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
