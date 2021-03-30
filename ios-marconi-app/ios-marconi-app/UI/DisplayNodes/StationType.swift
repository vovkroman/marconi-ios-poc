//
//  StationType.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 30.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

enum StationType {
    case live
    case digit
}

extension StationType: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        switch value {
        case 0:
            self = .live
        default:
            self = .digit
        }
    }
}
