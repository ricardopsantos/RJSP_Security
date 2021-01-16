import Foundation
import Combine

// https://www.vadimbulavin.com/modern-networking-in-swift-5-with-urlsession-combine-framework-and-codable/

/*
 Agent is a promise-based HTTP client. It fulfils and configures requests by passing a single URLRequest object to it.
 The agent automatically transforms JSON data into a Codable value and returns an AnyPublisher instance:

 1 - Response<T> carries both parsed value and a URLResponse instance. The latter can be used for status code validation and logging.
 2 - The run<T>() method is the single entry point for requests execution. It accepts a URLRequest instance that fully
 describes the request configuration. The decoder is optional in case custom JSON parsing is needed.
 3 - Create data task as a Combine publisher.
 4 - Parse JSON data. We have constrained T to be Decodable in the run<T>() method declaration.
 5 - Create the Response<T> object and pass it downstream. It contains the parsed value and the URL response.
 6 - Deliver values on the main thread.
 7 - Erase publisher’s type and return an instance of AnyPublisher.
 */

public enum APIError: Error {
   case ok // no error
   case genericError
   case cacheNotFound // no error
   case parsing(description: String)
   case network(description: String)
   case failedWithStatusCode(code: Int)
}

public enum HttpMethod: String {
   case post // no error
}

public struct Response<T: Decodable> {
    public let value: T
    public let response: Any
    public init(value: T, response: Any) {
        self.value = value
        self.response = response
    }
}

public protocol CombineSimpleNetworkAgentProtocol {
    var agent: CombineSimpleNetworkAgent { get set }
}

public class CombineSimpleNetworkAgent {
    private init() { self.session = .shared }
    private var session: URLSession
    public init(session: URLSession) {
        self.session = session
    }
}

public extension CombineSimpleNetworkAgent {

    // 2
    func run<T>(_ request: URLRequest, _ decoder: JSONDecoder, _ dumpResponse: Bool) -> AnyPublisher<Response<T>, APIError> where T: Decodable {
        return session
            .dataTaskPublisher(for: request) // 3
            .tryMap { result -> Response<T> in
                guard let httpResponse = result.response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    let code = (result.response as! HTTPURLResponse).statusCode
                    throw APIError.failedWithStatusCode(code: code)
                }
                if dumpResponse {
                    print("request: \(request)\n\(String(decoding: result.data, as: UTF8.self))")
                }
                let value = try decoder.decode(T.self, from: result.data) // 4
                return Response(value: value, response: result.response)  // 5
        }
        .mapError { error in
            print(request)
            print("\(error)")
            print("\(error.localizedDescription)")
            return APIError.network(description: error.localizedDescription)
        }
            .receive(on: DispatchQueue.main) // 6
            .eraseToAnyPublisher()           // 7
    }
}
