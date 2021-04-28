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
        
        private weak var _delegate: TrackTimimgsDelegate?
        
        private(set) var playlistOffset: TimeInterval = 0.0
        private(set) var counter: TimeInterval = 0.0
        
        private var _progressTrackObserver: Repeater?
        private var _nextTrackObserver: Scheduler?
        
        // MARK: - Public methods
        
        func pause() {
            _progressTrackObserver?.pause()
            _nextTrackObserver?.pause()
        }
        
        func updateTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            
            playlistOffset = metadata.playlistStartTime
            counter = 0.0
            
            _setupProgressObserver(duration)
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
            _progressTrackObserver = Repeater(every: 1.0, duration: duration) { [weak self] in
                guard let self = self else { return }
                self.counter += 1.0
                self.playlistOffset += 1.0
                self._delegate?.trackProgressing(self.counter.rounded(), self.playlistOffset.rounded())
            }
            _progressTrackObserver?.start()
        }
        
        private func _setupScheduler(with interval: TimeInterval) {
            _nextTrackObserver = Scheduler(){ [weak self] in
                guard let self = self else { return }
                self._delegate?.trackDidFinish()
            }
            _nextTrackObserver?.start(at: Date().addingTimeInterval(interval))
        }
        
        func invalidate() {
            _progressTrackObserver?.cancel()
            _nextTrackObserver?.cancel()
            _nextTrackObserver = nil
            _progressTrackObserver = nil
        }
        
        init(_ delegate: TrackTimimgsDelegate?) {
            _delegate = delegate
        }
        
        deinit {
            invalidate()
        }
    }
}
