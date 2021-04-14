//
//  BufferingView.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import SkeletonView

typealias ControlsDelegate = MarconiPlayerControlsDelegate & MarconiSeekDelegate

final class PlayingView: UIView, NibReusable {
    
    weak var playerControlsDelegate: ControlsDelegate? {
        didSet {
            _progressBar.delegate = playerControlsDelegate
        }
    }
    
    @IBOutlet private weak var _titleOfView: UILabel!
    @IBOutlet private weak var _imageView: MarconiImageView!
    @IBOutlet private weak var _skipButton: UIButton!
    
    @IBOutlet private weak var _stationName: UILabel!
    @IBOutlet private weak var _titleSong: UILabel!
    @IBOutlet private weak var _artistName: UILabel!
    @IBOutlet private weak var _typeName: UILabel!
    @IBOutlet private weak var _controlsView: UIView!
    @IBOutlet private weak var _progressBar: MarconiSlider!
    @IBOutlet private weak var _playButton: UIButton!
    @IBOutlet private weak var _muteButton: UIButton!
    
    func startBuffering() {
        _titleOfView.text = "Buffering ..."
        let shimmedColor = UIColor.lightGray
        _muteButton.showAnimatedSkeleton(usingColor: shimmedColor)
        _imageView.showAnimatedSkeleton(usingColor: shimmedColor)
        _stationName.showAnimatedSkeleton(usingColor: shimmedColor)
        _titleSong.showAnimatedSkeleton(usingColor: shimmedColor)
        _artistName.showAnimatedSkeleton(usingColor: shimmedColor)
        _typeName.showAnimatedSkeleton(usingColor: shimmedColor)
        _controlsView.showAnimatedSkeleton(usingColor: shimmedColor)
    }
    
    func stopBuffering() {
        _stationName.hideSkeleton()
        _titleSong.hideSkeleton()
        _artistName.hideSkeleton()
        _typeName.hideSkeleton()
        _controlsView.hideSkeleton()
        _muteButton.hideSkeleton()
    }
    
    func startPlaying(_ playingItem: DisplayItemNode) {
        stopBuffering()
        _playButton.isSelected = playingItem.isPlaying
        _titleOfView.text = "Now playing:"
        _skipButton.isEnabled = playingItem.isSkipSupportable
        _controlsView.isHidden = !playingItem.isShowPlayerControls
        
        _progressBar.maximumValue = playingItem.maxValue
        _progressBar.minimumValue = 0.0
        _progressBar.value = playingItem.offset
        
        _stationName.text = playingItem.stationName
        _titleSong.text = playingItem.title
        _artistName.text = playingItem.artistName
        _typeName.text = playingItem.type
        _imageView.loadImage(from: playingItem.url)
    }
    
    func updateProgress(_ value: Float) {
        _progressBar.value = value
    }
    
    func willReuseView() {
        _imageView.cancelLoading()
    }
    
    // MARK: - Acions
    
    @IBAction func playToggleAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playerControlsDelegate?.playToggle(isPlay: sender.isSelected)
    }
    
    @IBAction func muteToggleAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playerControlsDelegate?.muteToggle(isMuted: sender.isSelected)
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        Log.debug("SKIP has been performed")
        playerControlsDelegate?.performSkip()
    }
}
