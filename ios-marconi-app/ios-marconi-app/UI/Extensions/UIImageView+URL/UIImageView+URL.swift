//
//  UIImageView+URL.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 23.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit
import FutureKit
import SkeletonView

extension Future where Value == Data {
    @discardableResult
    func decode(into imageView: UIImageView) -> Future<Void> {
        let size = imageView.frame.size
        return transformed { data in
            let image = UIImage(data: data)
            let resizedImage = image?.resize(with: size)
            DispatchQueue.main.async {
                imageView.image = resizedImage
                imageView.hideSkeleton()
            }
        }
    }
}

extension UIImage {
    func resize(with size: CGSize) -> UIImage? {
        let imageSize: CGSize = size
        UIGraphicsBeginImageContextWithOptions(imageSize, true, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return optimizedImage
    }
}

extension UIImageView {
    func fetchImage(by url: URL) {
        showAnimatedSkeleton()
        ImageProvider().fetchImage(by: url)
                        .decode(into: self)
    }
}
