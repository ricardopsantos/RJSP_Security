//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation
import Combine
import CryptoKit

public class WebAPI : CombineSimpleNetworkAgentProtocol {
    public var agent: CombineSimpleNetworkAgent = CombineSimpleNetworkAgent(session: URLSession.shared)
}

// MARK: - Private

extension WebAPI {
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder(), _ dumpResponse: Bool = true) -> AnyPublisher<T, APIError> {
        return agent.run(request, decoder, dumpResponse).map(\.value).eraseToAnyPublisher()
    }
}

