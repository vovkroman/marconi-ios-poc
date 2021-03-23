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
        
        typealias Model = StationPlaceholder
        
        private let _items: ContiguousArray<Model>
        private weak var _playerDelegate: MarconiPlayerDelegate?
        private let _provider: StationProvider = .init()
        
        private func _fetchStation(by id: Int) {
            _provider.fetch(by: id).observe { [weak self](result) in
                switch result {
                case .success(let station):
                    self?._processTheStation(station)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        private func _processTheStation(_ station: Station) {
            // if hls is not present in streams so skip it
            guard let hls = station.streams?.first(where: { $0.type == .m3u8 }) else {
                // TODO: - call delegate
                return
            }
            _playerDelegate?.willPlayStation(station, with: URL(string: hls.url + "?udid=10000343")!)
        }
        
        subscript(index: Int) -> Model? {
            return _items[safe: index]
        }

        var count: Int { return _items.count }
        
        func didSelected(at indexPath: IndexPath) {
            guard let stationPlaceHolder = _items[safe: indexPath.row] else { return }
            _fetchStation(by: stationPlaceHolder.id)
        }
        
        required init(_ playerDelegate: MarconiPlayerDelegate?) {
            _playerDelegate = playerDelegate
            _items = [.init(id: 1005, name: "ALT 92.3"),
                      .init(id: 395, name: "Your '70s Playlist"),
                      .init(id: 657, name: "The Cove")]
        }
    }
}


extension DigitalStations {
    class ViewModel: ListViewModelable {
        
        typealias Model = StationPlaceholder
        private weak var _playerDelegate: MarconiPlayerDelegate?
        private let _items: ContiguousArray<Model>
        
        subscript(index: Int) -> Model? {
            return _items[safe: index]
        }

        var count: Int { return _items.count }
        
        func didSelected(at indexPath: IndexPath) {
            print(_items[indexPath.row])
        }
        
        required init(_ playerDelegate: MarconiPlayerDelegate?) {
            _playerDelegate = playerDelegate
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
