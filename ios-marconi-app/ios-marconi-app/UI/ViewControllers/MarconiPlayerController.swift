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

typealias StationType = Marconi.StationType

protocol MarconiPlayerDelegate: class {
    func willPlayStation(_ station: StationWrapper, with url: URL)
    func catchTheError(_ error: Error)
}

class MarconiPlayerController: UIViewController, Containerable {
    
    private(set) weak var _controller: UIViewController?
    
    typealias Radio = Marconi.Radio
    
    private lazy var _radio: Radio = .init(self)
    private var _station: Station!
    private var _playingItem: DisplayItemNode?
        
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
    
    private func _startPlaying(_ playItem: DisplayItemNode) {
        guard let controller = _controller as? PlayingItemViewController else {
            let controller = PlayingItemViewController()
            removeController(_controller)
            addController(controller, onto: view)
            _controller = controller
            controller.startPlaying(playItem)
            return
        }
        controller.willReuseController()
        controller.startPlaying(playItem)
    }
    
    private func _updateProgress(_ value: CGFloat) {
        guard let controller = _controller as? PlayingItemViewController else {
            let controller = PlayingItemViewController()
            removeController(_controller)
            addController(controller, onto: view)
            _controller = controller
            controller.updateProgress(value)
            return
        }
        controller.updateProgress(value)
    }
    
    private func _handleState(_ state: Marconi.StateMachine.State) {
        switch state {
        case .noPlaying:
            _noPlayingItem()
        case .buffering(_):
            _buffering()
            _playingItem = nil
        case .playing(let metaData, let progress):
            switch metaData {
            case .live:
                if progress.isZero {
                    let playingItemDispaly = DisplayItemNode(metaData, station: _station)
                     _startPlaying(playingItemDispaly)
                }
            case .digit, .none:
                guard let playingItem = _playingItem else {
                    let playingItemDispaly = DisplayItemNode(metaData, station: _station)
                    _startPlaying(playingItemDispaly)
                    _playingItem = playingItemDispaly
                    return
                }
                let playingItemDispaly = DisplayItemNode(metaData, station: _station)
                if playingItem == playingItemDispaly {
                    _updateProgress(CGFloat(metaData.duration.flatMap{ progress / $0 } ?? 0.0))
                } else {
                    _startPlaying(playingItemDispaly)
                    _playingItem = playingItemDispaly
                }
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
    
    func willPlayStation(_ wrapper: StationWrapper, with url: URL) {
        _playingItem = nil
        _station = wrapper.station
        _radio.replaceCurrentURL(with: url, stationType: wrapper.type)
        _radio.play()
    }
}
