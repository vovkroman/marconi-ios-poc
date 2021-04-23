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
        case offset(stationId: Int)
        case playId(stationId: Int)
        
        var prefixed: String { return Keys.prefix + ".\(self)" }
    }
}

extension UserDefaults.Keys: CustomStringConvertible {
    var description: String {
        switch self {
        case .udid: return "udid"
        case .offset(let stationID):
            return "\(stationID)/playlistOffset/"
        case .playId(let stationID):
            return "\(stationID)/playId/"
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
            standard.synchronize()
            return id
        }
    }
    
    // Save Progress
    static func saveProgress(_ value: String, for station: Station) {
        let key = Keys.offset(stationId: station.id)
        standard.set(value, forKey: key.prefixed)
        standard.synchronize()
    }
    
    static func progress(by station: Station) -> String? {
        let key = Keys.offset(stationId: station.id)
        return standard.string(forKey: key.prefixed)
    }
    
    // Save PlayId
    static func savePlayId(_ value: String, for station: Station) {
        let key = Keys.playId(stationId: station.id)
        standard.set(value, forKey: key.prefixed)
        standard.synchronize()
    }
    
    static func playId(by station: Station) -> String? {
        let key = Keys.playId(stationId: station.id)
        return standard.string(forKey: key.prefixed)
    }
    
    static func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        standard.removePersistentDomain(forName: domain)
        standard.synchronize()
    }
}


