//
//  ViewModelable.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

protocol DateSupportable {
    var date: String { get }
}

protocol Titlable {
    var title: String { get }
}

struct StationPlaceholder {
    let id: Int
    let name: String
}

extension StationPlaceholder: Titlable {
    var title: String {
        return name
    }
}

protocol Selectable {
    func didSelected(at indexPath: IndexPath)
}

protocol ListViewModelable: Selectable {
    associatedtype Model: Titlable
    var items: ContiguousArray<Model> { get set }
}
