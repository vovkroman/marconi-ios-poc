//
//  URL+Extensions.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 22.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation


extension URL {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
}
