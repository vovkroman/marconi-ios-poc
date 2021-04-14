//
//  LoggerViewModel.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 13.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import ios_marconi_framework

enum LoggerEvent {
    case handleStreamURL(description: String)
    case caughtTheError(Error)
    case metaDataItem(item: Marconi.MetaData)
}

extension LoggerEvent: Titlable {
    var title: String {
        switch self {
        case .caughtTheError(let error):
            return "Caught the error: \(error.localizedDescription)"
        case .handleStreamURL(let description):
            return description
        case .metaDataItem(let item):
            return "\(item)"
        }
    }
}

protocol LoggerDelegate: class {
    func emittedEvent(event: LoggerEvent)
}

extension Logger {
    
    class ViewModel {
        typealias Model = LogPresentNode
        typealias Items = ContiguousArray<Model>
        
        enum Changes {
            case empty
            case firstItem
            case multiple(new: Items, indexPathes: [IndexPath])
        }
        
        typealias ChangesHandler = (Changes) -> ()
        
        var changeHandler: ChangesHandler?
        
        private(set) var _items: Items = []
        
        lazy private var _dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter
        }()
                
        // MARK: - Private methods
        
        func updateItems(newItems: Items) {
            _items = newItems
        }
        
        private func _processNewItem(event: LoggerEvent) {
            if _items.isEmpty {
                _items.append(.init(event: event, dateString: _dateFormatter.string(from: Date())))
                changeHandler?(.firstItem)
                return
            }
            let new = _items + [.init(event: event, dateString: _dateFormatter.string(from: Date()))]
            let indexPathes = (_items.count..<new.count).map{ IndexPath(row: $0, section: 0) }
            changeHandler?(.multiple(new: new, indexPathes: indexPathes))
        }
    }
}

extension Logger.ViewModel: LoggerDelegate {
    func emittedEvent(event: LoggerEvent) {
        _processNewItem(event: event)
    }
}
