//
//  PlayingItem.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 30.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import ios_marconi_framework

struct DisplayItemNode {
    let title: String?
    let artistName: String?
    let stationName: String?
    let url: URL?
    
    init(_ item: Marconi.MetaData?, station: Station) {
        title = item?.song ?? "Unknown"
        artistName = item?.artist ?? "Unknown"
        stationName = station.name
        url = item?.imageUrl ?? URL(station.square_logo_large)
    }
}

extension DisplayItemNode: Equatable {
    static func == (lhs: DisplayItemNode, rhs: DisplayItemNode) -> Bool {
        return lhs.title == rhs.title &&
               lhs.artistName == rhs.artistName &&
               lhs.stationName == rhs.stationName
    }
}
