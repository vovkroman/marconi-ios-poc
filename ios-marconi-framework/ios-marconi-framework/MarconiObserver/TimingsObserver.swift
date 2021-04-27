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
        private var _playlistOffset: TimeInterval = 0.0
        private var _counter: TimeInterval = 0.0
        
        private var _progressObserver: Any?
        private weak var _player: AVPlayer?
        
        private func _trackIsProgressing() {
            _counter += _interval
            _playlistOffset += _interval
            _progressBlock?(_counter.rounded(), _playlistOffset.rounded())
        }
        
        // MARK: - Public methods
        
        func updateTimings(metadata: MetaData, for player: AVPlayer?) {
            guard let duration = metadata.duration else { return }
            _player = player
            _playlistOffset = metadata.playlistStartTime
            _counter = 0.0
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration + metadata.playlistStartTime,
                                                                 interval: 1.0,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
        }
        
        func startObserveTimings(metadata: MetaData, for player: AVPlayer?) {
            guard let duration = metadata.duration else { return }
            _player = player
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
                _counter = metadata.datumTime
            } else {
                _playlistOffset = metadata.datumTime
                _counter = metadata.datumTime - metadata.playlistStartTime
            }
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration - _counter,
                                                                 interval: 1.0,
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
