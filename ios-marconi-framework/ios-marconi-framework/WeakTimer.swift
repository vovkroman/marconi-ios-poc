//
//  MarconiTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 08.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

//Swift implementation of weak timer which automatically deallocates when target is released.
final class WeakTimer {
    
    private weak var _timer: Timer?
    private weak var _target: AnyObject?
    private let action: (Timer) -> Void
    
    init(timeInterval: TimeInterval,
                     target: AnyObject,
                     repeats: Bool,
                     action: @escaping (Timer) -> Void) {
        self._target = target
        self.action = action
        self._timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(_fire),
                                          userInfo: nil,
                                          repeats: repeats)
    }
    
    class func scheduledTimer(timeInterval: TimeInterval,
                              target: AnyObject,
                              repeats: Bool,
                              action: @escaping (Timer) -> Void) -> Timer {
        return WeakTimer(timeInterval: timeInterval,
                         target: target,
                         repeats: repeats,
                         action: action)._timer!
    }
    
    @objc private func _fire(timer: Timer) {
        if _target != nil {
            action(timer)
        } else {
            timer.invalidate()
        }
    }
    
    deinit {
        print("Timer deinit")
    }
}
