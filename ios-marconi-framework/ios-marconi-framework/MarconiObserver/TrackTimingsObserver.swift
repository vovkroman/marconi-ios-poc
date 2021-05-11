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
        private let _interval: TimeInterval
                
        private(set) var progressTrackObserver: Any?
        private var _currentItem: MetaData = .none
        
        // MARK: - Public methods
        
        func updateTimings(current: MetaData) {
            _currentItem = current
            _setupProgressObserver()
        }
        
        func startObserveTimings(metadata: MetaData) {
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
            } else {
                _playlistOffset = metadata.datumTime
            }
            _currentItem = metadata
            _setupProgressObserver()
        }
        
        private func _setupProgressObserver() {
            progressTrackObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main){ [weak self] (progress) in
                self?._updateProgress(progress)
            }
        }
        
        private func _updateProgress(_ progress: TimeInterval) {
            let currentProgress = _playlistOffset + progress
            _delegate?.trackProgress(currentProgress - _currentItem.playlistStartTime, currentProgress)
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
