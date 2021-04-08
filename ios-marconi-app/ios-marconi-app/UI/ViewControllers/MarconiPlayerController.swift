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
    func performSkip()
}

protocol MarconiSeekDelegate: class {
    func seekBegan(_ value: Float, slider: MarconiSlider)
    func seekInProgress(_ value: Float, slider: MarconiSlider)
    func seekEnded(_ value: Float, slider: MarconiSlider)
}

class MarconiPlayerController: UIViewController, Containerable {
    
    typealias Player = Marconi.Player
    
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
    
    private var _onSkip: NextAction?
    
    private lazy var _player: Player = .init(self)
    
    private var _playingItem: DisplayItemNode? {
        didSet {
            _onSkip = _playingItem?.next
        }
    }
    
    private var _stationWrapper: StationWrapper? {
        willSet {
            _willReplace(_stationWrapper)
        }
    }
    
    private let _applicationStateListener = ApplicationStateListener()
        
    init() {
        super.init(nibName: nil, bundle: nil)
        _applicationStateListener.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _noPlayingItem()
    }
    
//    // MARK: - Private methods
//
    private func _willReplace(_ stationWrapper: StationWrapper?) {
        let _displayItem = _playingItem ?? _player.currentMetaData.flatMap{ DisplayItemNode($0, station: _stationWrapper?.station) }
        guard let displayItem = _displayItem else { return }
        _stationWrapper?.savePlayingItem(playingItem: displayItem)
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
    
    private func _startPlaying(_ playItem: DisplayItemNode?) {
        if let playItem = playItem {
            let controller = _playingItemViewController
            controller.willReuseController()
            controller.startPlaying(playItem)
        }
    }
    
    private func _updateProgress(for metaData: Marconi.MetaData, progress: TimeInterval) {
        let controller = _playingItemViewController
        _playingItem?.updateProgress(value: progress)
        print("Progress: \(_playingItem?._progress)")
        let progress = Float(_playingItem?._progress ?? 0.0)
        controller.updateProgress(progress)
    }
    
    // MARK: - Handle State
    
    private func _handleState(_ state: Marconi.StateMachine.State) {
        switch state {
        case .noPlaying:
            _noPlayingItem()
        case .buffering(_):
            _playingItem = nil
            _buffering()
        case .startPlaying(let metaData):
            let playingItemDispaly = DisplayItemNode(metaData, station: _stationWrapper?.station)
            _playingItem = playingItemDispaly
            _startPlaying(playingItemDispaly)
        case .continuePlaying(let metaData, let progress):
            _updateProgress(for: metaData, progress: progress)
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
    
    func performSkip() {
        _onSkip?().observe(){ [weak self] result in
            switch result {
            case .success(let skipItem):
                if let stationWrapper = self?._stationWrapper {
                    self?.willPlayStation(stationWrapper, with: URL(skipItem.newPlaybackUrl))
                }
            case .failure(let error):
                print(error)
                break
                // catch the error
            }
        }
    }
    
    
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

extension MarconiPlayerController: MarconiSeekDelegate {
    func seekBegan(_ value: Float, slider: MarconiSlider) {}
    func seekInProgress(_ value: Float, slider: MarconiSlider) {}
    func seekEnded(_ value: Float, slider: MarconiSlider) {}
}

extension MarconiPlayerController: ApplicationStateListenerDelegate {
    
    func onApplicationStateChanged(_ newState: ApplicationState) {
        if case .didEnterBackground = newState {
            // To save progress when enter Background the app
            _willReplace(_stationWrapper)
        }
    }
}
