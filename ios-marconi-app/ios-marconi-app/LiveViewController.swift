//
//  LiveViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 17.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import AVFoundation
import ios_marconi_framework

class LiveViewController: UIViewController/*, AVPlayerItemMetadataCollectorPushDelegate*/ {
    
    let provider: StationProvider = .init()
    
    override func viewDidLoad() {
        provider.fetch(by: 1005).observe { (result) in
            switch result {
            case .success(let movie):
                print(movie)
            case .failure(let error):
                print(error)
            }
        }
    }
    
//    let player = AVPlayer()
//    var playerItem: AVPlayerItem!
//    var metadataCollector: AVPlayerItemMetadataCollector!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //provider.fetch(by: 1005)
////        prepareToPlay(url: URL(string: "https://marconi.radio-stg.com/marconi/live/3.m3u8?udid=10000343")!)
//        // Do any additional setup after loading the view.
//    }
//
//    func prepareToPlay(url: URL) {
//        self.metadataCollector = AVPlayerItemMetadataCollector()
//        self.metadataCollector.setDelegate(self, queue: DispatchQueue.global())
//
//        self.playerItem = AVPlayerItem(url: url)
//        self.playerItem.add(metadataCollector)
//
//        self.player.replaceCurrentItem(with: playerItem)
//        self.player.play()
//    }
//
//    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
//        for item in metadataGroups {
//            for it in item.items {
////                let metadataValue = it.value(forKeyPath: #keyPath(AVMetadataItem.value))!
////                print("Metadata value: \n \(metadataValue)")
////                Optional(__C.AVMetadataIdentifier(_rawValue: lsdr/X-TYPE))
////                Optional(__C.AVMetadataIdentifier(_rawValue: lsdr/X-PLAY-ID))
////                Optional(__C.AVMetadataIdentifier(_rawValue: lsdr/X-ARTIST))
////                Optional(__C.AVMetadataIdentifier(_rawValue: lsdr/X-TITLE))
//                //check lsdr/X-TITLE
//                print(it.value)
//            }
//        }
//    }
}
