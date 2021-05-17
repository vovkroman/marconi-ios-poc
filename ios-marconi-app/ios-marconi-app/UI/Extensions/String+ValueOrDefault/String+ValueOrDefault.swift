//
//  String+NilOrEmpty.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 17.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    
    func valueOrDefault(_ value: String) -> String {
        guard let nilValue = self, !nilValue.isEmpty else {
            return value
        }
        return nilValue
    }
}
