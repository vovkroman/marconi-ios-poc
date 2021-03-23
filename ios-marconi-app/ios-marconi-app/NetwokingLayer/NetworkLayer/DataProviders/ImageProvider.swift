//
//  ImageProvider.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation
import FutureKit

class ImageProvider: ResponseValidator {
    
    private let _router: AnyRouter<ImageApi>
    
    func fetchImage(by url: URL) -> Future<Data> {
        return _router.doRequest(.init(url: url))
                      .validateResponse(networkManager: self)
    }
    
    init(_ router: AnyRouter<ImageApi> = .init()) {
        _router = router
    }
}
