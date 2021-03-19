//
//  LiveStationsViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import AVFoundation
//import ios_marconi_framework

class LiveStationsViewController: ListViewController<LiveStations.ViewModel> {
    
//    var player: Marconi.Player!
//    var playerItem: AVPlayerItem!
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //provider.fetch(by: 1005)
//        //let url = URL(string: "https://marconi.radio-stg.com/marconi/live/31.m3u8?udid=10000343")!
//        let url = URL(string: "https://smartstreams.radio-stg.com/stream/2395/manifest/digitalstations/playlist.m3u8?udid=10000343")!
//        prepareToPlay(url: url)
        // Do any additional setup after loading the view.
    }
    
    func prepareToPlay(url: URL) {
//        //            self.metadataCollector = AVPlayerItemMetadataCollector()
//        //            self.metadataCollector.setDelegate(self, queue: DispatchQueue.global())
//        self.player = Marconi.Player(self)
//        self.playerItem = AVPlayerItem(url: url)
//        //self.playerItem.add(metadataCollector)
//
//        self.player.replaceCurrentItem(with: playerItem)
//        self.player.play()
    }
}

//extension LiveStationsViewController: MarconiPlayerObserver {
//    func stateDidChanched(_ stateMachine: Marconi.StateMachine, to: Marconi.StateMachine.State) {}
//}
