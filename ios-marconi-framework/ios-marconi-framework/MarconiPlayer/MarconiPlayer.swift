//
//  MarconiPlayer.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

extension Marconi {
    
    public class Player: AVPlayer {
        
        private var _observer: PlayerObserver?
        private var _resourceLoader: ResourceLoader?
        
        public var _currentURL: URL?
        
        public var streamProgress: TimeInterval {
            return _observer?.streamProgress ?? 0.0
        }
        
        public var playId: String? {
            return _observer?.currentMetaItem.playId
        }
        
        public func replaceCurrentURL(with url: URL, stationType: StationType) {
            guard let asset = URLAsset(url: url) else { return }
            
            _currentURL = url
            _observer?.stopMonitoring()
            if currentItem != nil { replaceCurrentItem(with: nil) }
            _resourceLoader = ResourceLoader(_observer)
            asset.resourceLoader.setDelegate(_resourceLoader, queue: .main)
            let playingItem = AVPlayerItem(asset: asset)

            // we need to know *station type* to know how to map paylaod
            self._observer?.startMonitoring(playingItem, stationType: stationType)
            super.replaceCurrentItem(with: playingItem)
            super.play()
        }
        
        public func restore(with url: URL) {
            let url = url.updateQueryParams(key: "playlistOffset", value: "\(streamProgress)")
            print(url)
            _observer?.stopMonitoring()
            
            let playingItem = AVPlayerItem(url: url)
            _observer?.startMonitoring(playingItem)
            super.replaceCurrentItem(with: playingItem)
        }
        
        public init(_ observer: MarconiPlayerObserver?) {
            // if observer doesn't exist, then the player behaves the same way as AVPlayer
            if let observer = observer {
                _observer = .init(observer)
            }
            super.init()
            _observer?.setPlayer(self)
        }
        
        public override func play() {
            _currentURL.flatMap(restore)
        }
        
        public override func pause() {
            if isPlaying {
                stop()
            }
            super.pause()
        }
        
        deinit {
            print("\(self) has been removed")
        }
    }
}

extension Marconi.Player: AVAssetResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                               shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else {
            print("🔑", #function, "Unable to read the url/host data.")
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -1, userInfo: nil))
            return false
        }
        ////////////////
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components!.scheme = "https"
        let baseURL = components?.url
        ////////////////
        if let url = baseURL {
            let request = URLRequest(url: url)
            print(request)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, responce, error) in
                if let data = data {
                    let string = String(decoding: data, as: UTF8.self)
                    // The CKC is correctly returned and is now send to the `AVPlayer` instance so we
                    // can continue to play the stream.
                    print("DATA: \(string)")
                    
                    print(responce!.expectedContentLength)
                    
                    print(loadingRequest.dataRequest?.requestedLength)
                    loadingRequest.contentInformationRequest!.isByteRangeAccessSupported = true
                    loadingRequest.contentInformationRequest!.contentLength = responce!.expectedContentLength
                    loadingRequest.dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                } else {
                    print("🔑", #function, "Unable to fetch the CKC.")
                    loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -4, userInfo: nil))
                }
            }
            task.resume()
            
        } else {
            print("🔑", #function, "Unable to read the url/host data.")
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -1, userInfo: nil))
            return false
        }
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        print("")
        return true
    }
}
