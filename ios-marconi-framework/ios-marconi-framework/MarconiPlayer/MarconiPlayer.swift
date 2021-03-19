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
        private lazy var _observer: PlayerObserver = .init()
        private var _metadataCollector: AVPlayerItemMetadataCollector!
        
        public override func replaceCurrentItem(with item: AVPlayerItem?) {
            _observer.startMonitoring(item)
            _metadataCollector = AVPlayerItemMetadataCollector()
            _metadataCollector.setDelegate(_observer, queue: .main)
            item?.add(_metadataCollector)
            super.replaceCurrentItem(with: item)
        }
        
        public override init() {
            super.init()
        }
    }
}

