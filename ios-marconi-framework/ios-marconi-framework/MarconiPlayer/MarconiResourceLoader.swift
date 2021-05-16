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
}

extension Marconi {
    
    final class ResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
        
        private weak var _delegate: PlaylistLoaderDelegate?
        private let _session: URLSession

        public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                                   shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            guard let url = loadingRequest.request.url else {
                loadingRequest.finishLoading(with: MError.loaderError(description: "Unable to read the url/host data."))
                return false
            }
            let baseURL = url.replace("https")
            if let url = baseURL {
                _loadResource(by: url, loadingRequest: loadingRequest)
            } else {
                loadingRequest.finishLoading(with: MError.loaderError(description: "Invalid url: \(String(describing: baseURL))"))
                return false
            }
            return true
        }
        
        private func _loadResource(by url: URL, loadingRequest: AVAssetResourceLoadingRequest?) {
            let request = URLRequest(url: url)
            let task = _session.dataTask(with: request) { [weak self] (data, responce, error) in
                if let error = error {
                    loadingRequest?.finishLoading(with: MError.loaderError(description: "\(request) failed with error \(error)"))
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
                        
                        loadingRequest?.dataRequest?.respond(with: data)
                        loadingRequest?.finishLoading()
                    } catch {
                        loadingRequest?.dataRequest?.respond(with: data)
                        loadingRequest?.finishLoading()
                        return
                    }
                } else {
                    loadingRequest?.finishLoading(with: MError.loaderError(description: "Unable to fetch manifest"))
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
