//
//  WeakTimer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

final class WeakTimer {
    
    private weak var timer: Timer?
    private weak var target: AnyObject?
    private let action: (Timer) -> Void
    
    private init(timeInterval: TimeInterval,
                     target: AnyObject,
                     repeats: Bool,
                     action: @escaping (Timer) -> Void) {
        self.target = target
        self.action = action
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(fire),
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
                         action: action).timer!
    }
    
    @objc private func fire(timer: Timer) {
        if target != nil {
            action(timer)
        } else {
            timer.invalidate()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
