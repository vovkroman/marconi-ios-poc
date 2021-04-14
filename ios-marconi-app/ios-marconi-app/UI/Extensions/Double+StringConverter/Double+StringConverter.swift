//
//  Double+StringConverter.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 07.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Double {
    var stringValue: String {
        let formatter = NumberFormatter()
        return formatter.string(from: NSNumber(value: self)) ?? "1"
    }
}
