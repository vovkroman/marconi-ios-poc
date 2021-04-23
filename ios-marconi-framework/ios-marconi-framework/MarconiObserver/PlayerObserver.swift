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
        
        private(set) var _stateMachine: StateMachine = .init()
        
        // MARK: - Methods to handle new meta item has come
        
        private var _queue: MetaDataQueue = .init()
        
        private(set) var _currentMetaItem: MetaData = .none {
            didSet {
                if oldValue != _currentMetaItem {
                    _processNew(metaItem: _currentMetaItem)
                }
            }
        }
        
        private func _processNew(metaItem: MetaData) {
            _workItem?.cancel()
            _workItem = nil
            switch _stationType {
            case .live:
                _stateMachine.transition(with: .newMetaHasCame(_currentMetaItem))
            case .digit:
                _scheduleNextTrackInvoke(metaItem: _currentMetaItem)
            }
        }
        
        private func _scheduleNextTrackInvoke(metaItem: MetaData) {
            guard let timeInterval = metaItem.startTrackDate?.timeIntervalSinceNow, timeInterval > 0.0 else {
                // current item has started playing, but will need to schedule next track invocation
                if let item = _queue.head(), item != _currentMetaItem  {
                    _scheduleNextTrackInvoke(metaItem: item)
                }
                return
            }
            print("NEXT TRACK HAS BEEN SCHEDULED ON: \(String(describing: metaItem.startTrackDate))")
            _workItem = DispatchWorkItem() { [weak self] in
                guard let self = self else { return }
                self._nextSongStartedPlaying(with: metaItem)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: _workItem!)
        }
        
        private func _nextSongStartedPlaying(with metaData: MetaData) {
            print("NEXT SONG METHOD HAS BEEN INVOKED: at time \(Date())")
            _stateMachine.transition(with: .trackHasBeenChanged(metaData))
            _updateProgressObserver(metaData: metaData)
            guard let item = _queue.head(), _currentMetaItem != item else {
                _queue.dequeue()
                return
            }
            // force unwrapped is ok, since head guarantee that first item exists
            _currentMetaItem = _queue.dequeue()!
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
        
        private func _startObserveProgress() {
            if case .digit = _stationType {
                _timerObsrever?.invalidate()
                _timerObsrever?.startObserveTimings(metadata: _currentMetaItem, for: _player)
            }
        }
        
        private func _updateProgressObserver(metaData: MetaData) {
            _timerObsrever?.invalidate()
            _timerObsrever?.updateTimings(metadata: metaData, for: _player)
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
            _workItem?.cancel()
            _queue.removeAll()
            _workItem = nil
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
                for group in metadataGroups {
                    let startDate = group.startDate
                    let items = MetaData(Digit.DataParser(group.items), date: startDate)
                    _queue.enqueue(items)
                }
                guard let item = _queue.head(), _currentMetaItem != item else {
                    _queue.dequeue()
                    return
                }
                // force unwrapped is ok, since head guarantee that first item exists
                _currentMetaItem = _queue.dequeue()!
            }
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            _stateMachine.observer = observer
        }
    }
}
