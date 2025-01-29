//
//  PopularMoviesViewModel.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol MoviesViewModelProtocol {
    func activityHandler(input: AnyPublisher<MoviesViewModel.MovieVMInput, Never>) -> AnyPublisher<MoviesViewModel.MovieVMOutput, Never>
}

final class MoviesViewModel: MoviesViewModelProtocol {
    // MARK: - Combine Properties

    private let output = PassthroughSubject<MovieVMOutput, Never>() // Outputları yaymak için
    private var cancellables = Set<AnyCancellable>() // Abonelikleri yönetmek için

    // MARK: - Use Case

    private var useCase: MoviesUseCaseImplementation? // UseCase, API çağrıları için kullanılacak

    // MARK: - Data Storage

    private var categorySections: [MovieCategory: [SectionType]] = [:]
    private var sections: [SectionType] = []
    private var movies: [Movie] = []

    // MARK: - Initialization

    init(useCase: MoviesUseCaseImplementation) {
        self.useCase = useCase
    }
}

// MARK: - Activity Handler

extension MoviesViewModel {
    /// Kullanıcıdan gelen olayları dinler ve işler
    func activityHandler(input: AnyPublisher<MovieVMInput, Never>) -> AnyPublisher<MovieVMOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .start(let categories, let page): // categories artık bir dizi
                self?.start(categories: categories, page: page) // start fonksiyonunu çağır
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Start Function - fetchMovies

extension MoviesViewModel {
    private func start(categories: [MovieCategory], page: Int) {
        output.send(.loading(isShow: true)) // Yükleniyor durumunu başlat
        useCase?.fetchAllMovies()?.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.output.send(.loading(isShow: false))
            case .failure(let error):
                print("Error: \(error)")
            }
        }, receiveValue: { movies in
            let sections = self.prepareUI(popular: movies.0, upcoming: movies.1, nowPlaying: movies.2, topRated: movies.3)
            self.output.send(.dataSource(sections: sections))
        }).store(in: &cancellables)
    }
}

extension MoviesViewModel {
//    enum PopularVMOutput {
//        case loading(isShow: Bool) // Yükleniyor durumu
//        case moviesUpdated(sections: [SectionType]) // Güncellenen veriler
//        case errorOccurred(message: String) // Hata mesajı
//    }

    enum MovieVMOutput {
        case loading(isShow: Bool) // Yüklenme durumu
        case sectionUpdated(category: MovieCategory, sections: [SectionType]) // Kategori bazlı güncelleme
        case errorOccurred(message: String) // Hata mesajı
        case dataSource(sections: [SectionType])
    }

//    enum PopularVMInput {
//        case start(category: MovieCategory, page: Int)
//    }

    enum MovieVMInput {
        case start(categories: [MovieCategory], page: Int) // Birden fazla kategori ve sayfa
    }

    // [.popular, .upcoming, .nowPlaying, .topRated]
    enum SectionType {
        case popular(rows: [RowType])
        case upcoming(rows: [RowType])
        case nowPlaying(rows: [RowType])
        case topRated(rows: [RowType])
    }

    enum RowType {
        case movie(movie: [Movie])
    }
}

// MARK: - Prepare UI

extension MoviesViewModel {
    private func prepareUI(popular: MoviesResponse?, upcoming: MoviesResponse?, nowPlaying: MoviesResponse?, topRated: MoviesResponse?) -> [SectionType] {
        var section = [SectionType]()
        var popularRowType = [RowType]()
        var upcomingRowType = [RowType]()
        var nowPlayingRowType = [RowType]()
        var topRatedRowType = [RowType]()

        if let popular = popular?.results {
            popularRowType.append(.movie(movie: popular))
            section.append(.popular(rows: popularRowType))
        }

        if let upcoming = upcoming?.results {
            upcomingRowType.append(.movie(movie: upcoming))
            section.append(.upcoming(rows: upcomingRowType))
        }

        if let nowPlaying = nowPlaying?.results {
            nowPlayingRowType.append(.movie(movie: nowPlaying))
            section.append(.nowPlaying(rows: nowPlayingRowType))
        }

        if let topRated = topRated?.results {
            topRatedRowType.append(.movie(movie: topRated))
            section.append(.topRated(rows: topRatedRowType))
        }

        return section
    }
}
