import FutureKit

extension ResponseValidator {
    public func validate(the response: Response) -> Result<ResponseError> {
        let httpResponse = response.httpResponse
        switch httpResponse.statusCode {
        case 200...299:
            guard let data = response.data else {
                return .failure(error: .default)
            }
            return .success(data: data)
        case 401...500:
            return .failure(error: .authenticationFailed)
        case 501...599:
            return .failure(error: .badRequest)
        case 600:
            return .failure(error: .default)
        default:
            return .failure(error: .default)
        }
    }
}

public class NetworkConfig {
    
    public enum APIVersion {
        case v1
        case v2
        
        var url: URL? {
            URL(string: "https://api.radio-stg.com/\(self)")
        }
    }
    
    public static var apiVersion: APIVersion = .v2
    public static var baseURL: URL? {
        return apiVersion.url
    }
}
