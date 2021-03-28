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
    public enum Live {}
    public enum Digit {}
}

extension Marconi {
    static let indentifierPlayId = AVMetadataIdentifier("lsdr/X-PLAY-ID")
    static let indentifierType = AVMetadataIdentifier("lsdr/X-TYPE")
    static let indentifierArtistName = AVMetadataIdentifier("lsdr/X-ARTIST")
    static let indentifierTitle = AVMetadataIdentifier("lsdr/X-TITLE")
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
            case playing(MetaData?, TimeInterval?)
            case error(MError)
            
            public static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (noPlaying, noPlaying):
                    return true
                case (.buffering(let lhs), .buffering(let rhs)):
                    return lhs == rhs
                case (.error(let lhs), .error(let rhs)):
                    return lhs == rhs
                case (.playing(let lhsMeta, let lhsProgress), .playing(let rhsMeta, let rhsProgress)):
                    guard let rhsMeta = rhsMeta else { return true }
                    return lhsMeta == rhsMeta && lhsProgress == rhsProgress
                default:
                    return false
                }
            }
        }
        
        enum Event {
            case startPlaying
            case bufferingStarted(AVPlayerItem)
            case bufferingEnded(MetaData?)
            // Progress is rounded
            case progressDidChanged(progress: TimeInterval)
            case fetchedMetaData(MetaData?)
            case catchTheError(Error?)
        }
        
        weak var observer: MarconiPlayerObserver?
        
        private(set) var state: State = .noPlaying {
            didSet {
                guard oldValue != state else { return }
                observer?.stateDidChanched(self, to: state)
            }
        }
        
        func transition(with event: Event) {
            print("state: \(state) -> \(event)")
            switch (state, event) {
            case (.buffering, .bufferingStarted(_)): break
            case (_, .bufferingStarted(let playerItem)):
                state = .buffering(playerItem)
            case (.buffering, .bufferingEnded(let playingItem)):
                guard let offset = playingItem?.offset, let duartion = playingItem?.duration else {
                    state = .playing(playingItem, nil)
                    return
                }
                state = .playing(playingItem, offset / duartion)
            case (.buffering, .fetchedMetaData(_)):
                // fetched meta data but buffering still in progress
                break
            case (.playing(_ , _), .fetchedMetaData(let new)):
                state = .playing(new, new?.offset)
            case (_, .bufferingEnded(let playingItem)):
                state = .playing(playingItem, playingItem?.offset)
            case (.noPlaying, .fetchedMetaData(_)): break
            case (_, .startPlaying): break
            case (_, .catchTheError(let error)):
                state = .error(.playerError(description: error?.localizedDescription))
            case (.error(_), .fetchedMetaData(let playingItem)):
                // if playingItem doesn't conatin duration or offset, most likely, it's Live Station
                guard let offset = playingItem?.offset, let duration = playingItem?.duration else {
                    state = .playing(playingItem, nil)
                    return
                }
                state = .playing(playingItem, offset / duration)
            case (.playing(let playingItem, _), .progressDidChanged(let progress)):
                guard let duration = playingItem?.duration else {
                    state = .playing(playingItem, nil)
                    return
                }
                state = .playing(playingItem, progress / duration)
            case (_, .progressDidChanged(_)):
                // if not playing there is no sense to update progress (state)
                break
            }
        }
    }
}
