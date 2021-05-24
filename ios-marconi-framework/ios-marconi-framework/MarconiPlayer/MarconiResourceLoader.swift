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
    var currentProgress: TimeInterval? { get }
    func playlistHasBeenLoaded(_ playlist: Marconi.Playlist) throws
}

extension Marconi {
    
    final class ResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
        
        private weak var _delegate: PlaylistLoaderDelegate?
        private let _session: URLSession
        
        public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                                   shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            guard var url = loadingRequest.request.url else {
                loadingRequest.finishLoading(with: MError.loaderError(description: "Unable to read the url/host data."))
                return false
            }
            
            if let streamProgress = _delegate?.currentProgress {
                url = url.updateQueryParams(key: "playlistOffset", value: String(format: "%.2f", streamProgress))
            }
            
            if let url = url.replace("https") {
                print("Loading \(url)")
                _loadMasterManifest(by: url, loadingRequest: loadingRequest)
            } else {
                loadingRequest.finishLoading(with: MError.loaderError(description: "Invalid url: \(String(describing: url))"))
                return false
            }
            return true
        }
        
        private func _loadMasterManifest(by url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
            let request = URLRequest(url: url)
            let task = _session.dataTask(with: request) { [weak self] (data, response, error) in
                if let error = error {
                    loadingRequest.finishLoading(with: MError.loaderError(description: "\(request) failed load master manifset with \(error)"))
                    return
                }
                if let data = data {
                    let manifestContent = String(decoding: data, as: UTF8.self)
                    let masterParser = MasterManifestParser(manifestContent)
                    do {
                        try masterParser.parse()
                        guard let url = masterParser.playlists.first else {
                            throw MError.loaderError(description: "There is no playlist url")
                        }
                        self?._loadPlaylistManifest(by: url, loadingRequest: loadingRequest)
                    } catch let error {
                        loadingRequest.finishLoading(with: MError.loaderError(description: "Failed parse master manifest error: \(error.localizedDescription)"))
                    }
                }
            }
            task.resume()
        }
        
        private func _loadPlaylistManifest(by url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
            let request = URLRequest(url: url)
            print("Load PlaylistManifest by url: \(url)")
            let task = _session.dataTask(with: request) { [weak self] (data, response, error) in
                if let data = data {
                    let manifestContent = String(decoding: data, as: UTF8.self)
                    let playlistManifest = MediaManifestParser(manifestContent)
                    
                    playlistManifest.parse()
                    
                    try? self?._delegate?.playlistHasBeenLoaded(playlistManifest.playlist)
                    
                    loadingRequest.contentInformationRequest?.contentType = response?.mimeType
                    loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
                    loadingRequest.contentInformationRequest?.contentLength = response!.expectedContentLength
                    loadingRequest.dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                } else {
                    loadingRequest.finishLoading(with: MError.loaderError(description: "Failed to load playlist manifest"))
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
