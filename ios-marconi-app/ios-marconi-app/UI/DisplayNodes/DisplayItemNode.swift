//
//  DisplayItemNode.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 30.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import ios_marconi_framework
import UIKit
import FutureKit

typealias NextAction = () -> Future<SkipEntity>

struct DisplayItemNode {
    
    private let _provider: SkipSongProvider = .init()
    private let _metaData: Marconi.MetaData
    private let _station: Station
    
    private(set) var _progress: TimeInterval?
    
    init?(_ metaData: Marconi.MetaData, station: Station?) {
        guard let station = station else { return nil }
        _metaData = metaData
        _station = station
    }
}

extension DisplayItemNode {
    mutating func updateProgress(value: TimeInterval) {
        guard let offset = _metaData.offset else {
            self._progress = value
            return
        }
        self._progress = offset + value
    }
}

extension DisplayItemNode: Equatable {
    static func == (lhs: DisplayItemNode, rhs: DisplayItemNode) -> Bool {
        return lhs._metaData == rhs._metaData
    }
}

extension DisplayItemNode {
    var title: String {
        return _metaData.song ?? "Unknown"
    }
    
    var artistName: String {
        return _metaData.artist ?? "Unknown"
    }
    
    var stationName: String? {
        return _station.name
    }
    
    var type: String? {
        switch _metaData {
        case .digit:
            return "Type: Track"
        case .live:
            return "Type: Live"
        case .none:
            return "Type: Unknown"
        }
    }
    
    var playId: String? {
        return _metaData.playId
    }
    
    var url: URL? {
        return _metaData.imageUrl ?? URL(_station.square_logo_large)
    }
    
    var isSkipSupportable: Bool {
        if case .digit = _metaData {
            return _metaData.isSkippbale
        }
        return false
    }
    
    var isShowPlayerControls: Bool {
        if case .digit = _metaData {
            return true
        }
        return false
    }
    
    var next: NextAction? {
        guard let playId = _metaData.playId, let trackId = _metaData.trackId else {
            return nil
        }
        return combine(_station.id, playId, trackId, with: _provider.skip)
    }
    
    var maxValue: Float {
        return Float(_metaData.duration ?? 0.0)
    }
    
    var offset: Float {
        return Float(_metaData.offset ?? 0.0)
    }
}
