//
//  Extensions+TimeInterval.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 11.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

func round(_ value: TimeInterval, toNearest: TimeInterval) -> TimeInterval {
    return round(value / toNearest) * toNearest
}
