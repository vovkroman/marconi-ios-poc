//
//  LiveStationsViewModel.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

enum LiveStations {}
enum DigitalStations {}

extension LiveStations {
    class ViewModel: ListViewModelable {
        
        typealias Model = StationHolder
        
        private let _items: ContiguousArray<Model>
        
        private let _provider: StationProvider = .init()
        
        subscript(index: Int) -> Model {
            return _items[index]
        }

        var count: Int { return _items.count }
        
        required init() {
            _items = [.init(id: 1005, name: "ALT 92.3"),
                      .init(id: 395, name: "Your '70s Playlist"),
                      .init(id: 657, name: "The Cove")]
        }
    }

}


extension DigitalStations {
    class ViewModel: ListViewModelable {
        
        typealias Model = StationHolder
        
        private let _items: ContiguousArray<Model>
        
        subscript(index: Int) -> Model {
            return _items[index]
        }

        var count: Int { return _items.count }
        
        required init() {
            _items = [.init(id: 2395, name: "Women of Alt"),
                      .init(id: 2396, name: "Ladies of Country"),
                      .init(id: 2401, name: "Slow Jams"),
                      .init(id: 2402, name: "Lighters in the Air"),
                      .init(id: 2404, name: "Post Modern ALT"),
                      .init(id: 2405, name: "New Wave Mix tape"),
                      .init(id: 2406, name: "One Hit Wonders")
            ]
        }
    }

}
