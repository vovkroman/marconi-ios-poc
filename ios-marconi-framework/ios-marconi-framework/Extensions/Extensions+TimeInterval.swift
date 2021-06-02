//
//  Extensions+TimeInterval.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 27.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension TimeInterval {
    public var stringValue: String {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 5

        let number = NSNumber(value: self)
        return formatter.string(from: number) ?? "0.0"
    }
}
