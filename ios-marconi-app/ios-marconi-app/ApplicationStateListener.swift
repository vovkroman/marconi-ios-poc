//
//  ApplicationStateListener.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 07.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

protocol ApplicationStateListenerDelegate: class {
    func onApplicationStateChanged(_ newState: ApplicationState)
}

enum ApplicationState {
    case willEnterForeground
    case didEnterBackground
    case willResignActive
    case didBecomeActive
    case willTerminate
}

/// Listens for application state change events and notifies delegate when they happen
///
class ApplicationStateListener {
    // MARK: - properties
    weak var delegate: ApplicationStateListenerDelegate?
    
    // MARK: - public interface
    
    public init() {
        startListening()
    }
    
    deinit {
        stopListening()
    }
    
    public func startListening() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    public func stopListening() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - notifcations callbacks
    @objc fileprivate func onApplicationDidEnterBackground() {
        delegate?.onApplicationStateChanged(.didEnterBackground)
    }
    
    @objc fileprivate func onApplicationWillEnterForeground() {
        delegate?.onApplicationStateChanged(.willEnterForeground)
    }
    
    @objc fileprivate func onApplicationWillResignActive() {
        delegate?.onApplicationStateChanged(.willResignActive)
    }
    
    @objc fileprivate func onApplicationDidBecomeActive() {
        delegate?.onApplicationStateChanged(.didBecomeActive)
    }
    
    @objc fileprivate func onApplicationWillTerminate() {
        delegate?.onApplicationStateChanged(.willTerminate)
    }
}
