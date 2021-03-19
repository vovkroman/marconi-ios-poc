//
//  ViewModelable.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

protocol Titlable {
    var title: String { get }
}

struct StationHolder: Titlable {
    let id: Int
    let name: String
    
    var title: String {
        return name
    }
}

protocol ListViewModelable {
    associatedtype Model: Titlable
    
    init()
    var count: Int { get }
    subscript(index: Int) -> Model { get }
}
