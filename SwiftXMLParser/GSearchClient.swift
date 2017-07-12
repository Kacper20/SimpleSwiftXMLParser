//
//  GSearchClient.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 09.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation

enum Result<T, E> {
    case success(T)
    case error(E)
}

enum SearchLoaderError: Error {
    case wrongUrl
    case invalidResponse(httpCode: Int?, contents: String?)
}
struct GSearchClient {
    func queryRequest(queryString: String, index: Int) throws -> String {
        let apiKeyValue = "AIzaSyADUlqmX-3mDo2PdDdoZTll0fOvY8_ETyg"
        let clientValue = "001663399765669867942:y9ew9z4ysby"

        var components = URLComponents(string: "https://www.googleapis.com/customsearch/v1")
        let apiKey = URLQueryItem(name: "key", value: apiKeyValue)
        let query = URLQueryItem(name: "q", value: queryString)
        let cx = URLQueryItem(name: "cx", value: clientValue)
        let atom = URLQueryItem(name: "alt", value: "atom")
        let index = URLQueryItem(name: "start", value: "\(index)")
        components?.queryItems = [apiKey, query, cx, atom, index]
        guard let url = components?.url else { throw SearchLoaderError.wrongUrl }


        let result = synchronize(closure: {
            return { closureToCall in
                self.performRequest(
                    forUrl: url,
                    resourceGen: { obj -> String? in
                        return String(data: obj, encoding: .utf8)
                },
                    completion: { result in closureToCall(result) })
            }
        })
        switch result {
        case let .success(values): return values
        case let .error(error): throw error
        }
    }

    private func performRequest<Resource>(
        forUrl url: URL,
        resourceGen: @escaping (Data) -> Resource?,
        completion: @escaping (Result<Resource, SearchLoaderError>) -> Void
        ) {
        let request = URLRequest(url: url)

        let sessionConfig = URLSessionConfiguration.default
        let dataTask = URLSession(configuration: sessionConfig)
            .dataTask(with: request, completionHandler: { (data, response, error) in
                guard let response = response as? HTTPURLResponse else {
                    completion(.error(.invalidResponse(httpCode: nil, contents: nil)))
                    return
                }
                guard let data = data else {
                    completion(.error(.invalidResponse(httpCode: response.statusCode, contents: nil)))
                    return
                }
                if let resource = resourceGen(data) {
                    completion(.success(resource))
                } else {
                    completion(.error(
                        .invalidResponse(httpCode: response.statusCode, contents: String(data: data, encoding: .utf8)))
                    )
                    return
                }
            })
        dataTask.resume()
    }
}

