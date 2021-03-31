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
    func catchTheError(_ error: Error)
}

class MarconiPlayerController: UIViewController, Containerable {
    
    private(set) weak var _controller: UIViewController?
    
    typealias Radio = Marconi.Radio
    
    private lazy var _radio: Radio = .init(self)
    private var _station: Station!
    private var _playingItem: PlayingItem?
    
    var stationType: StationType = .live
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _noPlayingItem()
    }
    
    // MARK: - UI is state function of State Machine
    private func _noPlayingItem() {
        let controller = NoPlayingItemViewController()
        removeController(_controller)
        addController(controller, onto: view)
        _controller = controller
    }
    
    private func _buffering() {
        guard let controller = _controller as? PlayingItemViewController else {
            removeController(_controller)
            let controller = PlayingItemViewController()
            addController(controller, onto: view)
            _controller = controller
            controller.buffering()
            return
        }
        controller.willReuseController()
        controller.buffering()
    }
    
    private func _playing(_ playItem: PlayingItem?) {
        guard let controller = _controller as? PlayingItemViewController else {
            let controller = PlayingItemViewController()
            removeController(_controller)
            addController(controller, onto: view)
            _controller = controller
            controller.dispalyItem(playItem)
            return
        }
        controller.willReuseController()
        controller.dispalyItem(playItem)
    }
    
    private func _updateProgress(_ value: CGFloat) {
        print("Updating progress \(value)")
    }
    
    private func _handleState(_ state: Marconi.StateMachine.State) {
        switch state {
        case .noPlaying:
            _noPlayingItem()
        case .buffering(_):
            _buffering()
            _playingItem = nil
        case .playing(let newMetaDataItem, let progress):
            guard let playingItem = _playingItem else {
                let playingItemDispaly = PlayingItem(newMetaDataItem, station: _station)
                _playing(playingItemDispaly)
                _playingItem = playingItemDispaly
                return
            }
            let playingItemDispaly = PlayingItem(newMetaDataItem, station: _station)
            if playingItem == playingItemDispaly {
                _updateProgress(progress.value)
            } else {
                _playing(playingItemDispaly)
                _playingItem = playingItemDispaly
            }
        case .error(_):
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarconiPlayerController: MarconiPlayerObserver {
    func stateDidChanched(_ stateMachine: Marconi.StateMachine, to: Marconi.StateMachine.State) {
        DispatchQueue.main.async(execute: combine(to, with: _handleState))
    }
}

extension MarconiPlayerController: MarconiPlayerDelegate {
    
    func catchTheError(_ error: Error) {}
    
    func willPlayStation(_ station: Station, with url: URL) {
        _playingItem = nil
        _station = station
        _radio.replaceCurrentURL(with: url)
        _radio.play()
    }
}
