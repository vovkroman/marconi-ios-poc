//
//  BufferingView.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import SkeletonView

class PlayingView: UIView, NibReusable {
    
    @IBOutlet private weak var _titleOfView: UILabel!
    @IBOutlet private weak var _imageView: MarconiImageView!
    
    @IBOutlet private weak var _stationName: UILabel!
    @IBOutlet private weak var _titleSong: UILabel!
    @IBOutlet private weak var _artistName: UILabel!
    @IBOutlet private weak var _typeName: UILabel!
        
    @IBOutlet private weak var _controlsView: UIView!
    
    @IBOutlet private weak var _progressBar: MarconiProgressBar!
    
    func startBuffering() {
        _titleOfView.text = "Buffering ..."
        let shimmedColor = UIColor.lightGray
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
    }
    
    func startPlaying(_ playingItem: DisplayItemNode) {
        stopBuffering()
        _titleOfView.text = "Now playing:"
        _controlsView.isHidden = !playingItem.isShowPlayerControls
        _progressBar.progress = playingItem.startTime
        _stationName.text = playingItem.stationName
        _titleSong.text = playingItem.title
        _artistName.text = playingItem.artistName
        _typeName.text = "Type: Station"
        
        _imageView.loadImage(from: playingItem.url)
    }
    
    func updateProgress(_ value: CGFloat) {
        _progressBar.progress = value
    }
    
    func willReuseView() {
        _imageView.cancelLoading()
    }
}
