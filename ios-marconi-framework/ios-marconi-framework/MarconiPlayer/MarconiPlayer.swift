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
        private var _resourceLoader: ResourceLoader?
        private var _stationType: StationType = .live
        
        public var _currentURL: URL?
        
        public var streamProgress: TimeInterval {
            return _observer?.streamProgress ?? 0.0
        }
        
        public var playId: String? {
            return _observer?.currentMetaItem.playId
        }
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            guard let asset = URLAsset(url: url) else { return }
            print(url)
            _stationType = stationType
            _currentURL = url
            _observer?.stopMonitoring()
            if currentItem != nil { replaceCurrentItem(with: nil) }
            
            // remove prev instance ResourceLoader
            _resourceLoader = nil
            _resourceLoader = ResourceLoader(_observer)
            
            asset.resourceLoader.setDelegate(_resourceLoader, queue: .main)
            let playingItem = AVPlayerItem(asset: asset)

            // we need to know *station type* to know how to map paylaod
            self._observer?.startMonitoring(playingItem, stationType: stationType)
            super.replaceCurrentItem(with: playingItem)
            super.play()
        }
        
        public func restore(with url: URL) {
            let url = url.updateQueryParams(key: "playlistOffset", value: "\(streamProgress.rounded(.toNearestOrEven))")
            print("replaced url: \(url)")
            replaceCurrentURL(with: url, stationType: _stationType)
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
            _currentURL.flatMap(restore)
        }
        
        public override func pause() {
            if isPlaying {
                stop()
            }
            super.pause()
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
