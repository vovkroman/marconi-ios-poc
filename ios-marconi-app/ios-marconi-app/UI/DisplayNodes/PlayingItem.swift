//
//  PlayingItem.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 30.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import ios_marconi_framework

struct PlayingItem {
    let title: String?
    let artistName: String?
    let stationName: String?
    let url: URL?
    
    init(_ item: Marconi.MetaData?, station: Station) {
        title = item?.song
        artistName = item?.artistName
        stationName = station.name
        url = URL(station.square_logo_large)
    }
}

extension PlayingItem: Equatable {
    static func == (lhs: PlayingItem, rhs: PlayingItem) -> Bool {
        return lhs.title == rhs.title &&
               lhs.artistName == rhs.artistName &&
               lhs.stationName == rhs.stationName
    }
}
