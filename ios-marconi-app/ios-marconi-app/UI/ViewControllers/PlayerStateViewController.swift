//
//  NoItemToPlayViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

typealias Viewable = UIView & NibReusable

class PlayerStateViewController<View: Viewable>: UIViewController {
    
    var contentView: View {
        return view as! View
    }
    
    override func loadView() {
        let view = View()
        view.setupFromNib()
        self.view = view
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.debug("\(self) has been removed", category: .lifeCycle)
    }
}

final class NoPlayingItemViewController: PlayerStateViewController<NoPlayingItemView> {}
final class PlayingItemViewController: PlayerStateViewController<PlayingView> {
    
    weak var playerControlsDelegate: ControlsDelegate? {
        didSet {
            contentView.playerControlsDelegate = playerControlsDelegate
        }
    }
    
    override func viewDidLayoutSubviews() {
        contentView.layoutSkeletonIfNeeded()
    }
    
    func buffering() {
        if isViewLoaded {
            contentView.startBuffering()
        }
    }
    
    func startPlaying(_ item: DisplayItemNode) {
        if isViewLoaded {
            contentView.startPlaying(item)
        }
    }
    
    func updateProgress(_ value: TimeInterval) {
        if isViewLoaded {
            contentView.updateProgress(value)
        }
    }
    
    func pause() {
        if isViewLoaded {
            contentView.pause()
        }
    }
    
    func willReuseController() {
        contentView.willReuseView()
    }
}
