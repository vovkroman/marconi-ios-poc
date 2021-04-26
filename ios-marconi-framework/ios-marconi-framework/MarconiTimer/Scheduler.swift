//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    
    class Scheduler {
        
        typealias Action = () -> Void
        
        private var _timer: Timer?
        private var _duration: TimeInterval = 0.0
        private var _currentDuration: TimeInterval = 0.0
        
        var fire: Action?
        
        // MARK: - operate
        func start(at startDate: Date) {
            _registerTimer(with: startDate)
        }
        
        func pause(at pauseDate: Date = Date()) {
            if !_isRunning(at: pauseDate) { return }
            
            _currentDuration = _remainingDuration(at: pauseDate)
            _timer?.invalidate()
        }
        
        func resume(at resumeDate: Date = Date()) {
            if _isRunning(at: resumeDate) { return }
            if _remainingDuration(at: resumeDate) == 0 { return }
            _registerTimer(with: resumeDate)
        }
        
        func cancel() {
            _reset()
        }
        
        private func _set(_ duration: TimeInterval) {
            _duration = duration
            _currentDuration = duration
        }
        
        private func _isRunning(at now: Date = Date()) -> Bool {
            guard let timer = _timer, timer.isValid else { return false }
            return _remainingDuration(at: now) > 0.0
        }
        
        private func _remainingDuration(at now: Date = Date()) -> TimeInterval {
            guard let timer = _timer, timer.isValid else {
                return _currentDuration
            }
            
            let elapsedDuration: TimeInterval = now.timeIntervalSince(timer.fireDate)
            let remainingDuration: TimeInterval = _currentDuration - elapsedDuration
            
            return remainingDuration < 0.0 ? 0.0 : remainingDuration
        }
        
        private func _invoke(timer: Timer) {
            fire?()
        }
        
        // MARK: - Timer
        private func _registerTimer(with startDate: Date) {
            let interval = startDate.timeIntervalSinceNow
            _timer = WeakTimer.scheduledTimer(timeInterval: interval,
                                              target: self,
                                              repeats: false,
                                              action: _invoke)
            _set(interval)
            RunLoop.current.add(_timer!, forMode: .common)
        }
        
        private func _reset() {
            _currentDuration = _duration
            _timer?.invalidate()
        }
    }
}
