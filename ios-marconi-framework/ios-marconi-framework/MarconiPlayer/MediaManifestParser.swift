//
//  M3u8Parser.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 14.05.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    
    struct Segment {
        let duration: Float
        let json: String
        
        init?(_ duration: Float?, json: String?) {
            guard let json = json else {
                return nil
            }
            self.duration = duration ?? 0.0
            self.json = json
        }
    }
    
    struct Playlist {
        var startDate: Date?
        var segments: [Segment] = []
    }
    
    class MasterManifestParser {
        
        private let _m3u8Content: String
        private(set) var playlists: [URL] = []
        
        func parse() throws {
            let types: NSTextCheckingResult.CheckingType = [.link]
            let detector = try NSDataDetector(types: types.rawValue)
            let matches =  detector.matches(in: _m3u8Content, options: [], range: NSRange(location: 0, length: _m3u8Content.count))
            for match in matches {
                if let url = match.url {
                    playlists.append(url)
                }
            }
        }
        
        init?(_ url: URL) {
            guard let dataContent = try? String(contentsOf: url, encoding: .utf8), !dataContent.isEmpty else {
                return nil
            }
            _m3u8Content = dataContent
        }
        
        init(_ dataContent: String) {
            _m3u8Content = dataContent
        }
    }
    
    class MediaManifestParser {
        
        enum Tag: String, CustomStringConvertible {
            case EXTINF = "#EXTINF:"
            case EXT_DATE_TIME = "#EXT-X-PROGRAM-DATE-TIME:"
            case EXT_X_DATERANGE = "#EXT-X-DATERANGE:"
            
            var description: String {
                return rawValue
            }
        }
        
        private let _m3u8Content: String
        private(set) var playlist: Playlist = .init()
        
        init(_ dataContent: String) {
            _m3u8Content = dataContent
        }
        
        private func _processInfTag(_ line: String) {
            let segmentRange = line.range(of: "\(Tag.EXTINF)")!
            let componenets = String(line.suffix(from: segmentRange.upperBound)).components(separatedBy: ", {")
            guard let segment = Segment(componenets.first.flatMap(Float.init),
                                        json: componenets.last.flatMap{ "{" + $0 }) else {
                return
            }
            playlist.segments.append(segment)
        }
        
        private func _processStartDateTag(_ line: String) {
            let dateRange = line.range(of: "\(Tag.EXT_DATE_TIME)")!
            let string = String(line.suffix(from: dateRange.upperBound))
            playlist.startDate = string.date
        }
        
        func parse() {
            print(_m3u8Content)
            _m3u8Content.enumerateLines { [weak self](line, isStop) in
                if line.contains("\(Tag.EXT_X_DATERANGE)") {
                    isStop = true
                }
                if line.contains("\(Tag.EXTINF)") {
                    self?._processInfTag(line)
                }
                if line.contains("\(Tag.EXT_DATE_TIME)") {
                    self?._processStartDateTag(line)
                }
            }
        }
    }
}
