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
    func willPlayStation(_ station: StationWrapper, with url: URL?)
    func catchTheError(_ error: Error)
}

protocol MarconiPlayerControlsDelegate: class {
    func playToggle(isPlay: Bool)
    func muteToggle(isMuted: Bool)
}

class MarconiPlayerController: UIViewController, Containerable {
    
    private weak var _controller: UIViewController?

    private var _playingItemViewController: PlayingItemViewController {
        guard let controller = _controller as? PlayingItemViewController else {
            removeController(_controller)
            let controller = PlayingItemViewController()
            controller.playerControlsDelegate = self
            addController(controller, onto: view)
            _controller = controller
            return controller
        }
        return controller
    }
    
    typealias Player = Marconi.Player
    
    private lazy var _player: Player = .init(self)
    
    private var _playingItem: DisplayItemNode?
    private var _stationWrapper: StationWrapper? {
        willSet {
            guard let oldStation = _stationWrapper, let newStation = newValue else { return }
            _willReplaceStation(from: oldStation, to: newStation)
        }
    }
        
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _noPlayingItem()
    }
    
    // MARK: - Private methods
    
    private func _willReplaceStation(from: StationWrapper, to: StationWrapper) {
        // save progress for current station, needed to initialize digital stream
        if case .digit = from.type {
            _playingItem?.saveCurrentProgress(for: from.station)
        }
    }
    
    // MARK: - UI is function of State Machine
    
    private func _noPlayingItem() {
        let controller = NoPlayingItemViewController()
        removeController(_controller)
        addController(controller, onto: view)
        _controller = controller
    }
    
    private func _buffering() {
        let controller = _playingItemViewController
        controller.willReuseController()
        controller.buffering()
    }
    
    private func _startPlaying(_ playItem: DisplayItemNode) {
        let controller = _playingItemViewController
        controller.willReuseController()
        controller.startPlaying(playItem)
    }
    
    private func _updateProgress(_ value: CGFloat) {
        let controller = _playingItemViewController
        controller.updateProgress(value)
    }
    
    // MARK: - Handle State
    
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
                // call _startPlaying only once, because we don't need to update UI
                if progress.isZero {
                    let playingItemDispaly = DisplayItemNode(metaData, station: _stationWrapper?.station)
                     _startPlaying(playingItemDispaly)
                }
            case .digit, .none:
                let playingItemDispaly = DisplayItemNode(metaData, station: _stationWrapper?.station)
                guard let playingItem = _playingItem, playingItem == playingItemDispaly else {
                    _startPlaying(playingItemDispaly)
                    _playingItem = playingItemDispaly
                    return
                }
                guard let duration = metaData.duration,
                    let offset = metaData.offset else {
                    return
                }
                _playingItem?.updateProgress(value: progress)
                _updateProgress(CGFloat((progress + offset) / duration))
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
    
    func willPlayStation(_ wrapper: StationWrapper, with url: URL?) {
        guard let url = url else { return }
        _stationWrapper = wrapper
        _playingItem = nil
        _player.replaceCurrentURL(with: url, stationType: wrapper.type)
        _player.play()
    }
}

extension MarconiPlayerController: MarconiPlayerControlsDelegate {
    
    func playToggle(isPlay: Bool) {
        if isPlay {
            _player.play()
        } else {
            _player.pause()
        }
    }
    
    func muteToggle(isMuted: Bool) {
        _player.isMuted = isMuted
    }
}
