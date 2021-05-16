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
        
        init(_ duration: Float?, json: String) {
            self.duration = duration ?? 0.0
            self.json = json
        }
    }
    
    struct Playlist {
        var startDate: Date?
        var segments: [Segment] = []
    }
    
    class MasterManigestParser {
        
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
            
            var description: String {
                return rawValue
            }
        }
        
        private let _m3u8Content: String
        private(set) var playlist: Playlist = .init()
        
        init(_ url: URL) throws {
            let dataContent = try String(contentsOf: url, encoding: .utf8)
            guard !dataContent.isEmpty else {
                throw MError.loaderError(description: "MediaManifest is empty")
            }
            _m3u8Content = dataContent
        }
        
        private func _processInfTag(_ line: String) {
            let segmentRange = line.range(of: "\(Tag.EXTINF)")!
            let componenets = String(line.suffix(from: segmentRange.upperBound)).components(separatedBy: ", ")
            playlist.segments.append(Segment(Float(componenets[0]), json: componenets[1]))
        }
        
        private func _processStartDateTag(_ line: String) {
            let dateRange = line.range(of: "\(Tag.EXT_DATE_TIME)")!
            let stringDate = String(line.suffix(from: dateRange.upperBound))
            playlist.startDate = DateFormatter().date(from: stringDate)
        }
        
        func parse() {
            _m3u8Content.enumerateLines { [weak self](line, _) in
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
