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

protocol MarconiItemFeedbackDelegate: class {
    func makeFeedback(_ type: Feedback)
}

protocol MarconiSeekDelegate: class {
    func seekBegan(_ value: Float, slider: MarconiSlider)
    func seekInProgress(_ value: Float, slider: MarconiSlider)
    func seekEnded(_ value: Float, slider: MarconiSlider)
}

class MarconiPlayerController: UIViewController, Containerable {
    
    typealias Player = Marconi.Player
    
    private weak var _controller: UIViewController?
    
    weak var logger: LoggerDelegate?

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
    
    private let _applicationStateListener = ApplicationStateListener()
    
    private var _playingItem: DisplayItemNode? {
        didSet {
            _onSkip = _playingItem?.skip
        }
    }
    
    private var _stationWrapper: StationWrapper? {
        willSet {
            _willReplace(_stationWrapper)
        }
    }
        
    init() {
        super.init(nibName: nil, bundle: nil)
        _applicationStateListener.delegate = self // I'm your father, Luke
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _noPlayingItem()
    }
    
//    // MARK: - Private methods
//
    private func _willReplace(_ stationWrapper: StationWrapper?) {
        _stationWrapper?.saveCurrent(progressData: (_player.streamProgress, _player.playId))
    }
    
    // MARK: - UI is function of State Machine
    
    private func _noPlayingItem() {
        let controller = NoPlayingItemViewController()
        removeController(_controller)
        addController(controller, onto: view)
        _controller = controller
    }
    
    private func _buffering() {
        // to cancel pending skip/feedback
        //_playingItem?.cancelRequests()
        
        // to nullify _onSkip handler
        _playingItem = nil
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
        controller.updateProgress(progress)
    }
    
    // MARK: - Handle State
    
    private func _handleState(_ state: Marconi.StateMachine.State) {
        switch state {
        case .noPlaying:
            _noPlayingItem()
        case .buffering(_):
            _buffering()
        case .startPlaying(let metaData):
            let playingItemDispaly = DisplayItemNode(metaData,
                                                     station: _stationWrapper?.station,
                                                     isPlaying: _player.isPlaying)
            _playingItem = playingItemDispaly
            _startPlaying(playingItemDispaly)
            
            // Log event
            logger?.emittedEvent(event: .metaDataItem(item: metaData))
        case .continuePlaying(let metaData, let progress):
            _updateProgress(for: metaData, progress: progress)
        case .error(let error):
            
            // To save progress on caught the error
            _willReplace(_stationWrapper)
            Log.error("[Error]: Marconi.Player throws the error", category: .default)
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
    
    func catchTheError(_ error: Error) {
        // Log error
        logger?.emittedEvent(event: .caughtTheError(error))
    }
    
    func willPlayStation(_ wrapper: StationWrapper, with url: URL?) {
        guard let url = url else { return }
        _stationWrapper = wrapper
        _playingItem = nil
        _player.replaceCurrentURL(with: url, stationType: wrapper.type)
        _player.play()
        
        // Log event
        logger?.emittedEvent(event: .handleStreamURL(description: "\(url) to initialize \(wrapper.station.name)"))
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
                self?.catchTheError(error)
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

extension MarconiPlayerController: MarconiItemFeedbackDelegate {
    func makeFeedback(_ type: Feedback) {
        let leaveFeedback = _playingItem?.leaveFeedback(type)
        leaveFeedback?.observe() { [weak self] result in
            switch result {
            case .success(let entity):
                self?.logger?.emittedEvent(event: .leaved(feedback: entity))
            case .failure(let error):
                self?.logger?.emittedEvent(event: .caughtTheError(error))
            }
        }
    }
}
