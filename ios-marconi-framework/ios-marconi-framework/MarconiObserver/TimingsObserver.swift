//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    public class TimingsObserver {
        
        typealias ProgressBlock = (_ currentItem: TimeInterval, _ stream: TimeInterval) -> ()
        
        private var _progressBlock: ProgressBlock?
        
        private let _interval: TimeInterval
        private var _playlistOffset: TimeInterval
        private var _counter: TimeInterval
        
        private(set) var _progressObserver: Any?
        private weak var _player: AVPlayer?
        
        private func _progressing(_ progress: TimeInterval) {
            _counter += _interval
            _progressBlock?(_counter.rounded(), (_playlistOffset + _counter).rounded())
        }
        
        func startObserving(metadata: MetaData, isContinuePlaying: Bool) {
            // we are distinguishing 2 states, because depands on state initila progress is calculated in differnt way
            if isContinuePlaying {
                _playlistOffset = metadata.playlistStartTime
                _counter = 0.0
            } else {
                _playlistOffset = metadata.playlistOffset
                _counter = metadata.playlistOffset - metadata.playlistStartTime
            }
            print("PLAYLIST: \(_playlistOffset)")
            _progressObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main, using: _progressing)
        }
        
        func invalidate() {
            _player?.removeTimeObserver(_progressObserver)
            _progressObserver = nil
        }
        
        init(every interval: TimeInterval, player: AVPlayer?, block: ProgressBlock? = nil) {
            _interval = interval
            _progressBlock = block
            _counter = 0.0
            _playlistOffset = 0.0
            _player = player
        }
        
        deinit {
            invalidate()
        }
    }
}
