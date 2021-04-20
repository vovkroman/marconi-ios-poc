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
        
        // TODO: Taken out of the player
        public var streamProgress: TimeInterval? {
            return _observer?._streamProgress
        }
        
        public var playId: String? {
            return _observer?._currentMetaItem.playId
        }
        
        public func startProgressObserving() {
            _observer?.startObserveProgress()
        }
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            _observer?.stopMonitoring()
            replaceCurrentItem(with: nil)
            let playingItem = AVPlayerItem(url: url)
            
            // we need to know *station type* to know how to map paylaod
            _observer?.startMonitoring(playingItem, stationType: stationType)
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
        
        deinit {
            print("\(self) has been removed")
        }
    }
}
