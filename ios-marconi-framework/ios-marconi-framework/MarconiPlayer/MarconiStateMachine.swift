//
//  StateMachine.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

public enum Marconi {}

extension Marconi {
    enum MError: Equatable {}
}

protocol StateMachineObserver: class {
    func stateDidChanched(from: Marconi.StateMachine.State, to: Marconi.StateMachine.State)
}

extension Marconi {
    final class StateMachine {
        
        enum State: Equatable {
            case idle
            case buffering(AVPlayerItem)
            case playing()
            case error(MError)
            
            static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (idle, idle):
                    return true
                case (.buffering(let lhs), .buffering(let rhs)):
                    return lhs == rhs
                case (.error(let lhs), .error(let rhs)):
                    return lhs == rhs
                default:
                    return false
                }
            }
        }
        
        enum Event {
            case bufferingStarted
        }
        
        weak var observer: StateMachineObserver?
        
        private(set) var state: State = .idle {
            didSet {
                guard oldValue != state else { return }
                observer?.stateDidChanched(from: oldValue, to: state)
            }
        }
        
        func transition(with event: Event) {
            switch (state, event) {case (_, _):
                break
                //
            }
        }
    }
}
