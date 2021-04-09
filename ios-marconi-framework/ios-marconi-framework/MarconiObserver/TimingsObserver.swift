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
        private let _duration: TimeInterval
        private let _offset: TimeInterval
        private var _counter: TimeInterval {
            didSet {
                if _counter > _duration {
                    _counter = 0.0
                }
            }
        }
        
        private(set) var _progressObserver: Any?
        private weak var _player: AVPlayer?
        
        private func _running(_ progress: TimeInterval) {
            _counter += _interval
            _progressBlock?(_counter.rounded(), (_offset + progress).rounded())
        }
        
        func start() {
            _progressObserver = _player?.addLinearPeriodicTimeObserver(every: _interval, queue: .main, using: _running)
        }
        
        func invalidate() {
            _player?.removeTimeObserver(_progressObserver)
            _progressObserver = nil
        }
        
        init?(every interval: TimeInterval, metadata: MetaData, player: AVPlayer?, block: ProgressBlock? = nil) {
            guard let duration = metadata.duration else {
                return nil
            }
            _interval = interval
            _progressBlock = block
            _offset = (metadata.offset ?? 0.0) - (metadata.datumInterval ?? 0.0)
            print("OFFSET: \(_offset)")
            _duration = duration
            _counter = _offset
            _player = player
        }
        
        deinit {
            invalidate()
            print("TimingsObserver has been removed")
        }
    }
}
