//
//  MarconiPlayer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class Player: AVPlayer {
        
        private var _observer: PlayerObserver?
        private var _stationType: StationType = .live
        
        public var _currentURL: URL? {
            didSet {
                _observer?.currentURL = _currentURL
            }
        }
        
        public var streamProgress: TimeInterval {
            return _observer?.streamProgress ?? 0.0
        }
            
        public var playId: String? {
            return _observer?.currentMetaItem.playId
        }
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            _stationType = stationType
            _currentURL = url
            _observer?.stopMonitoring()
            _observer?.cleanAllData()
            replaceCurrentItem(with: nil)
            
            let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
            let playingItem = AVPlayerItem(asset: asset)
            playingItem.automaticallyPreservesTimeOffsetFromLive = true
            playingItem.configuredTimeOffsetFromLive = .zero

            // we need to know *station type* to know how to map paylaod
            self._observer?.startMonitoring(playingItem, stationType: stationType)
            super.replaceCurrentItem(with: playingItem)
            super.play()
        }
        
        func restore(with url: URL) {
            let url = url.updateQueryParams(key: "playlistOffset", value: streamProgress.stringValue)
            print("restored url: \(url)")
            let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
            let playingItem = AVPlayerItem(asset: asset)
            playingItem.automaticallyPreservesTimeOffsetFromLive = true
            playingItem.configuredTimeOffsetFromLive = .zero
            
            self._observer?.startMonitoring(playingItem, stationType: self._stationType)
            super.replaceCurrentItem(with: playingItem)
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            // if observer doesn't exist, then the player behaves the same way as AVPlayer
            if let observer = observer {
                _observer = .init(observer)
            }
            super.init()
            _observer?.setPlayer(self)
        }
        
        public override func play() {
            if case .digit = _stationType {
                _currentURL.flatMap(restore)
            }
            super.play()
        }
        
        public override func pause() {
            if isPlaying {
                stop()
                _observer?.stopMonitoring()
            }
            super.pause()
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
