//
//  SortedArray.swift
//  ios-marconi-framework
//
//  Created by Roman Vovk on 23.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import Foundation

extension Marconi {
    struct MetaDataQueue {
        
        private var _storage: ContiguousArray<MetaData>
        
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
        
        
        mutating func removeAll() {
            _storage.removeAll()
        }
        
        @discardableResult
        mutating func dequeue() -> MetaData? {
            if isEmpty {
                return nil
            }
            return _storage.removeFirst()
        }
        
        mutating func head() -> MetaData? {
            if isEmpty {
                return nil
            }
            return _storage.first
        }
        
        mutating func enqueue(_ items: MetaData...) {
            for item in items {
                insert(newElement: item)
            }
        }

        mutating private func insert(newElement: MetaData) {
            guard let newStartDate = newElement.startTrackDate else { return }
            if _storage.isEmpty {
                _storage.append(newElement)
                return
            }
            let index = findInsertionPoint(for: newElement)
            if index >= 0, index < _storage.count, _storage[index] == newElement { return }
            var insertIndex = index
            if _storage[index].startTrackDate! < newStartDate { insertIndex += 1 }
            _storage.insert(newElement, at: insertIndex)
        }
        
        private func findInsertionPoint(for element: MetaData) -> Int {
            var startIndex = 0
            var endIndex = _storage.count - 1
            
            while startIndex < endIndex {
                let midIndex = startIndex + (endIndex - startIndex) / 2
                if _storage[midIndex] == element {
                    return midIndex
                } else if _storage[midIndex].startTrackDate! < element.startTrackDate! {
                    startIndex = midIndex + 1
                } else {
                    endIndex = midIndex
                }
            }
            return startIndex
        }
    }
}