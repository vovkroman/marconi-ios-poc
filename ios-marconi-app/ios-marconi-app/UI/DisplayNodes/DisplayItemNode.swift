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

// Plz notice, DisplayItemNode knows nothing about the current progress
struct DisplayItemNode {
    
    private let _provider: SongProvider = .init()
    private let _metaData: Marconi.MetaData
    private let _station: Station
    private let _isPlaying: Bool
    private let _isNextTrack: Bool
        
    init?(_ metaData: Marconi.MetaData, station: Station?, isPlaying: Bool, isNextTrack: Bool) {
        guard let station = station else { return nil }
        _metaData = metaData
        _station = station
        _isPlaying = isPlaying
        _isNextTrack = isNextTrack
    }
}

extension DisplayItemNode: Equatable {
    static func == (lhs: DisplayItemNode, rhs: DisplayItemNode) -> Bool {
        return lhs._metaData == rhs._metaData
    }
}

extension DisplayItemNode {
    
    var isPlaying: Bool {
        return _isPlaying
    }
    
    var title: String {
        return _metaData.song.valueOrDefault("Unknown")
    }
    
    var artistName: String {
        return _metaData.artist.valueOrDefault("Unknown")
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
    
    var skip: NextAction? {
        guard let playId = _metaData.playId, let trackId = _metaData.trackId else {
            return nil
        }
        return combine(_station.id, playId, trackId, with: _provider.skip)
    }
    
    var maxValue: TimeInterval {
        return _metaData.duration ?? 0.0
    }
    
    var playlistOffset: TimeInterval {
        if _isNextTrack {
            return 0.0
        }
        let playlistStartTime = _metaData.playlistStartTime ?? 0.0
        return _metaData.datumTime - playlistStartTime
    }
    
    var playId: String? {
        return _metaData.playId
    }
}

// MARK: - To make like/dislike
extension DisplayItemNode {
    func leaveFeedback(_ type: Feedback) -> Future<PreferenceEntity>? {
        guard let playId = _metaData.playId, let trackId = _metaData.trackId else {
            return nil
        }
        
        return _provider.feedback(stationId: _station.id,
                           playId: playId,
                           trackId: trackId,
                           preference: type)
    }
}

// MARK: - Cancel all active requests, including (skip/feedback)
extension DisplayItemNode {
    func cancelRequests() {
        _provider.cancel()
    }
}
