//
//  Storage.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 31.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        
        private static var prefix: String {
            return Bundle.main.bundleIdentifier ?? "" + ".settings"
        }
        
        case udid
        case offset(stationName: String)
        var prefixed: String { return Keys.prefix + ".\(self)" }
    }
}

extension UserDefaults.Keys: CustomStringConvertible {
    var description: String {
        switch self {
        case .udid: return "udid"
        case .offset(let stationName):
            return "\(stationName)/offset"
        }
    }
}

extension UserDefaults {
    static var udid: String {
        let key = Keys.udid.prefixed
        if let id = standard.string(forKey: key) {
            return id
        } else {
            let id = UUID().uuidString
            standard.set(id, forKey: key)
            return id
        }
    }
}


