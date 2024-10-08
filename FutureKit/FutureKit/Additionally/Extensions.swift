import Foundation

extension Future {
    @inlinable
    public func chained<T>(using closure: @escaping (Value) throws -> Future<T>) -> Future<T> {
        // We'll start by constructing a "wrapper" promise that will be
        // returned from this method:
        let promise = Promise<T>()
        
        // Observe the current future:
        observe { result in
            switch result {
            case .success(let value):
                do {
                    // Attempt to construct a new future using the value
                    // returned from the first one:
                    let future = try closure(value)
                    
                    // Observe the "nested" future, and once it
                    // completes, resolve/reject the "wrapper" future:
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
    
    @inlinable
    public func transformed<T>(
        with closure: @escaping (Value) throws -> T
    ) -> Future<T> {
        chained { value in
            try Promise(value: closure(value))
        }
    }
}


extension Future where Value == Data {
    @inlinable
    public func decoded<T: Decodable>(as type: T.Type = T.self) -> Future<T> {
        transformed { data in
            try autoreleasepool {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            }
        }
    }
}
