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
        
        private var _playlistOffset: TimeInterval = 0.0
        private var _counter: TimeInterval = 0.0
        
        private(set) var progressTrackObserver: Repeater?
        
        // MARK: - Public methods
        
        func pause() {
            progressTrackObserver?.pause()
        }
        
        func updateTimings(current: MetaData) {
            guard let duration = current.duration else { return }
            
            _playlistOffset = current.playlistStartTime
            _counter = 0.0
            
            _setupProgressObserver(duration)
        }
        
        func startObserveTimings(metadata: MetaData) {
            guard let duration = metadata.duration else { return }
            if metadata.datumTime < metadata.playlistStartTime {
                // TODO: Clarify this scenario
                _playlistOffset = metadata.datumTime + metadata.playlistStartTime
                _counter = metadata.datumTime
            } else {
                _playlistOffset = metadata.datumTime
                _counter = metadata.datumTime - metadata.playlistStartTime
            }
            let length = duration - _counter
            _setupProgressObserver(length)
        }
        
        private func _setupProgressObserver(_ duration: TimeInterval) {
            progressTrackObserver = Repeater(every: 1.0, duration: duration) { [weak self] in
                guard let self = self else { return }
                self._counter += 1.0
                self._playlistOffset += 1.0
                self._delegate?.trackProgress(self._counter, self._playlistOffset)
            }
            progressTrackObserver?.start()
        }
        
        func invalidate() {
            progressTrackObserver?.cancel()
            progressTrackObserver = nil
        }
        
        init(_ delegate: TrackTimimgsDelegate?) {
            _delegate = delegate
        }
        
        deinit {
            invalidate()
        }
    }
}
