//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    public class MarconiTimer {
        
        typealias ProgressBlock = (TimeInterval) -> ()
        
        private var _timer: Timer?
        private let _workerQueue: DispatchQueue = .main
        
        private let _duration: TimeInterval
        private var _offset: TimeInterval {
            didSet {
                if _offset > _duration {
                    _offset = 0.0
                }
            }
        }
        
        private let _interval: TimeInterval
        private var _progressBlock: ProgressBlock?
        
        private var _isRunning: Bool {
            guard let timer = _timer else { return false }
            return timer.isValid
        }
        
        private func _registerTimer() {
            _timer = WeakTimer.scheduledTimer(timeInterval: _interval,
                                              target: self,
                                              repeats: true,
                                              action: _running)
            RunLoop.current.add(_timer!, forMode: RunLoop.Mode.common)
        }
        
        private func _running(_ timer: Timer) {
            _offset += timer.timeInterval
            _progressBlock?(_offset)
        }
        
        public func start() {
            _workerQueue.async(execute: _registerTimer)
        }
        
        public func pause() {
            if _isRunning { _workerQueue.async(execute: invalidate) }
        }
        
        public func invalidate() {
            _timer?.invalidate()
            _timer = nil
        }
        
        init(every interval: TimeInterval, with offset: TimeInterval?, duration: TimeInterval, block: ProgressBlock? = nil ) {
            _progressBlock = block
            _interval = interval
            _offset = offset ?? 0.0
            _duration = duration
        }
        
        deinit {
            print("Marconi Timer has been deinit")
        }
    }
}
