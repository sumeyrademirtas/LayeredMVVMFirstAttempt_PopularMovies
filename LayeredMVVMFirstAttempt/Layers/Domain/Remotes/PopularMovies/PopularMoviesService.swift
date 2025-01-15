//
//  PopularMoviesService.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition
protocol PopularMoviesService {
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error>
}

// MARK: - Service Implementation
struct PopularMoviesServiceImplementation: PopularMoviesService {
    
    // MARK: - Properties
    private let session: URLSession
    private let constants: Constants

    // MARK: - Initializer
    init(session: URLSession = .shared, constants: Constants) {
        self.session = session
        self.constants = constants
    }

    // MARK: - API Call
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        return Future { promise in
            // URL Creation
            let endpoint = "\(constants.apiHost)/movie/popular"
            var urlComponents = URLComponents(string: endpoint)
            urlComponents?.queryItems = [
                URLQueryItem(name: "api_key", value: constants.apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "\(page)")
            ]

            // Validate URL
            guard let url = urlComponents?.url else {
                promise(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }

            // Network Request
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                    return
                }

                // JSON Parsing
                do {
                    let decodedResponse = try JSONDecoder().decode(PopularMoviesResponse.self, from: data)
                    promise(.success(decodedResponse.results))
                } catch {
                    promise(.failure(error))
                }
            }

            task.resume()
        }
        .eraseToAnyPublisher() // Convert Future to AnyPublisher
    }
}
