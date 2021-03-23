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
        
        public func setDelegate(_ observer: MarconiPlayerObserver?) {
            _observer?._stateMachine.observer = observer
        }
        
        public func play() {
            _player.play()
        }
        
        public func replaceCurrentURL(with url: URL) {
            let urlAsset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: urlAsset)
            _observer?.startMonitoring(item)
            _player.replaceCurrentItem(with: item)
        }
        
        public init(_ observer: MarconiPlayerObserver?, _ player: AVPlayer = .init()) {
            _player = player
            _observer = .init(observer)
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
