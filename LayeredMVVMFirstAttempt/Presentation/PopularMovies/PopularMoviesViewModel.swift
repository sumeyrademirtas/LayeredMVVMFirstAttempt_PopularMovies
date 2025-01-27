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
        
        let publishers = categories.map { category in
            useCase?.fetchMovies(category: category, page: page) ?? Empty<[Movie], Error>().eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .collect() // Tüm yayınları birleştir
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.output.send(.loading(isShow: false)) // Yükleniyor durumunu kapat
                case .failure(let error):
                    self.output.send(.errorOccurred(message: error.localizedDescription)) // Hata mesajını ilet
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                for (index, category) in categories.enumerated() {
                    let sections = self.prepareUI(data: results[index])
                    self.output.send(.sectionUpdated(category: category, sections: sections)) // Kategoriye uygun bölümleri yayınla
                }
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
    }

//    enum PopularVMInput {
//        case start(category: MovieCategory, page: Int)
//    }
    
    enum MovieVMInput {
        case start(categories: [MovieCategory], page: Int) // Birden fazla kategori ve sayfa
    }

    enum SectionType {
        case defaultSection(rows: [RowType])
    }

    enum RowType {
        case movie(movie: Movie)
    }
}

// MARK: - Prepare UI

extension MoviesViewModel {
    private func prepareUI(data: [Movie]) -> [SectionType] {
        var section = [SectionType]()
        var rowType = [RowType]()

        for movie in data {
            rowType.append(.movie(movie: movie))
        }

        section.append(.defaultSection(rows: rowType))
        return section
    }
}
