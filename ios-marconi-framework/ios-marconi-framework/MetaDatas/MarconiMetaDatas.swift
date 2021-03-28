//
//  MarconiMetaDatas.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    public struct MetaData {
        public let artistName: String?
        public let song: String?
        public var offset: TimeInterval? = 0.0
        public var duration: TimeInterval?
        
        init(_ items: [AVMetadataItem]) {
            let _parser = MetaDataParser(items)
            self.artistName = _parser.artistName
            self.song = _parser.song
            self.duration = _parser.duration
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        return lhs.artistName == rhs.artistName && lhs.song == rhs.song
    }
}
