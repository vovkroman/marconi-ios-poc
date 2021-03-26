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
        public let artistName: String
        public let song: String
        
        init?(_ items: [AVMetadataItem]) {
            var dict: [AVMetadataIdentifier: AnyObject] = [:]
            for item in items {
                if let identifier = item.identifier, let value = item.value {
                    dict[identifier] = value
                }
            }
            guard let artistName = dict[Marconi.indentifierArtistName] as? String, let song = dict[Marconi.indentifierTitle] as? String else {
                return nil
            }
            self.artistName = artistName
            self.song = song
        }
    }
}

extension Marconi.MetaData: Equatable {
    public static func == (lhs: Marconi.MetaData, rhs: Marconi.MetaData) -> Bool {
        return lhs.artistName == rhs.artistName && lhs.song == rhs.song
    }
}
