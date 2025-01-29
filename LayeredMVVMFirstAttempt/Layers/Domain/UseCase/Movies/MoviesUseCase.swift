//
//  PopularMoviesUseCase.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol MoviesUseCase {
    func getPopularMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>?
    func getTopRatedMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>?
    func getNowPlayingMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>?
    func getUpcomingMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>?
}

struct MoviesUseCaseImplementation: MoviesUseCase {
    private let service: TmdbService

    /// Dependency Injection
    init(service: TmdbService) {
        self.service = service
    }

    // return [.popular, .upcoming, .nowPlaying, .topRated]
    func fetchAllMovies() -> AnyPublisher<(MoviesResponse?, MoviesResponse?, MoviesResponse?, MoviesResponse?), Error>? {
        // Tüm sorguları başlat
        if
            let popularPublisher = getPopularMovies(api: .getPopularMovies(page: 1)),
            let topRatedPublisher = getTopRatedMovies(api: .getTopRatedMovies(page: 1)),
            let nowPlayingPublisher = getNowPlayingMovies(api: .getNowPlayingMovies(page: 1)),
            let upcomingPublisher = getUpcomingMovies(api: .getUpcomingMovies(page: 1))
        {
            return Publishers.Zip4(popularPublisher, upcomingPublisher, nowPlayingPublisher, topRatedPublisher)
                .map { popular, topRated, nowPlaying, upcoming in
                    (popular, topRated, nowPlaying, upcoming)
                }
                .eraseToAnyPublisher()
        }

        return nil
    }
}

// MARK: Yeni extension

extension MoviesUseCaseImplementation {
    func getPopularMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>? {
        service.getPopularMovies(api: api)
    }

    func getTopRatedMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>? {
        service.getTopRatedMovies(api: api)
    }

    func getNowPlayingMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>? {
        service.getNowPlayingMovies(api: api)
    }

    // return [.popular, .upcoming, .nowPlaying, .topRated]

    func getUpcomingMovies(api: TMDBApi) -> AnyPublisher<MoviesResponse?, any Error>? {
        service.getUpcomingMovies(api: api)
    }
}
