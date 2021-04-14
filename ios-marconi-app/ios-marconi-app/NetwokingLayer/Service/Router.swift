import Foundation
import FutureKit

public protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func doRequest(_ route: EndPoint) -> Future<Response>
    func cancel()
}

open class AnyRouter<EndPoint: EndPointType>: NetworkRouter {
    
    public typealias EndPoint = EndPoint
    
    private var _task: URLSessionTask?
    private let _session: URLSession
    
    // MARK: - Public methods
    
    open func doRequest(_ route: EndPoint) -> Future<Response> {
        let promise = Promise<Response>()
        do {
            let request = try buildRequest(from: route)
            Log.info("\(request) has been started", category: .api)
            _task = _session.dataTask(with: request){ data, response, error in
                if let error = error {
                    Log.error("\(request) failed with error \(error)", category: .api)
                    promise.reject(with: error)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    Log.debug("\(request) finished with status code \(httpResponse.statusCode)",
                        category: .api)
                    promise.resolve(with: (data, httpResponse))
                    return
                }
                promise.reject(with: DataError.httpResponseFailed)
            }
        } catch {
            promise.reject(with: error)
        }
        
        _task?.resume()
        
        return promise
    }
    
    public init(session: URLSession = .shared) {
        _session = session
    }
    
    open func cancel() {
        _task?.cancel()
    }
    
    // MARK: - Build request method
    
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        var url: URL
        if let path = route.path {
            url = route.baseURL.appendingPathComponent(path)
        } else {
            url = route.baseURL
        }
        var request = URLRequest(url: url,
                                 cachePolicy: route.cachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue
        
        addAdditionalHeaders(route.authenticationHeaders, request: &request)
        addAdditionalHeaders(route.headers, request: &request)
        
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try configureParameters(bodyParameters: bodyParameters,
                                        bodyEncoding: bodyEncoding,
                                        urlParameters: urlParameters,
                                        request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                        bodyEncoding: bodyEncoding,
                                        urlParameters: urlParameters,
                                        request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    private func configureParameters(bodyParameters: Parameters?,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}



