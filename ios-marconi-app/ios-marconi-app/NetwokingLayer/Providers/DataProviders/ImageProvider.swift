//
//  ImageProvider.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit.UIImage
import FutureKit

struct ImageProvider: ResponseValidator {
    
    private let _router: AnyRouter<ImageApi>
    private let _imageLoader: ImageLoader = .shared
    
    func fetchImage(by url: URL) -> Future<UIImage> {
        guard let future = _imageLoader.loadFromCache(from: url) else {
            return _router.doRequest(.init(url: url))
                            .validateResponse(networkManager: self)
                            .decodeImage()
                        .cacheImage(into: _imageLoader.cache, by: url)
        }
        return future
    }
    
    func cancel() {
        _router.cancel()
    }
    
    init(_ router: AnyRouter<ImageApi> = .init()) {
        _router = router
    }
}
