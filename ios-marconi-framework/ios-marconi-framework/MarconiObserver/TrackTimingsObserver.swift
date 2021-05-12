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
        
        func startObserveTimings(metadata: MetaData) {
            switch metadata {
            case .digit(let item, _):
                if item.datumTime < item.playlistStartTime {
                    #warning("most likely this scenrio will be never exected")
                    _playlistOffset = item.datumTime + item.playlistStartTime
                } else {
                    _playlistOffset = item.datumTime
                }
            case .live(_, _), .none:
                break
            }
            currentMetaItem = metadata
            _setupProgressObserver()
        }
        
        func updateTimings(current: MetaData) {
            currentMetaItem = current
            _setupProgressObserver()
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
        
        
        // MARK: - Private methods
        
        private func _setupProgressObserver() {
            if progressTrackObserver == nil {
                progressTrackObserver = _player?.addLinearPeriodicTimeObserver(every: _interval,
                                                                               queue: .main){ [weak self] (progress) in
                    self?._updateProgress(progress)
                }
            }
        }
        
        private func _process(item: DigitaItem, progress: TimeInterval) {
            let currentProgress = _playlistOffset + progress
            let playlistStartTime = item.playlistStartTime
            if let nextItem = _queue.next() {
                if playlistStartTime < currentProgress && currentProgress >= nextItem.playlistStartTime && !_isFinished {
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("Track has been changed, AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            } else if let duration = item.duration {
                let upperBound = playlistStartTime + duration
                if playlistStartTime < currentProgress &&  currentProgress > upperBound && !_isFinished {
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("Track has been changed, AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            }
            _isFinished = false
            _delegate?.trackProgress(currentProgress - playlistStartTime, currentProgress)
        }
        
        private func _process(item: LiveItem, startDate: Date) {
            guard _queue.count > 0 else { return }
            if let nextItem = _queue.next() {
                if nextItem.startTrackDate! <= Date() && !_isFinished {
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("Track has been changed, AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            } else if let duration = item.duration {
                if startDate.addingTimeInterval(duration) < Date() && !_isFinished {
                    _isFinished = true
                    _delegate?.trackHasBeenChanged()
                    print("Track has been changed, AMOUNT OF ITEMS in QUEUE: \(_queue.count)")
                    return
                }
            }
            _isFinished = false
        }
        
        private func _updateProgress(_ progress: TimeInterval) {
            switch currentMetaItem {
            case .digit(let item, _):
                _process(item: item, progress: progress)
                case .live(let item, let startDate):
                _process(item: item, startDate: startDate)
            case .none:
                break
            }
        }
        
        deinit {
            invalidate()
        }
    }
}
