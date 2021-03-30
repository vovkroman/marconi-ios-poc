//
//  MarconiMetaDatas.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public enum Progress {
        case unknown
        case progress(progress: TimeInterval)
    }
    
    public struct MetaData {
        // Data for Live
        public let artistName: String?
        public let song: String?
        
        // Data for Digit
        public var offset: TimeInterval?
        public var duration: TimeInterval?
        
        init(_ items: [AVMetadataItem]) {
            let _parser = MetaDataParser(items)
            self.artistName = _parser.artistName ?? "Unknown"
            self.song = _parser.song ?? "Unknown"
            self.duration = _parser.duration
            self.offset = _parser.offset
        }
    }
}

extension Marconi.Progress: Equatable {
    public static func == (lhs: Marconi.Progress, rhs: Marconi.Progress) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, unknown):
            return true
        case (.progress(let lhs), .progress(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        return lhs.artistName == rhs.artistName && lhs.song == rhs.song
    }
}
