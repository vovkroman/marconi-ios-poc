//
//  LiveStationsViewModel.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

// To distinguish by station type
enum Live {}
enum Digital {}
enum Rewind {}

struct StationWrapper {    
    let station: Station
    let type: StationType
}

extension StationWrapper {
    typealias ProgressData = (progress: TimeInterval?, playId: String?)
    func saveCurrent(progressData: ProgressData) {
        if case .digit = type {
            
            // please user's seen none second of asset, repeated request will no return meta data
            // that's why set the default value 1.0s
            // TODO: Clarify this moment with Tony
            let progress = progressData.progress ?? 0.0 //else { return }
            UserDefaults.saveProgress(progress.stringValue, for: station)
            
            if let playId = progressData.playId {
                UserDefaults.savePlayId(playId, for: station)
                Log.debug("Saved \(progress) progress by playId: \(playId)", category: .default)
            }
        }
    }
}

class BaseListViewModel: ListViewModelable {
    typealias Model = StationPlaceholder
    
    var items: ContiguousArray<Model>
    
    private(set) weak var _playerDelegate: MarconiPlayerDelegate?
    private let _provider: StationProvider = .init()
    
    private func _fetchStation(by id: Int) {
        _provider.cancel()
        _provider.fetch(by: id).observe { [weak self](result) in
            switch result {
            case .success(let station):
                self?.processTheStation(station)
            case .failure(let error):
                Log.error(error.localizedDescription, category: .api)
                self?._playerDelegate?.catchTheError(error)
            }
        }
    }
    
    func processTheStation(_ station: Station) {
        //fatalError("method should be overrided")
    }
    
    subscript(index: Int) -> Model? {
        return items[safe: index]
    }
    
    func didSelected(at indexPath: IndexPath) {
        guard let stationPlaceHolder = items[safe: indexPath.row] else { return }
        _fetchStation(by: stationPlaceHolder.id)
    }
    
    required init(_ playerDelegate: MarconiPlayerDelegate?) {
        self._playerDelegate = playerDelegate
        self.items = []
    }
}

extension Live {
    
    class ViewModel: BaseListViewModel {
        override func processTheStation(_ station: Station) {
            // if hls is not present in streams so skip it
            guard let hls = station.streams?.first(where: { $0.type == .m3u8 }) else {
                _playerDelegate?.catchTheError(ErrorType.noHls(stationName: station.name))
                return
            }
            _playerDelegate?.willPlayStation(StationWrapper(station: station, type: .live),
                                             with: URL(string: hls.url + "?udid=\(UserDefaults.udid)"))
        }
        
        required init(_ playerDelegate: MarconiPlayerDelegate?) {
            super.init(playerDelegate)
            items = [.init(id: 1005, name: "ALT 92.3"),
                      .init(id: 349, name: "KROQ"),
                      .init(id: 395, name: "Your '70s Playlist"),
                      .init(id: 657, name: "The Cove")]
        }
    }
}

extension Digital {
    class ViewModel: BaseListViewModel {
        
        override func processTheStation(_ station: Station) {
            var digitalUrl = "https://smartstreams.radio-stg.com/stream/\(station.id)/manifest/digitalstations/playlist.m3u8?udid=\(UserDefaults.udid)"
            if let playlistOffset = UserDefaults.progress(by: station) {
                digitalUrl += "&playlistOffset=\(playlistOffset)"
            }
            if let playId = UserDefaults.playId(by: station) {
                digitalUrl += "&playId=\(playId)"
            }
            print("digitalUrl: \(digitalUrl)")
            _playerDelegate?.willPlayStation(StationWrapper(station: station, type: .digit),
                                             with: URL(string: digitalUrl))
        }
        
        required init(_ playerDelegate: MarconiPlayerDelegate?) {
            super.init(playerDelegate)
            items = [.init(id: 2395, name: "Women of Alt"),
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

extension Rewind {
    class ViewModel: BaseListViewModel {
        
        override func processTheStation(_ station: Station) {}
        
        required init(_ playerDelegate: MarconiPlayerDelegate?) {
            super.init(playerDelegate)
        }
    }
}
