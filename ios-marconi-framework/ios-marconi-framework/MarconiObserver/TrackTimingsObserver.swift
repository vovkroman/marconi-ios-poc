//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

protocol TrackTimimgsDelegate: class {
    func trackProgress(_ currentItemProgress: TimeInterval, _ streamProgress: TimeInterval)
}

extension Marconi {
    public class TrackTimingsObserver {
        
        private weak var _delegate: TrackTimimgsDelegate?
        private weak var _player: AVPlayer?
        
        private var _playlistOffset: TimeInterval = 0.0
        private var _counter: TimeInterval = 0.0
        private let _interval: TimeInterval
        
        private var _currentProgress: TimeInterval = 0.0
        
        private(set) var progressTrackObserver: Any?
        
        // MARK: - Public methods
        
        func updateTimings(current: MetaData) {
            _playlistOffset = current.playlistStartTime
            _counter = -_currentProgress
            _setupProgressObserver()
        }
        
        func startObserveTimings(metadata: MetaData) {
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
                _counter = metadata.datumTime
            } else {
                _playlistOffset = metadata.datumTime
                _counter = metadata.datumTime - metadata.playlistStartTime
            }
            _setupProgressObserver()
        }
        
        private func _setupProgressObserver() {
            progressTrackObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main){ [weak self] (progress) in
                self?._updateProgress(progress)
            }
        }
        
        private func _updateProgress(_ progress: TimeInterval) {
            _delegate?.trackProgress(_counter + progress, _playlistOffset + progress)
            _currentProgress = progress
        }
        
        func invalidate() {
            _player?.removeTimeObserver(progressTrackObserver)
            progressTrackObserver = nil
        }
        
        init(every interval: TimeInterval, player: AVPlayer?, delegate: TrackTimimgsDelegate?) {
            _player = player
            _delegate = delegate
            _interval = interval
        }
        
        deinit {
            invalidate()
        }
    }
}
