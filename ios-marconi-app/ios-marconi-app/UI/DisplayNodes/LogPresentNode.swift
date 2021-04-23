//
//  LogPresentNode.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 14.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct LogPresentNode {
    private let _event: LoggerEvent
    private let _dateString: String
    
    init(event: LoggerEvent, dateString: String) {
        _event = event
        _dateString = dateString
    }
}

extension LogPresentNode: Titlable, DateSupportable {
    var title: String {
        return _event.title
    }
    
     var date: String {
        return _dateString
    }
}

extension LogPresentNode: Equatable {
    static func == (lhs: LogPresentNode, rhs: LogPresentNode) -> Bool {
        return lhs.title == rhs.title && lhs._dateString == rhs._dateString
    }
    
    
}
