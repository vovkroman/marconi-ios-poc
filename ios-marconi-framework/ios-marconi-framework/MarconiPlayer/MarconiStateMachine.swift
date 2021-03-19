//
//  StateMachine.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

public enum Marconi {}

public protocol MarconiPlayerObserver: class {
    func stateDidChanched(_ stateMachine: Marconi.StateMachine, to: Marconi.StateMachine.State)
}

extension Marconi {
    public struct MetaData: Equatable {
        let albumArt: String?
        let stationInfo: String?
        let articst: String?
        let song: String?
    }
}

extension Marconi {
    public enum MError: Equatable {}
}

extension Marconi {
    public final class StateMachine {
        
        public enum State: Equatable {
            case noPlaying
            case buffering(AVPlayerItem)
            case playing(MetaData?)
            case error(MError)
            
            public static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (noPlaying, noPlaying):
                    return true
                case (.buffering(let lhs), .buffering(let rhs)):
                    return lhs == rhs
                case (.error(let lhs), .error(let rhs)):
                    return lhs == rhs
                case (.playing(let lhs), .playing(let rhs)):
                    return lhs == rhs
                default:
                    return false
                }
            }
        }
        
        enum Event {
            case bufferingStarted(AVPlayerItem)
            case bufferingEnded(MetaData?)
            case fetchedMetaData(MetaData)
            case catchTheError(Error?)
        }
        
        weak var observer: MarconiPlayerObserver?
        
        private(set) var state: State = .noPlaying {
            didSet {
                guard oldValue != state else { return }
                print("\(oldValue) -> \(state)")
                observer?.stateDidChanched(self, to: state)
            }
        }
        
        func transition(with event: Event) {
            switch (state, event) {
            case (.noPlaying, .bufferingStarted(let playerItem)):
                state = .buffering(playerItem)
            case (.buffering, .bufferingStarted(_)): break
            case (.buffering, .bufferingEnded(let playingItem)):
                state = .playing(playingItem)
            case (.buffering, .fetchedMetaData(let playingItem)):
                state = .playing(playingItem)
            case (_, _):
                break
            }
        }
    }
}
