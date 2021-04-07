//
//  SkipEntity.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 05.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

struct SkipEntity {
    let newPlaybackUrl: String
    let playId: String
}

extension SkipEntity: Decodable {}
