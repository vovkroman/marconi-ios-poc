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
    func trackHasBeenChanged()
}

extension Marconi {
    public class TrackTimingsObserver {
        
        private weak var _delegate: TrackTimimgsDelegate?
        private weak var _player: AVPlayer?
        
        private var _playlistOffset: TimeInterval = 0.0
        private let _interval: TimeInterval
        private var _queue: MetaDataQueue
                
        private(set) var progressTrackObserver: Any?
        private(set) var currentMetaItem: MetaData = .none {
            didSet {
                if oldValue != currentMetaItem {
                    _setupProgressObserver()
                }
            }
        }
        
        // MARK: - Public methods
        
        func updateTimings(current: MetaData) {
            _playlistOffset -= 0.1 // it's been added for rounded value
            currentMetaItem = current
        }
        
        func startObserveTimings(metadata: MetaData) {
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
            } else {
                _playlistOffset = metadata.datumTime
            }
            currentMetaItem = metadata
        }
        
        private func _setupProgressObserver() {
            progressTrackObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main){ [weak self] (progress) in
                self?._updateProgress(progress)
            }
        }
        
        private func _updateProgress(_ progress: TimeInterval) {
            let currentProgress = _playlistOffset + progress
            let playlistStartTime = currentMetaItem.playlistStartTime
            if let nextItem = _queue.next() {
                if !(playlistStartTime..<nextItem.playlistStartTime ~= currentProgress) {
                    _delegate?.trackHasBeenChanged()
                    return
                }
            }
            if let duartion = currentMetaItem.duration {
                let upperBound = playlistStartTime + duartion
                if !(playlistStartTime...upperBound ~= currentProgress) {
                    _delegate?.trackHasBeenChanged()
                    return
                }
            }
            _delegate?.trackProgress(currentProgress - currentMetaItem.playlistStartTime, currentProgress)
        }
        
        func invalidate() {
            _player?.removeTimeObserver(progressTrackObserver)
            progressTrackObserver = nil
        }
        
        init(every interval: TimeInterval, player: AVPlayer?, queue: MetaDataQueue, delegate: TrackTimimgsDelegate?) {
            _player = player
            _queue = queue
            _delegate = delegate
            _interval = interval
        }
        
        deinit {
            invalidate()
        }
    }
}
