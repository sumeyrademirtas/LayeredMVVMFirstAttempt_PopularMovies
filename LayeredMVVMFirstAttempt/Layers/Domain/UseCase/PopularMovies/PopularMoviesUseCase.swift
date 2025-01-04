//
//  PopularMoviesUseCase.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation

protocol PopularMoviesUseCase {
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
}

struct PopularMoviesUseCaseImplementation: PopularMoviesUseCase {
    private let service: PopularMoviesService

    init(service: PopularMoviesService) {
        self.service = service  // bu atama/tanim sayesinde struct icindeki fonksiyonlar service i  kullanabilecek.
    }
}

extension PopularMoviesUseCaseImplementation {
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        service.fetchPopularMovies(page: page, completion: completion)
    }
}
