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
    case leaved(feedback: PreferenceEntity)
}

extension LoggerEvent: Titlable {
    var title: String {
        switch self {
        case .caughtTheError(let error):
            return "[WARRNING]: Error with the description: \(error.localizedDescription)"
        case .handleStreamURL(let description):
            return "[STREAM INIT]: \(description)"
        case .metaDataItem(let item):
            return "[METADATA]: \(item)"
        case .leaved(let feedback):
            return "[FEEDBACK]: \(feedback)"
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
        
        private let _worker = DispatchQueue(label: "com.personal.com.personal.ios-marconi-app")
        private var _items: Items = []
        
        lazy private var _dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter
        }()
        
        // MARK: - Public methods
        
        var changeHandler: ChangesHandler?
        
        subscript(index: Int) -> Model? {
            var result: Model?
            _worker.sync {
                result = self._items[safe: index]
            }
            return result
        }
        
        var count: Int {
            var result = 0
            _worker.sync { result = self._items.count }
            return result
        }
        
        func updateItems(newItems: Items) {
            _worker.async { self._items = newItems }
        }
        
        // MARK: - Private methods
        
        private func _processNewItem(event: LoggerEvent) {
            let dateString = _dateFormatter.string(from: Date())
            if _items.isEmpty {
                _items.append(.init(event: event, dateString: dateString))
                changeHandler?(.firstItem)
                return
            }
            let new = _items + [.init(event: event, dateString: dateString)]
            let indexPathes = (_items.count..<new.count).map{ IndexPath(row: $0, section: 0) }
            changeHandler?(.multiple(new: new, indexPathes: indexPathes))
        }
    }
}

extension Logger.ViewModel: LoggerDelegate {
    func emittedEvent(event: LoggerEvent) {
        _worker.async(execute: combine(event,
                                       with: _processNewItem))
    }
}
