//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    public class TimingsObserver {
        
        typealias ProgressBlock = (_ currentItem: TimeInterval, _ stream: TimeInterval) -> ()
        typealias EndBlock = () -> ()
        
        private let _progressBlock: ProgressBlock?
        
        private let _interval: TimeInterval
        
        private(set) var playlistOffset: TimeInterval = 0.0
        private(set) var counter: TimeInterval = 0.0
        
        private var _progressObserver: Any?
        private weak var _player: AVPlayer?
        
        private func _trackIsProgressing() {
            counter += _interval
            playlistOffset += _interval
            _progressBlock?(counter.rounded(), playlistOffset.rounded())
        }
        
        // MARK: - Public methods
        
        func updateTimings(metadata: MetaData, for player: AVPlayer?) {
            guard let duration = metadata.duration else { return }
            _player = player
            playlistOffset = metadata.playlistStartTime
            counter = 0.0
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration + metadata.playlistStartTime,
                                                                 interval: _interval,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
        }
        
        func startObserveTimings(metadata: MetaData, for player: AVPlayer?) {
            guard let duration = metadata.duration else { return }
            _player = player
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                playlistOffset = metadata.datumTime + metadata.playlistStartTime
                counter = metadata.datumTime
            } else {
                playlistOffset = metadata.datumTime
                counter = metadata.datumTime - metadata.playlistStartTime
            }
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration - counter,
                                                                 interval: _interval,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
        }
        
        func invalidate() {
            _player?.removeTimeObserver(_progressObserver)
            _progressObserver = nil
        }
        
        init(every interval: TimeInterval, progress: ProgressBlock? = nil) {
            _interval = interval
            _progressBlock = progress
        }
        
        deinit {
            invalidate()
        }
    }
}
