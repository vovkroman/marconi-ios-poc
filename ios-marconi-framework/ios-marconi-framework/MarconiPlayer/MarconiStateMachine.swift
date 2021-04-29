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
    public enum MError: Equatable {
        case playerError(description: String?)
    }
}

extension Marconi {
    public final class StateMachine {
        
        public enum State: Equatable {
            case noPlaying
            case buffering(AVPlayerItem)
            case startPlaying(MetaData, Bool)
            case continuePlaying(MetaData, TimeInterval)
            case error(MError)
            
            public static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (noPlaying, noPlaying):
                    return true
                case (.buffering(let lhs), .buffering(let rhs)):
                    return lhs == rhs
                case (.error(let lhs), .error(let rhs)):
                    return lhs == rhs
                case (.continuePlaying(let lhsMeta, let lhsProgress), .continuePlaying(let rhsMeta, let rhsProgress)):
                    return lhsMeta == rhsMeta && lhsProgress.isEqual(to: rhsProgress)
                case (.startPlaying(let lhsMeta, let lhsIsNextTrack), .startPlaying(let rhsMeta, let rhsIsNextTrack)):
                    return lhsMeta == rhsMeta && lhsIsNextTrack == rhsIsNextTrack
                default:
                    return false
                }
            }
        }
        
        enum Event {
            case startPlaying
            case bufferingStarted(AVPlayerItem)
            case bufferingEnded(MetaData)
            // Progress is not rounded
            
            case newMetaHasCame(MetaData)
            case trackHasBeenChanged(MetaData)
            case progressDidChanged(progress: TimeInterval)
            
            case catchTheError(Error?)
        }
        
        weak var observer: MarconiPlayerObserver?
        
        private(set) var state: State = .noPlaying {
            didSet {
                guard oldValue != state else { return }
                //print("state: \(oldValue) -> \(state)")
                observer?.stateDidChanched(self, to: state)
            }
        }
        
        func transition(with event: Event) {
            switch (state, event) {
            case (.buffering, .bufferingStarted(_)): break
            case (_, .bufferingStarted(let playerItem)):
                state = .buffering(playerItem)
            case (.buffering, .bufferingEnded(let playingItem)):
                state = .startPlaying(playingItem, false)
            case (.buffering, .newMetaHasCame(_)):
                // fetched meta data but buffering still in progress
                break
            case (.startPlaying(let old, _), .newMetaHasCame(let new)):
                if old != new {
                    state = .startPlaying(new, false)
                }
            case (_, .bufferingEnded(let new)):
                state = .startPlaying(new, false)
            case (.noPlaying, .newMetaHasCame(_)): break
            case (_, .startPlaying): break
            case (.error, .catchTheError(_)): break
            case (_, .catchTheError(let error)):
                state = .error(.playerError(description: error?.localizedDescription))
            case (.error(_), .newMetaHasCame(let new)):
                state = .startPlaying(new, false)
            case (.startPlaying(let playingItem, _), .progressDidChanged(let progress)):
                state = .continuePlaying(playingItem, progress)
            case (.continuePlaying(_, _), .newMetaHasCame(let new)):
                state = .startPlaying(new, false)
            case (.continuePlaying(let meta, _), .progressDidChanged(let progress)):
                state = .continuePlaying(meta, progress)
            case (_, .progressDidChanged(_)):
                // if not playing there is no sense to update progress (state)
                break
            case (.continuePlaying(let old, _), .trackHasBeenChanged(let new)):
                if old != new {
                    state = .startPlaying(new, true)
                }
            case (_, .trackHasBeenChanged(_)): break
            }
        }
    }
}
