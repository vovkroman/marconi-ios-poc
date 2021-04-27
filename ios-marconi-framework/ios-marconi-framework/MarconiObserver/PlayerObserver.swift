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
        
        private lazy var _timerObsrever: TimingsObserver = { [weak self] in
            return .init(every: 1.0) { (itemProgress, streamProgress) in
                guard let self = self else { return }
                self.streamProgress = streamProgress
                self.stateMachine.transition(with: .progressDidChanged(progress: itemProgress))
            }
        }()
        
        private weak var _player: AVPlayer?
        private(set) var streamProgress: TimeInterval?
        
        private(set) var scheduler: Scheduler?
        private(set) var stateMachine: StateMachine = .init()
        
        // MARK: - Methods to handle new meta item has come
        
        private var _queue: MetaDataQueue = .init()
        
        private(set) var currentMetaItem: MetaData = .none {
            didSet {
                if oldValue != currentMetaItem {
                    _processNew(metaItem: currentMetaItem)
                }
            }
        }
        
        private func _processNew(metaItem: MetaData) {
            scheduler?.cancel()
            scheduler = nil
            
            switch _stationType {
            case .live:
                stateMachine.transition(with: .newMetaHasCame(currentMetaItem))
            case .digit:
                _scheduleNextTrackInvoke(metaItem: currentMetaItem)
            }
        }
        
        private func _scheduleNextTrackInvoke(metaItem: MetaData) {
            guard let scheduleDate = metaItem.startTrackDate, scheduleDate > Date() else {
                // current item has started playing, but will need to schedule next track invocation
                if scheduler == nil {
                    _queue.dequeue()
                    if let item = _queue.peek(), item != currentMetaItem  {
                        _scheduleNextTrackInvoke(metaItem: item)
                    } else {
                        // new asset will come
                    }
                }
                return
            }
            print("NEXT TRACK HAS BEEN SCHEDULED ON: \(String(describing: scheduleDate))")
            scheduler = .init()
            scheduler?.start(at: scheduleDate)
            scheduler?.fire = { [weak self] in
                guard let self = self else { return }
                self._nextSongStartedPlaying(with: metaItem)
            }
        }
        
        private func _nextSongStartedPlaying(with metaData: MetaData) {
            print("NEXT SONG METHOD HAS BEEN INVOKED: at time \(Date())")
            _updateProgressObserver(metaData: metaData)
            stateMachine.transition(with: .trackHasBeenChanged(metaData))
            _queue.dequeue()
            guard let item = _queue.peek(), currentMetaItem != item else {
                return
            }

            currentMetaItem = item
        }
        
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
        
        private func _startObserveProgress() {
            if case .digit = _stationType {
                _timerObsrever.invalidate()
                _timerObsrever.startObserveTimings(metadata: currentMetaItem, for: _player)
            }
        }
        
        private func _updateProgressObserver(metaData: MetaData) {
            _timerObsrever.invalidate()
            _timerObsrever.updateTimings(metadata: metaData, for: _player)
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
            _player?.pause()
            scheduler?.cancel()
            scheduler = nil
            
            _queue.removeAll()
            
            _timerObsrever.invalidate()
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
//                let startDate = metadataGroups.first.startDate
                let item = MetaData(Live.DataParser(metadataItems))
                currentMetaItem = item
            case .digit:
                for group in metadataGroups {
                    let startDate = group.startDate
                    let items = MetaData(Digit.DataParser(group.items),
                                         startDate: startDate)
                    _queue.enqueue(items)
                }
                guard let item = _queue.peek(), currentMetaItem != item else {
                    return
                }
                
                currentMetaItem = item
            }
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            stateMachine.observer = observer
        }
    }
}
