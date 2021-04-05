//
//  PlayingItem.swift
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
    let title: String?
    let artistName: String?
    let stationName: String?
    let url: URL?
    
    let duration: TimeInterval?
    let offset: TimeInterval?
    
    var isShowPlayerControls: Bool = false
    var progress: TimeInterval?
    var next: NextAction?
    
    private let _provider: SkipSongProvider = .init()

    init(_ item: Marconi.MetaData, station: Station?) {
        title = item.song ?? "Unknown"
        artistName = item.artist ?? "Unknown"
        stationName = station?.name
        url = item.imageUrl ?? URL(station?.square_logo_large)
        duration = item.duration
        offset = item.offset
        progress = offset
        if case .digit = item {
            isShowPlayerControls = true
        }
        guard let playId = item.playId, let trackId = item.trackId, let stationId = station?.id else { return }
        next = combine(stationId, playId, trackId, with: _provider.skip)
    }
}

extension DisplayItemNode {
    
    mutating func updateProgress(value: TimeInterval) {
        guard let progress = progress else {
            self.progress = value
            return
        }
        self.progress = progress + value
    }
    
    // range [0..1) to display on progress bar
    var startTime: CGFloat {
        guard let duration = duration, let offset = offset else {
            return 0.0
        }
        return CGFloat(offset / duration)
    }
}

extension DisplayItemNode: Equatable {
    static func == (lhs: DisplayItemNode, rhs: DisplayItemNode) -> Bool {
        return lhs.title == rhs.title &&
               lhs.artistName == rhs.artistName &&
               lhs.stationName == rhs.stationName
    }
}
