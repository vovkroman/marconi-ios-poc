//
//  Extensions+AVPlayer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    public var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension AVPlayer {
    
    public func seek(to time: TimeInterval, completionHandler: @escaping (Bool) -> Void) {
        let currentAssetTimeScale = currentItem?.asset.duration.timescale ?? 1
        seek(to: CMTime(seconds: time, preferredTimescale: currentAssetTimeScale),
             toleranceBefore: CMTime.zero,
             toleranceAfter: CMTime.zero,
             completionHandler: completionHandler)
    }
    
    public func seek(to time: TimeInterval) {
        seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
}


