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
        
        private(set) var _currentMetaItem: Live.MetaData? {
            didSet {
                guard let currentMetaItem = _currentMetaItem else { return }
                if oldValue != currentMetaItem {
                    _stateMachine.transition(with: .fetchedMetaData(_currentMetaItem))
                }
            }
        }
        
        private(set) var _stateMachine: StateMachine = .init()
        
        private func _observeBuffering(_ playerItem: AVPlayerItem?) {
            _playbackBufferEmptyObserver = playerItem?.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self](playerItem, _) in
                self?._stateMachine.transition(with: .bufferingStarted(playerItem))
            }
            
            _playbackLikelyToKeepUpKeyPathObserver = playerItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            }
            
            _playbackBufferFullObserver = playerItem?.observe(\.isPlaybackBufferFull, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
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
        
        private func _fetchMetaData(_ playerItem: AVPlayerItem?) {
            let metadataCollector = AVPlayerItemMetadataCollector()
            metadataCollector.setDelegate(self, queue: .main)
            playerItem?.add(metadataCollector)
        }
        
        // Public methods
        
        deinit {
            stopMonitoring()
        }
        
        public func startMonitoring(_ playerItem: AVPlayerItem?) {
            stopMonitoring()
            _fetchMetaData(playerItem)
            _observeBuffering(playerItem)
        }
        
        public func stopMonitoring() {
            _playbackLikelyToKeepUpKeyPathObserver?.invalidate()
            _playbackBufferEmptyObserver?.invalidate()
            _playbackBufferFullObserver?.invalidate()
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            _stateMachine.observer = observer
        }
    }
}

extension Marconi.PlayerObserver: AVPlayerItemMetadataCollectorPushDelegate {
    public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                  didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                  indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        let item = Marconi.Live.MetaData(metadataGroups.flatMap{ $0.items })
        _currentMetaItem = item
    }
}
