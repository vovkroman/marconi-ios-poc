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
        private var _metadataCollector: AVPlayerItemMetadataCollector!
        
        public override func replaceCurrentItem(with item: AVPlayerItem?) {
            _observer?.startMonitoring(item)
            super.replaceCurrentItem(with: item)
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            // if MarconiPlayerObserver? doesn't exist then Marconi.Player will behav as regular AVPlayer
            if let observer = observer {
                _observer = PlayerObserver(observer)
            }
            super.init()
        }
        
        public override init() {
            super.init()
        }
    }
}

