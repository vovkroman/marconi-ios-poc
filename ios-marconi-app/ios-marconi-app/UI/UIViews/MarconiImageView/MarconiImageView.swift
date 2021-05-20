//
//  MarconiImageView.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 24.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import FutureKit
import SkeletonView

extension Future where Value == Data {
    func decodeImage() -> Future<UIImage> {
        transformed { data in
            autoreleasepool {
                return UIImage(data: data) ?? UIImage()
            }
        }
    }
}

extension Future where Value == UIImage {
    func cacheImage(into cache: ImageCacheType, by url: URL) -> Future<UIImage> {
        transformed { [weak cache] image in
            cache?.insertImage(image, for: url)
            return image
        }
    }
}

extension Future where Value == UIImage {
    @discardableResult
    func loadInto(into imageView: UIImageView, with size: CGSize) -> Future<Void> {
        return transformed { [weak imageView] image in
            let resizedImage = image.resize(with: size)
            DispatchQueue.main.async {
                imageView?.hideSkeleton()
                imageView?.image = resizedImage
            }
        }
    }
}

extension UIImage {
    func resize(with size: CGSize) -> UIImage? {
        return autoreleasepool {
            let imageSize: CGSize = size
            defer {
                UIGraphicsEndImageContext()
            }
            UIGraphicsBeginImageContextWithOptions(imageSize, true, UIScreen.main.scale)
            draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            return resizedImage
        }
    }
    
    // Rough estimation of how much memory image uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

final class MarconiImageView: UIImageView {
    
    private lazy var _provider: ImageProvider = .init()
    
    func loadImage(from url: URL?) {
        guard let url = url else { return }
        let size = frame.size
        if !isSkeletonActive { showAnimatedSkeleton() }
        _provider.fetchImage(by: url)
                  .loadInto(into: self, with: size)
    }
    
    func cancelLoading() {
        image = nil
        _provider.cancel()
    }
}
