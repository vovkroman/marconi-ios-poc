//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

protocol TrackTimimgsDelegate: class {
    func trackProgressing(_ currentItemInterval: TimeInterval, _ streamProgress: TimeInterval)
    func trackDidFinish()
}

extension Marconi {
    public class TrackTimingsObserver {
        
        private let _interval: TimeInterval
        private weak var _delegate: TrackTimimgsDelegate?
        
        private(set) var playlistOffset: TimeInterval = 0.0
        private(set) var counter: TimeInterval = 0.0
        
        private var _progressObserver: Any?
        private(set) var scheduler: Scheduler?
        
        private weak var _player: AVPlayer?
        
        private func _trackIsProgressing() {
            counter += _interval
            playlistOffset += _interval
            _delegate?.trackProgressing(counter.rounded(), playlistOffset.rounded())
        }
        
        // MARK: - Public methods
        
        func updateTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            
            playlistOffset = metadata.playlistStartTime
            counter = 0.0
            
            _setupProgressObserver(duration + metadata.playlistStartTime)
            _setupScheduler(with: duration)
        }
        
        func startObserveTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                playlistOffset = metadata.datumTime + metadata.playlistStartTime
                counter = metadata.datumTime
            } else {
                playlistOffset = metadata.datumTime
                counter = metadata.datumTime - metadata.playlistStartTime
            }
            let length = duration - counter
            _setupProgressObserver(length)
            _setupScheduler(with: length)
        }
        
        private func _setupProgressObserver(_ duration: TimeInterval) {
            _progressObserver = _player?.addBoundaryTimeObserver(duration: duration,
                                                                 interval: _interval,
                                                                 queue: .main,
                                                                 body: _trackIsProgressing)
        }
        
        private func _setupScheduler(with interval: TimeInterval) {
            scheduler = Scheduler(){ [weak self] in
                self?._delegate?.trackDidFinish()
            }
            scheduler?.start(at: Date().addingTimeInterval(interval))
            print("scheduler has been setup")
        }
        
        func invalidate() {
            _player?.removeTimeObserver(_progressObserver)
            _progressObserver = nil
            print("Timings has been invalidated")
            scheduler?.cancel()
            scheduler = nil
        }
        
        init(every interval: TimeInterval, _ player: AVPlayer?, delegate: TrackTimimgsDelegate?) {
            _interval = interval
            _player = player
            _delegate = delegate
        }
        
        deinit {
            invalidate()
        }
    }
}
