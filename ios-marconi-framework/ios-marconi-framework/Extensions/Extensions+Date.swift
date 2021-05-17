//
//  Extensions+Date.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 17.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}

extension String {
    var date: Date? {
        let dateFormatter = Marconi.dateFormatter
        return dateFormatter.date(from: self)
    }
}
