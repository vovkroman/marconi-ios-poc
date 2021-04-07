//
//  UIImage+SolidColor.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 07.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit.UIImage

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
