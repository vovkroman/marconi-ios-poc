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
        
        private var _isFinished: Bool = true
                
        private(set) var progressTrackObserver: Any?
        private(set) var currentMetaItem: MetaData = .none
        
        // MARK: - Public methods
        
        func updateTimings(current: MetaData) {
            currentMetaItem = current
            _setupProgressObserver()
        }
        
        func startObserveTimings(metadata: MetaData) {
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
            } else {
                _playlistOffset = metadata.datumTime
            }
            currentMetaItem = metadata
            _setupProgressObserver()
        }
        
        private func _setupProgressObserver() {
            if progressTrackObserver == nil {
                progressTrackObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main){ [weak self] (progress) in
                    self?._updateProgress(progress)
                }
            }
        }
        
        private func _updateProgress(_ progress: TimeInterval) {
            let currentProgress = _playlistOffset + progress
            let playlistStartTime = currentMetaItem.playlistStartTime
            if let nextItem = _queue.next() {
                if playlistStartTime < currentProgress && currentProgress >= nextItem.playlistStartTime && !_isFinished {
                    print("TRACK HAS BEEN CHANGED")
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            }
            if let duartion = currentMetaItem.duration {
                let upperBound = playlistStartTime + duartion
                if playlistStartTime < currentProgress &&  currentProgress > upperBound && !_isFinished {
                    print("TRACK HAS BEEN CHANGED")
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            }
            _isFinished = false
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
