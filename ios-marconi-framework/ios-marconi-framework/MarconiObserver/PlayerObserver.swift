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
            return .init(every: 1.0) { (itemProgress, streamProgress) in
                self._streamProgress = streamProgress
                self._stateMachine.transition(with: .progressDidChanged(progress: itemProgress))
            }
        }()
        
        private weak var _player: AVPlayer?
        private(set) var _streamProgress: TimeInterval?
        
        private var _workItem: DispatchWorkItem?
        
        private(set) var _currentMetaItem: MetaData = .none {
            didSet {
                _workItem?.cancel()
                if oldValue != _currentMetaItem {
                    switch _currentMetaItem {
                    case .live(_):
                        _stateMachine.transition(with: .newMetaHasCame(_currentMetaItem))
                    case .digit(_, let startDate):
                        print("STARTED TIME: \(startDate)")
                        guard let timeInterval = startDate?.timeIntervalSinceNow, timeInterval > 0.0 else {
                            return
                        }
                        let workItem = DispatchWorkItem(block: _nextSongStartedPlaying)
                        self._workItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: workItem)
                    case .none:
                        break
                    }
                }
            }
        }
        
        private func _nextSongStartedPlaying() {
            print("STARTED TIME: NEXT SONG HAS BEEN INVOKED: at time \(Date())")
            _updateProgressObserver()
            _stateMachine.transition(with: .trackHasBeenChanged(_currentMetaItem))
        }
        
        private(set) var _stateMachine: StateMachine = .init()
        
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
        
        private func _startObserveProgress() {
            if case .digit = _stationType {
                _timerObsrever?.invalidate()
                _timerObsrever?.startObserveTimings(metadata: _currentMetaItem, for: _player)
            }
        }
        
        private func _updateProgressObserver() {
            _timerObsrever?.invalidate()
            _timerObsrever?.updateTimings(metadata: _currentMetaItem, for: _player)
        }
        
        private func _observeStatus(_ playerItem: AVPlayerItem) {
            switch playerItem.status {
            case .readyToPlay:
                _startObserveProgress()
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
        }
        
        public func stopMonitoring() {
            _player?.pause()
            _timerObsrever?.invalidate()
            _playbackLikelyToKeepUpKeyPathObserver?.invalidate()
            _playbackBufferEmptyObserver?.invalidate()
            _playbackBufferFullObserver?.invalidate()
            _playbackBufferEmptyObserver = nil
            _playbackLikelyToKeepUpKeyPathObserver = nil
            _playbackBufferFullObserver = nil
        }
        
        public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                      didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                      indexesOfNewGroups: IndexSet,
                                      indexesOfModifiedGroups: IndexSet) {
            let metadataItems = metadataGroups.flatMap{ $0.items }
            switch _stationType {
            case .live:
                let item = MetaData(Live.DataParser(metadataItems))
                _currentMetaItem = item
            case .digit:
                let startDate = metadataGroups.first?.startDate
                let item = MetaData(Digit.DataParser(metadataItems), date: startDate)
                _currentMetaItem = item
            }
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            _stateMachine.observer = observer
        }
    }
}
