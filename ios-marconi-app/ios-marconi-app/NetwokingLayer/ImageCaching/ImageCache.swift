//
//  ImageCache.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 24.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit.UIImage

// Declares in-memory image cache
public protocol ImageCacheType: class {
    // Returns the image associated with a given url
    func fetchImage(for url: URL) -> UIImage?
    // Inserts the image of the specified url in the cache
    func insertImage(_ image: UIImage?, for url: URL)
    // Removes the image of the specified url in the cache
    func removeImage(for url: URL)
    // Removes all images from the cache
    func removeAllImages()
    // Accesses the value associated with the given key for reading and writing
    subscript(_ url: URL) -> UIImage? { get set }
}

final class ImageCache: ImageCacheType {
    
    private lazy var _imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = _config.countLimit
        return cache
    }()
    
    private let _lock = NSLock()
    private let _config: Config
    
    struct Config {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }
    
    init(config: Config = Config.defaultConfig) {
        self._config = config
    }
    
    func fetchImage(for url: URL) -> UIImage? {
        return autoreleasepool {
            _lock.lock()
            defer { _lock.unlock() }
            // the best case scenario -> there is a decoded image in memory
            if let image = _imageCache.object(forKey: url as AnyObject) as? UIImage {
                return image
            }
            return nil
        }
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else {
            removeImage(for: url)
            return
        }
        _imageCache.setObject(image, forKey: url as AnyObject, cost: image.diskSize)
    }
    
    func removeImage(for url: URL) {
        _lock.lock()
        defer { _lock.unlock() }
        _imageCache.removeObject(forKey: url as AnyObject)
    }
    
    func removeAllImages() {
        _lock.lock()
        defer { _lock.unlock() }
        _imageCache.removeAllObjects()
    }
    
    subscript(_ key: URL) -> UIImage? {
        get {
            return fetchImage(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}
