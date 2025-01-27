//
//  PopularMoviesUseCase.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation
import Combine


// MARK: - Protocol Definition
protocol MoviesUseCase {
    func fetchMovies(category: MovieCategory, page: Int) -> AnyPublisher<[Movie], Error>
}


struct MoviesUseCaseImplementation: MoviesUseCase {
    private let service: TmdbService

    /// Dependency Injection
    init(service: TmdbService) {
        self.service = service
    }
}


// MARK: Yeni extension
extension MoviesUseCaseImplementation {
    func fetchMovies(category: MovieCategory, page: Int) -> AnyPublisher<[Movie], Error> {
        return service
            .getMovies(api: .getMovies(category: category, page: page))
            .map { $0.results } // Sadece film listesi döndürülüyor
            .eraseToAnyPublisher()
    }
}
