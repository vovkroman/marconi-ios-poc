//
//  ImageLoader.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 24.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import FutureKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    private let _cache: ImageCacheType
    
    var cache: ImageCacheType { return _cache }
    
    private init(cache: ImageCacheType = ImageCache()) {
        self._cache = cache
    }

    func loadFromCache(from url: URL) -> Future<UIImage>? {
        if let image = _cache[url] {
            return Promise(value: image)
        }
        return nil
    }
}
