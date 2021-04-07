//
//  ViewModelOwnable.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

protocol ViewModelOwnable {
    associatedtype ViewModelType
    init(viewModel: ViewModelType)
}
