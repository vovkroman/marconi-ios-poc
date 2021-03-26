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
    
    func startBuffering() {
        _titleOfView.text = "Buffering ..."
        _imageView.showAnimatedSkeleton()
        _stationName.showAnimatedSkeleton()
        _titleSong.showAnimatedSkeleton()
        _artistName.showAnimatedSkeleton()
        _typeName.showAnimatedSkeleton()
    }
    
    func stopBuffering() {
        _stationName.hideSkeleton()
        _titleSong.hideSkeleton()
        _artistName.hideSkeleton()
        _typeName.hideSkeleton()
    }
    
    func startPlaying(_ playingItem: PlayingItem?) {
        stopBuffering()
        _titleOfView.text = "Now playing:"
        _stationName.text = playingItem?.stationName
        _titleSong.text = playingItem?.title
        _artistName.text = playingItem?.artistName
        _typeName.text = "Type: Station"
        _imageView.loadImage(from: (playingItem?.url)!)
    }
    
    func willReuseView() {
        _imageView.cancelLoading()
    }
}
