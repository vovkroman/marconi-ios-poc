//
//  Identifiers.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 26.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import AVFoundation

enum Identifier {
    static let playID = AVMetadataIdentifier("lsdr/X-PLAY-ID")
    static let type = AVMetadataIdentifier("lsdr/X-TYPE")
    static let artist = AVMetadataIdentifier("lsdr/X-ARTIST")
    static let title = AVMetadataIdentifier("lsdr/X-TITLE")
    static let image = AVMetadataIdentifier("lsdr/X-IMAGE")
    
    static let songAlbumArtURL = AVMetadataIdentifier("lsdr/X-SONG-ALBUM-ART-URL")
    static let canPause = AVMetadataIdentifier("lsdr/X-SONG-CAN-PAUSE")
    static let songTitle = AVMetadataIdentifier("lsdr/X-SONG-TITLE")
    static let skips = AVMetadataIdentifier("lsdr/X-SESSION-SKIPS")
    static let playlistTrackStartTime = AVMetadataIdentifier("lsdr/X-PLAYLIST-TRACK-START-TIME")
    static let stationID = AVMetadataIdentifier("lsdr/X-SONG-STATION-ID")
    static let isSongExplicit = AVMetadataIdentifier("lsdr/X-SONG-IS-EXPLICIT")
    static let isSkippable = AVMetadataIdentifier("lsdr/X-SONG-IS-SKIPPABLE")
    static let songArtist = AVMetadataIdentifier("lsdr/X-SONG-ARTIST")
    static let datumTime = AVMetadataIdentifier("lsdr/X-DATUM-TIME")
    static let songDuration = AVMetadataIdentifier("lsdr/X-SONG-DURATION")
    static let songID = AVMetadataIdentifier("lsdr/X-SONG-ID")
    static let datumStartTime = AVMetadataIdentifier("lsdr/X-DATUM-START-TIME")
    static let segmentStartTime = AVMetadataIdentifier("lsdr/X-SEGMENT-START-TIME")
    static let sessionPlayID = AVMetadataIdentifier("lsdr/X-SESSION-PLAY-ID")
    static let songType = AVMetadataIdentifier("lsdr/X-SONG-TYPE")
}
