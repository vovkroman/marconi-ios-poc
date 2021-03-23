//
//  MarconiPlayerViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 22.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import AVFoundation
import ios_marconi_framework

protocol MarconiPlayerDelegate: class {
    func willPlayStation(_ station: Station, with url: URL)
}

class MarconiPlayerController: UIViewController {

    typealias Radio = Marconi.Radio
    
    private lazy var _radio: Radio = .init(self)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _noPlayingItem()
    }
    
    // MARK: - UI is state function of State Machine
    private func _noPlayingItem() {
        
    }
    
    private func _buffering() {
        
    }
    
    private func _playing(_ playItem: Marconi.Live.MetaData?) {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarconiPlayerController: MarconiPlayerObserver {
    func stateDidChanched(_ stateMachine: Marconi.StateMachine, to: Marconi.StateMachine.State) {
        switch to {
        case .noPlaying:
            _noPlayingItem()
        case .buffering(_):
            _buffering()
        case .playing(let playerItem):
            _playing(playerItem)
        case .error(let error):
            break
        }
    }
}

extension MarconiPlayerController: MarconiPlayerDelegate {
    func willPlayStation(_ station: Station, with url: URL) {
        _radio.replaceCurrentURL(with: url)
        _radio.play()
    }
}
