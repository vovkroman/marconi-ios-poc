//
//  Collections+SafeIndex.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 22.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension ContiguousArray {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    subscript (safe index: Index) -> Element? {
        return 0 <= index && index < count ? self[index] : nil
    }
}
