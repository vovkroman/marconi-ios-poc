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
        
        public var streamProgress: TimeInterval {
            return _observer?.streamProgress ?? 0.0
        }
        
        public var playId: String? {
            return _observer?.currentMetaItem.playId
        }
        
        public var currentURL: URL?
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            currentURL = url
            _observer?.stopMonitoring()
            replaceCurrentItem(with: nil)
            let playingItem = AVPlayerItem(url: url)
            
            // we need to know *station type* to know how to map paylaod
            _observer?.startMonitoring(playingItem, stationType: stationType)
            super.replaceCurrentItem(with: playingItem)
            super.play()
        }
        
        public func restartCurrent(_ url: URL) {
            let url = url.updateQueryParams(key: "playlistOffset", value: "\(streamProgress)")
            _observer?.stopMonitoring()
            
            let playingItem = AVPlayerItem(url: url)
            _observer?.startMonitoring(playingItem)
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
            if !isPlaying {
                currentURL.flatMap(restartCurrent)
            }
            super.play()
        }
        
        public override func pause() {
            if isPlaying {
                _observer?.timerObserver.pause()
                stop()
            }
            super.pause()
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
