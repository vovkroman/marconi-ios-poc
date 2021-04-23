//
//  BufferingView.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import SkeletonView

typealias ControlsDelegate = MarconiPlayerControlsDelegate & MarconiSeekDelegate & MarconiItemFeedbackDelegate

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
    
    @IBOutlet private weak var _progressLabel: UILabel!
    @IBOutlet private weak var _durationLabel: UILabel!
    
    @IBOutlet private weak var _preferenceView: UIView!
    
    // Constraints to hide/show _preferenceView
    @IBOutlet private weak var _bottomPreferenceViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _bottomProgressPanelConstraint: NSLayoutConstraint!
    
    func startBuffering() {
        _titleOfView.text = "Buffering ..."
        let shimmedColor = UIColor.lightGray
        _preferenceView.showAnimatedSkeleton(usingColor: shimmedColor)
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
        _preferenceView.hideSkeleton()
    }
    
    func startPlaying(_ playingItem: DisplayItemNode) {
        stopBuffering()
        _playButton.isSelected = playingItem.isPlaying
        _titleOfView.text = "Now playing:"
        _skipButton.isEnabled = playingItem.isSkipSupportable
        _controlsView.isHidden = !playingItem.isShowPlayerControls
        
        let duration = playingItem.maxValue
        _progressBar.maximumValue = Float(duration)
        _progressBar.minimumValue = 0.0
        
        let offsetValue = playingItem.playlistOffset
        _progressBar.value = Float(offsetValue)
        _progressLabel.text = offsetValue.asString(style: .positional)
        _durationLabel.text = duration.asString(style: .positional)
        
        _stationName.text = playingItem.stationName
        _titleSong.text = playingItem.title
        _artistName.text = playingItem.artistName
        _typeName.text = playingItem.type
        _imageView.loadImage(from: playingItem.url)
        
        if playingItem.isShowPlayerControls {
            _bottomProgressPanelConstraint.isActive = false
            _bottomPreferenceViewConstraint.isActive = true
        } else {
            _bottomPreferenceViewConstraint.isActive = false
            _bottomProgressPanelConstraint.isActive = true
        }
         _preferenceView.isHidden = !playingItem.isShowPlayerControls
        layoutIfNeeded()
    }
    
    func updateProgress(_ value: TimeInterval) {
        print("TimeInterval: \(value)")
        _progressBar.value = Float(value)
        _progressLabel.text = value.asString(style: .positional)
    }
    
    func willReuseView() {
        _imageView.cancelLoading()
    }
    
    // MARK: - Acions
    
    @IBAction private func playToggleAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playerControlsDelegate?.playToggle(isPlay: sender.isSelected)
    }
    
    @IBAction private func muteToggleAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playerControlsDelegate?.muteToggle(isMuted: sender.isSelected)
    }
    
    @IBAction private func skipAction(_ sender: UIButton) {
        Log.debug("SKIP has been performed")
        playerControlsDelegate?.performSkip()
    }
    @IBAction private func likeAction(_ sender: Any) {
        Log.debug("LIKE has been performed")
        playerControlsDelegate?.makeFeedback(.like)
    }
    
    @IBAction private func dislikeAction(_ sender: Any) {
        Log.debug("DISLIKE has been performed")
        playerControlsDelegate?.makeFeedback(.dislike)
    }
}
