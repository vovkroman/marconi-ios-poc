//
//  SortedArray.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    class MetaDataQueue {
        
        private var _storage: ContiguousArray<MetaData>
        private let _lock: NSLock = .init()
        
        private var isEmpty: Bool {
            return _storage.isEmpty
        }
        
        // MARK: - Public methods
        
        init() {
            _storage = ContiguousArray<MetaData>()
        }

        var count: Int {
            return _storage.count
        }
        
        func removeAll() {
            defer {
                _lock.unlock()
            }
            _lock.lock()
            if _storage.isEmpty { return }
            _storage.removeAll()
        }
        
        @discardableResult
        func popFirst() -> MetaData? {
            defer {
                _lock.unlock()
            }
            _lock.lock()
            if isEmpty {
                return nil
            }
            return _storage.removeFirst()
        }
        
        func head() -> MetaData? {
            defer {
                _lock.unlock()
            }
            _lock.lock()
            if isEmpty {
                return nil
            }
            return _storage.first
        }
        
        func next() -> MetaData? {
            defer {
                _lock.unlock()
            }
            _lock.lock()
            if _storage.count > 1 {
                return _storage[1]
            }
            return nil
        }
        
        func enqueue(_ items: [MetaData]) {
            defer {
                _lock.unlock()
            }
            _lock.lock()
            for item in items {
                insert(newElement: item)
            }
        }

        private func insert(newElement: MetaData) {
            guard let newElementKey = newElement.sortedKey else {
                return
            }
            if _storage.isEmpty {
                _storage.append(newElement)
                return
            }
            guard let index = findInsertionPoint(for: newElement) else {
                return
            }
            if index >= 0, index < _storage.count, _storage[index].sortedKey == newElement.sortedKey {
                _storage[index] = newElement
                return
            }
            var insertIndex = index
            if _storage[index].sortedKey! < newElementKey { insertIndex += 1 }
            _storage.insert(newElement, at: insertIndex)
        }
        
        // Using binary search define index to insert item at position
        private func findInsertionPoint(for element: MetaData) -> Int? {
            guard let newElementKey = element.sortedKey else {
                return nil
            }

            var startIndex = 0
            var endIndex = _storage.count - 1
            
            while startIndex < endIndex {
                let midIndex = startIndex + (endIndex - startIndex) / 2
                if _storage[midIndex] == element {
                    return midIndex
                } else if _storage[midIndex].sortedKey! < newElementKey {
                    startIndex = midIndex + 1
                } else {
                    endIndex = midIndex
                }
            }
            return startIndex
        }
    }
}
