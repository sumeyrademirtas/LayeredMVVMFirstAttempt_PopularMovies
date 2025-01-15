//
//  PopularMoviesUseCase.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol PopularMoviesUseCase {
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error>
}

// MARK: - Implementation
struct PopularMoviesUseCaseImplementation: PopularMoviesUseCase {
    private let service: PopularMoviesService

    /// Dependency Injection
    init(service: PopularMoviesService) {
        self.service = service  /// This definition allows the function within the struct to utilize the service.
    }
}

// MARK: - Combine Compatible Fetch
extension PopularMoviesUseCaseImplementation {
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        /// Calling the fetch method from the service layer and returning a Publisher
        service.fetchPopularMovies(page: page)
    }
}
