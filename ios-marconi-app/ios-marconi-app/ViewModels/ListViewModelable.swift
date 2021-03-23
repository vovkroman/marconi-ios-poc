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

struct StationPlaceholder: Titlable {
    let id: Int
    let name: String
    
    var title: String {
        return name
    }
}

protocol Selectable {
    func didSelected(at indexPath: IndexPath)
}

protocol ListViewModelable: Selectable {
    associatedtype Model: Titlable
    var count: Int { get }
    subscript(index: Int) -> Model? { get }
}
