//
//  MarconiObserver.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class PlayerObserver: NSObject, AVPlayerItemMetadataCollectorPushDelegate, TrackTimimgsDelegate {
        
        private(set) var _stationType: StationType = .live
        
        private var _playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
        private var _playbackBufferEmptyObserver: NSKeyValueObservation?
        private var _playbackBufferFullObserver: NSKeyValueObservation?
        
        private(set) lazy var timerObserver: TrackTimingsObserver = .init(every: 1.0,
                                                                          player: _player,
                                                                          queue: _queue,
                                                                          delegate: self)
        
        private weak var _player: AVPlayer?
        private(set) var streamProgress: TimeInterval? {
            didSet {
                print("streamProgress: \(String(describing: streamProgress))")
            }
        }
        
        private(set) var stateMachine: StateMachine = .init()
        
        // MARK: - Methods to handle new meta item has come
        
        private var _queue: MetaDataQueue = .init()
        
        private(set) var currentMetaItem: MetaData = .none
        
        private func _currentTrackFinished() {
            _queue.dequeue()
            
            guard let item = _queue.head() else {
                let nextMeta: MetaData = .none
                currentMetaItem = nextMeta
                stateMachine.transition(with: .trackHasBeenChanged(nextMeta))
                return
            }
            
            currentMetaItem = item
            _updateProgressObserver(metaData: item)
            stateMachine.transition(with: .trackHasBeenChanged(item))
        }
        
        // MARK: - Observe buffering
        
        private func _observeBuffering(_ playerItem: AVPlayerItem) {
            stateMachine.transition(with: .bufferingStarted(playerItem))
            _playbackBufferEmptyObserver = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self](playerItem, _) in
                self?.stateMachine.transition(with: .bufferingStarted(playerItem))
            }
            
            _playbackLikelyToKeepUpKeyPathObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            }
            
            _playbackBufferFullObserver = playerItem.observe(\.isPlaybackBufferFull, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            }
        }
        
        private func _observeStatus(_ playerItem: AVPlayerItem) {
            switch playerItem.status {
            case .readyToPlay:
                _startObserveProgress()
                stateMachine.transition(with: .bufferingEnded(currentMetaItem))
            case .failed:
                stateMachine.transition(with: .catchTheError(playerItem.error))
            default:
                break
            }
        }
        
        // MARK: - Observe progressing
        
        private func _startObserveProgress() {
            if case .digit = _stationType {
                timerObserver.invalidate()
                timerObserver.startObserveTimings(metadata: currentMetaItem)
            }
        }
        
        private func _updateProgressObserver(metaData: MetaData) {
            if case .digit = _stationType {
                timerObserver.invalidate()
                timerObserver.updateTimings(current: metaData)
            }
        }
        
        // MARK: - Fetch meta
        
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
            currentMetaItem = .none
            guard let newPlayingItem = playerItem else {
                return
            }
            _stationType = stationType
            _fetchMetaData(newPlayingItem)
            _observeBuffering(newPlayingItem)
        }
        
        public func startMonitoring(_ playerItem: AVPlayerItem?) {
            startMonitoring(playerItem, stationType: _stationType)
        }
        
        public func stopMonitoring() {
            //_player?.pause()
            
            _queue.removeAll()
            
            timerObserver.invalidate()
            
            _playbackLikelyToKeepUpKeyPathObserver?.invalidate()
            _playbackBufferEmptyObserver?.invalidate()
            _playbackBufferFullObserver?.invalidate()
            _playbackBufferEmptyObserver = nil
            _playbackLikelyToKeepUpKeyPathObserver = nil
            _playbackBufferFullObserver = nil
        }
        
        // MARK: - TimimgsDelegate implementation
        
        func trackProgress(_ currentItemProgress: TimeInterval, _ streamProgress: TimeInterval) {
            self.streamProgress = streamProgress
            print("TimeInterval: \(currentItemProgress)")
            if currentItemProgress >= 1.0 {
                self.stateMachine.transition(with: .progressDidChanged(progress: round(currentItemProgress, toNearest: 1.0)))
            }
        }
        
        func trackHasBeenChanged() {
            _currentTrackFinished()
        }
        
        // MARK: - AVPlayerItemMetadataCollectorPushDelegate implementation
        
        public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                      didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                      indexesOfNewGroups: IndexSet,
                                      indexesOfModifiedGroups: IndexSet) {
            switch _stationType {
            case .live:
                let metadataItems = metadataGroups.flatMap{ $0.items }
                let item = MetaData(Live.DataParser(metadataItems))
                currentMetaItem = item
                stateMachine.transition(with: .newMetaHasCame(currentMetaItem))
            case .digit:
                for group in metadataGroups {
                    let startDate = group.startDate
                    let items = MetaData(Digit.DataParser(group.items),
                                         startDate: startDate)
                    _queue.enqueue(items)
                }
                guard let item = _queue.head(), currentMetaItem != item else {
                    // current asset's still playing
                    return
                }
                currentMetaItem = item
                if case .continuePlaying = stateMachine.state {
                    _updateProgressObserver(metaData: item)
                }
                stateMachine.transition(with: .newMetaHasCame(item))
            }
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            stateMachine.observer = observer
        }
    }
}
