//
//  MarconiResourceLoader.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 13.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlaylistLoaderDelegate: class {
    func playlistHasBeenLoaded(_ playlist: Marconi.Playlist) throws
    func playlistLoaded(with error: Error)
}

extension Marconi {
    
    final class ResourceLoader: NSObject {
        
        private weak var _delegate: PlaylistLoaderDelegate?
        private let _session: URLSession

        public func loadResource(by url: URL) {
            _loadMasterManifest(by: url)
        }
        
        private func _loadMasterManifest(by url: URL) {
            let request = URLRequest(url: url)
            let task = _session.dataTask(with: request) { [weak self] (data, _, error) in
                if let error = error {
                    self?._delegate?.playlistLoaded(with: MError.loaderError(description: error.localizedDescription))
                    return
                }
                if let data = data {
                    let manifestContent = String(decoding: data, as: UTF8.self)
                    let masterParser = MasterManigestParser(manifestContent)
                    do {
                        try masterParser.parse()
                        guard let url = masterParser.playlists.first else {
                            throw MError.loaderError(description: "There is no playlist url")
                        }
                        let mediaManifest = try MediaManifestParser(url)
                        mediaManifest.parse()
                        
                        try self?._delegate?.playlistHasBeenLoaded(mediaManifest.playlist)
                    } catch let error {
                        self?._delegate?.playlistLoaded(with: MError.loaderError(description: error.localizedDescription))
                        return
                    }
                } else {
                    self?._delegate?.playlistLoaded(with: MError.loaderError(description: "Data for master manifset is nil"))
                    return
                }
            }
            task.resume()
        }
        
        deinit {
            print("ResourceLoader has been removed")
        }
        
        init(_ delegate: PlaylistLoaderDelegate?, session: URLSession = .shared) {
            _delegate = delegate
            _session = session
        }
    }
}
