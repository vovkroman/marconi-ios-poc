//
//  MarconiObserver.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    class ObserverWrapper {
        private let _observer: NSKeyValueObservation?
        
        init(_ observer: NSKeyValueObservation) {
            _observer = observer
        }
        
        deinit {
            if let observer = _observer {
                observer.invalidate()
            }
        }
    }
    
    public class PlayerObserver: NSObject, AVPlayerItemMetadataCollectorPushDelegate, TrackTimimgsDelegate, PlaylistLoaderDelegate {
        
        enum MetadataSource: Int {
            case metaCollector = 0
            case playlist = 1
        }
        
        var currentURL: URL?
        private var _loader: ResourceLoader?
        
        private var _stationType: StationType = .live
        
        private var _playbackLikelyToKeepUpKeyPathObserver: ObserverWrapper?
        private var _playbackBufferEmptyObserver: ObserverWrapper?
        private var _playbackBufferFullObserver: ObserverWrapper?
        
        private lazy var _timerObserver: TrackTimingsObserver = .init(every: 1.0,
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
        
        // MARK: - Observe buffering
        
        private func _observeBuffering(_ playerItem: AVPlayerItem) {
            stateMachine.transition(with: .bufferingStarted(playerItem))
            _playbackBufferEmptyObserver = .init(playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self](playerItem, _) in
                self?.stateMachine.transition(with: .bufferingStarted(playerItem))
            })
            
            _playbackLikelyToKeepUpKeyPathObserver = .init(playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            })
            
            _playbackBufferFullObserver = .init(playerItem.observe(\.isPlaybackBufferFull, options: [.new]) { [weak self](playerItem, _) in
                self?._observeStatus(playerItem)
            })
        }
        
        private func _observeStatus(_ playerItem: AVPlayerItem) {
            switch playerItem.status {
            case .readyToPlay:
                _willStartPlaying()
            case .failed:
                stateMachine.transition(with: .catchTheError(playerItem.error))
            default:
                break
            }
        }
        
        private func _willStartPlaying() {
            // if .none then meta hasn't came, so requesting playlists
            if case .none = currentMetaItem {
                let resourceLoader = ResourceLoader(self)
                // suspend playing unless meta has came
                _player?.rate = 0.0
                currentURL.flatMap(resourceLoader.loadResource)
                _loader = resourceLoader
            } else {
               _startObserveProgress()
                if let player = _player, !player.isPlaying {
                    player.rate = 1.0
                }
               stateMachine.transition(with: .bufferingEnded(currentMetaItem))
           }
        }
        
        // MARK: - Observe progressing
        
        func _startObserveProgress() {
            _timerObserver.invalidate()
            _timerObserver.startObserveTimings(metadata: currentMetaItem)
        }
        
        private func _updateProgressObserver(metadata: MetaData) {
            _timerObserver.updateTimings(current: metadata)
        }
        
        // MARK: - Fetch meta
        
        private func _fetchMetaData(_ playerItem: AVPlayerItem) {
            let metadataCollector = AVPlayerItemMetadataCollector()
            metadataCollector.setDelegate(self, queue: .main)
            playerItem.add(metadataCollector)
        }
        
        private func _handleNewItems(from source: MetadataSource) {
            guard let item = _queue.head(), currentMetaItem != item else {
                // current asset's still playing
                return
            }
            currentMetaItem = item
            _startObserveProgress()
            
            switch source {
            case .metaCollector:
                stateMachine.transition(with: .newMetaHasCame(item))
            case .playlist:
                if let player = _player, !player.isPlaying {
                    player.rate = 1.0
                }
                stateMachine.transition(with: .bufferingEnded(item))
            }
        }
        
        // Public methods
        
        deinit {
            stopMonitoring()
            cleanAllData()
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
        
        public func cleanAllData() {
            _queue.removeAll()
        }
        
        public func stopMonitoring() {
            
            _timerObserver.invalidate()
            
            _playbackBufferEmptyObserver = nil
            _playbackLikelyToKeepUpKeyPathObserver = nil
            _playbackBufferFullObserver = nil
        }
        
        // MARK: - TimimgsDelegate implementation
        
        func trackProgress(_ currentItemProgress: TimeInterval, _ streamProgress: TimeInterval) {
            self.streamProgress = streamProgress
            print("Item Current Progress: \(currentItemProgress)")
            if currentItemProgress >= 1.0 {
                self.stateMachine.transition(with: .progressDidChanged(progress: currentItemProgress))
            }
        }
        
        func trackHasBeenChanged() {
            _queue.popFirst()
            guard let item = _queue.head() else {
                // skip assign .none if it's already .none
                if currentMetaItem != .none {
                    currentMetaItem = .none
                    stateMachine.transition(with: .trackHasBeenChanged(.none))
                }
                return
            }
            
            currentMetaItem = item
            _updateProgressObserver(metadata: item)
            stateMachine.transition(with: .trackHasBeenChanged(item))
        }
        
        // MARK: - PlaylistLoaderDelegate implementation
        
        func playlistHasBeenLoaded(_ playlist: Marconi.Playlist) throws {
            guard let data = "[\(playlist.segments.compactMap{ $0.json }.joined(separator: ", "))]".data(using: .utf8) else {
                throw MError.loaderError(description: "Failed laoding json from #EXTINF tag")
            }
            
            let startDate = playlist.startDate ?? Date()
            var metaItems: [MetaData] = []
            switch _stationType {
            case .digit:
                let items = try JSONDecoder().decode(Set<DigitaItem>.self, from: data)
                metaItems.append(contentsOf: items.compactMap{ MetaData.digit($0, startDate) })
            case .live:
                let items = try JSONDecoder().decode(Set<LiveItem>.self, from: data)
                metaItems.append(contentsOf: items.compactMap{ MetaData.live($0, startDate) })
            }
            if metaItems.isEmpty { return }
            _queue.enqueue(metaItems)
            DispatchQueue.main.async { self._handleNewItems(from: .playlist) }
        }
        
        func playlistLoaded(with error: Error) {
            if let player = _player, !player.isPlaying {
                player.rate = 1.0
            }
            stateMachine.transition(with: .bufferingEnded(currentMetaItem))
        }
        
        // MARK: - AVPlayerItemMetadataCollectorPushDelegate implementation
        
        public func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                      didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                      indexesOfNewGroups: IndexSet,
                                      indexesOfModifiedGroups: IndexSet) {
            print("Meta has come")
            var items: [MetaData] = []
            for group in metadataGroups {
                let startDate = group.startDate
                switch _stationType {
                case .digit:
                    let item = MetaData(Digit.DataParser(group.items),
                                        startDate: startDate)
                    items.append(item)
                case .live:
                    let item = MetaData(Live.DataParser(group.items),
                                        startDate: startDate)
                    items.append(item)
                }
            }

            if items.isEmpty {
                return
            }

            _queue.enqueue(items)
            _handleNewItems(from: .metaCollector)
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            stateMachine.observer = observer
        }
    }
}
