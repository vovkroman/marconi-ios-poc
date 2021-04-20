//
//  MarconiObserver.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class PlayerObserver: NSObject, AVPlayerItemMetadataCollectorPushDelegate {
        
        private(set) var _stationType: StationType = .live
        
        private var _playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
        private var _playbackBufferEmptyObserver: NSKeyValueObservation?
        private var _playbackBufferFullObserver: NSKeyValueObservation?
        private var _tracksObserver: NSKeyValueObservation?
        
        private lazy var _timerObsrever: TimingsObserver? = { [weak self] in
            guard let self = self else { return nil }
            return .init(every: 1.0, player: self._player) { (itemProgress, streamProgress) in
                self._streamProgress = streamProgress
                self._stateMachine.transition(with: .progressDidChanged(progress: itemProgress))
            }
        }()
        
        private weak var _player: AVPlayer?
        private(set) var _streamProgress: TimeInterval?
        
        private(set) var _currentMetaItem: MetaData = .none {
            didSet {
                if oldValue != _currentMetaItem {
                    if case .live = _stationType {
                        // update UI on new meta has came for live
                        _stateMachine.transition(with: .trackWillStartPlaying(_currentMetaItem))
                    }
                }
            }
        }
        
        private(set) var _stateMachine: StateMachine = .init()
        private var _state: StateMachine.State {
            return _stateMachine.state
        }
        
        private func _observeBuffering(_ playerItem: AVPlayerItem) {
            _stateMachine.transition(with: .bufferingStarted(playerItem))
            _playbackBufferEmptyObserver = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self](playerItem, _) in
                self?._stateMachine.transition(with: .bufferingStarted(playerItem))
            }
            
            _playbackLikelyToKeepUpKeyPathObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            }
            
            _playbackBufferFullObserver = playerItem.observe(\.isPlaybackBufferFull, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            }
        }
        
        private func _trackChangeObserver(_ playerItem: AVPlayerItem) {
            if case .digit = _stationType {
                _tracksObserver = playerItem.observe(\.tracks, options: [.new]) { [weak self](playerItem, _) in
                    let tracks = playerItem.tracks
                    guard let metadata = self?._currentMetaItem, !tracks.isEmpty else { return }
                    if playerItem.status == .readyToPlay {
                        
                        // will be triggered only when track has been changed
                        self?._stateMachine.transition(with: .trackHasBeenChanged(metadata))
                    }
                }
            }
        }
        
        public func startObserveProgress() {
            if case .digit = _stationType {
                _timerObsrever?.invalidate()
                var isContinuePlaying = false
                if case .continuePlaying = _state {
                    isContinuePlaying = true
                }
                _timerObsrever?.startObserving(metadata: _currentMetaItem,
                                               isContinuePlaying: isContinuePlaying)
            }
        }
        
        private func _observeStatus(_ playerItem: AVPlayerItem) {
            switch playerItem.status {
            case .readyToPlay:
                if playerItem.errorLog() != nil {
                    // when stream fails with error
                    _stateMachine.transition(with: .catchTheError(playerItem.error))
                    return
                }
                _stateMachine.transition(with: .bufferingEnded(_currentMetaItem))
            case .failed:
                _stateMachine.transition(with: .catchTheError(playerItem.error))
            default:
                break
            }
        }
        
        private func _fetchMetaData(_ playerItem: AVPlayerItem) {
            let metadataCollector = AVPlayerItemMetadataCollector()
            metadataCollector.setDelegate(self, queue: .main)
            playerItem.add(metadataCollector)
        }
        
        // Public methods
        
        deinit {
            stopMonitoring()
        }
        
        public func setPlayer(_ player: AVPlayer) {
            _player = player
        }
        
        public func startMonitoring(_ playerItem: AVPlayerItem?, stationType: StationType) {
            _currentMetaItem = .none
            guard let newPlayingItem = playerItem else {
                return
            }
            _stationType = stationType
            _fetchMetaData(newPlayingItem)
            _observeBuffering(newPlayingItem)
            _trackChangeObserver(newPlayingItem)
        }
        
        public func stopMonitoring() {
            _player?.pause()
            _timerObsrever?.invalidate()
            _playbackLikelyToKeepUpKeyPathObserver?.invalidate()
            _playbackBufferEmptyObserver?.invalidate()
            _playbackBufferFullObserver?.invalidate()
            _tracksObserver?.invalidate()
            _tracksObserver = nil
            _playbackBufferEmptyObserver = nil
            _playbackLikelyToKeepUpKeyPathObserver = nil
            _playbackBufferFullObserver = nil
        }
        
        public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                      didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                      indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
            let metadataItems = metadataGroups.flatMap{ $0.items }
            switch _stationType {
            case .live:
                let item = MetaData(Live.DataParser(metadataItems))
                _currentMetaItem = item
            case .digit:
                let item = MetaData(Digit.DataParser(metadataItems))
                _currentMetaItem = item
            }
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            _stateMachine.observer = observer
        }
    }
}
