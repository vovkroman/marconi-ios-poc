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
        private let _endBlock: EndBlock?
        
        private let _interval: TimeInterval
        private var _playlistOffset: TimeInterval
        private var _counter: TimeInterval
        
        private(set) var _progressObserver: Any?
        private(set) var _endTrackObserver: Any?
        
        private weak var _player: AVPlayer?
        
        private func _trackIsProgressing() {
            _counter += _interval
            _progressBlock?(_counter.rounded(), (_playlistOffset + _counter).rounded())
        }
        
        private func _trackEnded() {
            _endBlock?()
        }
        
        // MARK: - Public methods
        
        func updateTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            _playlistOffset = metadata.playlistStartTime
            _counter = 0.0
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration,
                                                                 interval: 1.0,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
            _endTrackObserver = _player?.addBoundaryTimeObserver(duration: duration,
                                                                 interval: duration,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
        }
        
        func startObserveTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            if metadata.playlistOffset < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.playlistOffset + metadata.playlistStartTime
                _counter = metadata.playlistOffset
            } else {
                _playlistOffset = metadata.playlistOffset
                _counter = metadata.playlistOffset - metadata.playlistStartTime
            }
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration - _counter,
                                                                 interval: 1.0,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
            _endTrackObserver = _player?.addBoundaryTimeObserver(duration: duration - _counter,
                                                                 interval: duration - _counter,
                                                                 queue: .main,
                                                                 body: _trackEnded)
        }
        
        func invalidate() {
            _player?.removeTimeObserver(_progressObserver)
            _progressObserver = nil
        }
        
        init(every interval: TimeInterval, player: AVPlayer?, progress: ProgressBlock? = nil, end: EndBlock? = nil) {
            _interval = interval
            _progressBlock = progress
            _counter = 0.0
            _playlistOffset = 0.0
            _player = player
            _endBlock = end
        }
        
        deinit {
            invalidate()
        }
    }
}
