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

extension AVPlayer {
    
    public func addLinearPeriodicTimeObserver(every seconds: TimeInterval,
                                              queue: DispatchQueue,
                                              using block: @escaping (TimeInterval) -> Void) -> Any {
        let interval = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        return addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
            block(time.seconds)
        }
    }
    
    public func removeTimeObserver(_ observer: Any?) {
        if let observer = observer {
            removeTimeObserver(observer)
        }
    }
}

extension AVPlayer {
    func stop() {
        guard let currentItem = currentItem else { return }
        currentItem.asset.cancelLoading()
        currentItem.cancelPendingSeeks()
        replaceCurrentItem(with: nil)
    }
}



