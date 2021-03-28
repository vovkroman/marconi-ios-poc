//
//  MarconiObserver.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class PlayerObserver: NSObject {
        
        private var _playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
        private var _playbackBufferEmptyObserver: NSKeyValueObservation?
        private var _playbackBufferFullObserver: NSKeyValueObservation?
        private var _playbackProgressObserver: Any?
        
        private weak var _player: AVPlayer?
        
        private(set) var _currentMetaItem: MetaData? {
            didSet {
                guard let currentMetaItem = _currentMetaItem else { return }
                if oldValue != currentMetaItem {
                    _stateMachine.transition(with: .fetchedMetaData(_currentMetaItem))
                }
            }
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
        
        private func _observeProgress() {
            _playbackProgressObserver = _player?.addLinearPeriodicTimeObserver(every: 1.0, queue: .main){ [weak self] progress in
                self?._stateMachine.transition(with: .progressDidChanged(progress: progress.rounded()))
            }
        }
        
        private func _observeStatus(_ playerItem: AVPlayerItem) {
            switch playerItem.status {
            case .readyToPlay:
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
        
        public func startMonitoring(_ playerItem: AVPlayerItem?) {
            guard let newPlayingItem = playerItem else {
                return
            }
            stopMonitoring()
            _fetchMetaData(newPlayingItem)
            _observeBuffering(newPlayingItem)
            _observeProgress()
        }
        
        public func stopMonitoring() {
            _player?.removeTimeObserver(_playbackProgressObserver)
            _playbackLikelyToKeepUpKeyPathObserver?.invalidate()
            _playbackBufferEmptyObserver?.invalidate()
            _playbackBufferFullObserver?.invalidate()
            _playbackBufferEmptyObserver = nil
            _playbackLikelyToKeepUpKeyPathObserver = nil
            _playbackBufferFullObserver = nil
            _playbackProgressObserver = nil
        }
        
        public init(_ observer: MarconiPlayerObserver?, player: AVPlayer) {
            _stateMachine.observer = observer
            _player = player
        }
    }
}

extension Marconi.PlayerObserver: AVPlayerItemMetadataCollectorPushDelegate {
    public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                  didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                  indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        let item = Marconi.MetaData(metadataGroups.flatMap{ $0.items })
        _currentMetaItem = item
    }
}
