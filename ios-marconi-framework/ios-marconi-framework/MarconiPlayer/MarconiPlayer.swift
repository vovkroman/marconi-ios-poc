//
//  MarconiPlayer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class Radio: NSObject {
        
        private var _observer: PlayerObserver?
        
        private(set) var _player: AVPlayer
        
        public func play() {
            _player.play()
        }
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            _observer?.stopMonitoring()
            _player.replaceCurrentItem(with: nil)
            let playingItem = AVPlayerItem(url: url)
            
            // we need to know station type to know how to map paylaod
            _observer?.startMonitoring(playingItem, stationType: stationType)
            _player.replaceCurrentItem(with: playingItem)
        }
        
        public init(_ observer: MarconiPlayerObserver?, _ player: AVPlayer = .init()) {
            _player = player
            _observer = .init(observer, player: player)
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
