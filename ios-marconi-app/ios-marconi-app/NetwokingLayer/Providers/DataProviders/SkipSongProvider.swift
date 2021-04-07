//
//  SkipSongProvider.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 05.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation
import FutureKit

struct SkipSongProvider: ResponseValidator {
    
    private let _router: AnyRouter<SkipApi>
    
    func skip(stationId: Int, playId: String, trackId: String) -> Future<SkipEntity> {
        return _router.doRequest(.init(stationId: stationId, playId: playId, trackId: trackId))
                       .validateResponse(networkManager: self)
                       .decoded()
    }
    
    func cancel() {
        _router.cancel()
    }
    
    init(_ router: AnyRouter<SkipApi> = .init()) {
        _router = router
    }
}
