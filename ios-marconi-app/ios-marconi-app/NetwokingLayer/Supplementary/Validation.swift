import FutureKit

public typealias Response = (data: Data?, httpResponse: HTTPURLResponse)

public enum Result<ErrorType: Error> {
    case success(data: Data)
    case failure(error: ErrorType)
}

public protocol ResponseValidator: class {
    func validate(the response: Response) -> Result<ResponseError>
}

extension Future where Value == Response {
    @inlinable
    public func validateResponse(networkManager: ResponseValidator) -> Future<Data> {
        chained { value in
            let result = networkManager.validate(the: value)
            switch result {
            case .success(let data):
                return Promise(value: data)
            case .failure(let error):
                throw error
            }
        }
    }
}
