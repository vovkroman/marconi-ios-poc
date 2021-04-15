//
//  SkipSongProvider.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 05.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation
import FutureKit

struct SongProvider: ResponseValidator {
    
    private let _router: AnyRouter<SessionApi>
    
    func skip(stationId: Int, playId: String, trackId: String) -> Future<SkipEntity> {
        return _router.doRequest(.skip(song: .init(stationId: stationId, playId: playId, trackId: trackId)))
                       .validateResponse(networkManager: self)
                       .decoded()
    }
    
    func feedback(stationId: Int, playId: String, trackId: String, preference: Feedback) -> Future<PreferenceEntity> {
        return _router.doRequest(.preference(song: .init(stationId: stationId, playId: playId, trackId: trackId),
                                 feedback: preference))
                        .validateResponse(networkManager: self)
                        .decoded()
    }
    
    func cancel() {
        _router.cancel()
    }
    
    init(_ router: AnyRouter<SessionApi> = .init()) {
        _router = router
    }
}
