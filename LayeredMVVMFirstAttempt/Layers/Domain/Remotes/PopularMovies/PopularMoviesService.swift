//
//  PopularMoviesService.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation

protocol PopularMoviesService {
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

struct PopularMoviesResponse: Decodable {
    let results: [Movie]
}

struct PopularMoviesServiceImplementation: PopularMoviesService {
    private let session: URLSession
    private let apiHost: String
    private let apiKey: String

    init(session: URLSession = .shared, apiHost: String, apiKey: String) {
        self.session = session
        self.apiHost = apiHost
        self.apiKey = apiKey
    }

    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        
        // URL olusturma
        let endpoint = "\(apiHost)/movie/popular" // endpoint olusturuluyor
        
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = [ // Query parameters ekleniyor
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil))) // URL olusturulamazsa hata donuyor
            return
        }

        // Network olusturma
        let task = session.dataTask(with: url) { data, _, error in // session.dataTask URL ye HTTP istegi yapar, yaniti isler.
            if let error = error {
                completion(.failure(error)) // eger istekte hata varsa
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))  // eger data bossa
                return
            }

            // JSON Parse
            do {
                let decodedResponse = try JSONDecoder().decode(PopularMoviesResponse.self, from: data) // JSON Decoder gelen yaniti PopularMoviesResponse yapisina cevirir.
                completion(.success(decodedResponse.results)) // basarili ise
            } catch {
                completion(.failure(error)) // hatali ise
            }
        }

        // Istegi Baslat
        task.resume()
    }
}
