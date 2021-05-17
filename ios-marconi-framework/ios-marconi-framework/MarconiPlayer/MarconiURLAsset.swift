//
//  MarconiURLAsset.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 14.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    final class URLAsset: AVURLAsset {

        init?(url URL: URL) {
            guard let newURL = URL.replace("marconi") else { return nil }
            super.init(url: newURL, options: nil)
        }
    }
}
