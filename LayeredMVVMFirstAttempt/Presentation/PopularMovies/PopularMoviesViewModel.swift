//
//  PopularMoviesViewModel.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition
protocol PopularMoviesViewModelProtocol {
    func activityHandler(input: AnyPublisher<PopularMoviesViewModel.PopularVMInput, Never>) -> AnyPublisher<PopularMoviesViewModel.PopularVMOutput, Never>
}

final class PopularMoviesViewModel: PopularMoviesViewModelProtocol {
    
    // MARK: - Combine Properties
    private let output = PassthroughSubject<PopularVMOutput, Never>() // Outputları yaymak için
    private var cancellables = Set<AnyCancellable>() // Abonelikleri yönetmek için

    // MARK: - Use Case
    private var useCase: PopularMoviesUseCaseImplementation? // UseCase, API çağrıları için kullanılacak

    // MARK: - Data Storage
    private var sections: [SectionType] = []
    private var movies: [Movie] = []

    // MARK: - Initialization
    init(useCase: PopularMoviesUseCaseImplementation) {
        self.useCase = useCase
    }
}

// MARK: - Activity Handler

extension PopularMoviesViewModel {
    /// Kullanıcıdan gelen olayları dinler ve işler
    func activityHandler(input: AnyPublisher<PopularVMInput, Never>) -> AnyPublisher<PopularVMOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .start(let page):
                self?.start(page: page)
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

}

// MARK: - Start Function - fetchMovies

extension PopularMoviesViewModel {
    
    private func start(page: Int) {
        // Yükleniyor durumunu başlat
        output.send(.loading(isShow: true))

        useCase?.fetchPopularMovies(page: page)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    // İşlem tamamlandı, yükleniyor durumunu kapat
                    self.output.send(.loading(isShow: false))
                case .failure(let error):
                    // Hata durumunda hata mesajını ilet
                    self.output.send(.errorOccurred(message: error.localizedDescription))
                }
            }, receiveValue: { [weak self] movies in
                guard let self else { return }
                // Gelen verileri işleyerek UI'ye uygun hale getir
                let sections = self.prepareUI(data: movies)
                // Güncellenmiş verileri output ile yayınla
                self.output.send(.moviesUpdated(sections: sections))
            }).store(in: &cancellables) // Aboneliği yönetmek için cancellables'a ekle
    }
}

extension PopularMoviesViewModel {
    enum PopularVMOutput {
        case loading(isShow: Bool) // Yükleniyor durumu
        case moviesUpdated(sections: [SectionType]) // Güncellenen veriler
        case errorOccurred(message: String) // Hata mesajı
    }

    enum PopularVMInput {
        case start(page: Int)
    }

    enum SectionType {
        case defaultSection(rows: [RowType])
    }

    enum RowType {
        case movie(movie: Movie)
    }
}

// MARK: - Prepare UI

extension PopularMoviesViewModel {
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
