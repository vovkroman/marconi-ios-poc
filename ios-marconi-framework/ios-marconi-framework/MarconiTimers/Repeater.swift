//
//  Repeater.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 28.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    
    class Repeater {
        typealias Action = () -> Void
        
        private var _timer: Timer?
        private let _interval: TimeInterval
        private var _duration: TimeInterval
        
        private var _fire: Action?
        
        // MARK: - Operate
        
        private var _isRunning: Bool {
            guard let timer = _timer, timer.isValid else { return false }
            return true
        }
        
        func start() {
            _registerTimer()
        }
        
        func pause() {
            if !_isRunning { return }
            _timer?.invalidate()
        }
        
        func resume() {
            if _isRunning { return }
            start()
        }
        
        func cancel() {
            _reset()
        }
        
        private func _invoke(timer: Timer) {
            if _duration > 0.0 {
                _fire?()
                _duration -= _interval
            } else {
                cancel()
            }
        }
        
        // MARK: - Timer
        private func _registerTimer() {
            _timer = WeakTimer.scheduledTimer(timeInterval: _interval,
                                              target: self,
                                              repeats: true,
                                              action: _invoke)
            RunLoop.current.add(_timer!, forMode: .common)
        }
        
        private func _reset() {
            _timer?.invalidate()
            _timer = nil
        }
        
        init(every timeInterval: TimeInterval, duration: TimeInterval, fireAction: Action? = nil) {
            _interval = timeInterval
            _duration = duration
            _fire = fireAction
        }
    }
}
