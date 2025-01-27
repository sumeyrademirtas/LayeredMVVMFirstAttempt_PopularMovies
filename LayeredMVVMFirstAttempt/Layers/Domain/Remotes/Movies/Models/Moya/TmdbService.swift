//
//  TmdbService.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/23/25.
//

import Combine
import Foundation
import Moya

protocol TmdbService {
    func getMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse, Error>
}

struct TmdbServiceImpl: TmdbService {
    
    let provider = BaseMoyaProvider<TMDBApi>(
            plugins: [NetworkLoggerPlugin(configuration: .init(
                formatter: .init(responseData: JSONResponseDataFormatter),
                logOptions: .verbose
            ))]
        )
}

extension TmdbServiceImpl {

    func getMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse, Error> {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MoviesResponse.self, from: response.data)
                        promise(.success(decodedResponse)) // Başarıyla promise gönder
                    } catch {
                        promise(.failure(error)) // JSON decode hatası
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        promise(.failure(error)) // Ağ hatası
                    default:
                        promise(.failure(moyaError)) // Diğer Moya hataları
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
