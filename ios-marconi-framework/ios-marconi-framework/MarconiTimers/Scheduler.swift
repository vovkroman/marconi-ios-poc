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
        private var _currentDuration: TimeInterval = 0.0
        
        private var _fire: Action?
        
        // MARK: - Operate
        
        private var _isRunning: Bool {
            guard let timer = _timer, timer.isValid else { return false }
            return _remainingDuration() > 0.0
        }
        
        func start(at startDate: Date) {
            let timeInterval = startDate.timeIntervalSinceNow
            _registerTimer(in: timeInterval)
        }
        
        func pause() {
            if !_isRunning { return }
            
            _currentDuration = _remainingDuration()
            _timer?.invalidate()
        }
        
        func resume() {
            if _isRunning { return }
            if _remainingDuration() == 0.0 { return }
            _registerTimer(in: _currentDuration)
        }
        
        func cancel() {
            _reset()
        }
        
        private func _remainingDuration() -> TimeInterval {
            guard let timer = _timer, timer.isValid else {
                return _currentDuration
            }
            
            let remainingDuration = timer.fireDate.timeIntervalSinceNow
            return remainingDuration < 0.0 ? 0.0 : remainingDuration
        }
        
        private func _invoke(timer: Timer) {
            _fire?()
        }
        
        // MARK: - Timer
        private func _registerTimer(in interval: TimeInterval) {
            _timer = WeakTimer.scheduledTimer(timeInterval: interval,
                                              target: self,
                                              repeats: false,
                                              action: _invoke)
            RunLoop.current.add(_timer!, forMode: .common)
        }
        
        private func _reset() {
            _timer?.invalidate()
            _timer = nil
        }
        
        init(_ fireAction: Action? = nil) {
            _fire = fireAction
        }
    }
}
