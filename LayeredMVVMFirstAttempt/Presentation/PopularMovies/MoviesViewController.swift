//
//  PopularMoviesViewController.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Combine
import UIKit

final class PopularMoviesViewController: UIViewController {
    // MARK: - Types

    typealias P = MoviesCollectionViewProvider
    typealias V = MoviesViewModel

    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?

    // Combine Binding
    private let inputVM = PassthroughSubject<MoviesViewModel.MovieVMInput, Never>()
//    private let inputPR = PassthroughSubject<PopularMoviesTableViewProviderImpl.PopularMoviesProviderInput, Never>()
    private let inputPR = PassthroughSubject<MoviesCollectionViewProviderImpl.MoviesProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    // UI Elements

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()


    // MARK: - Initialization

    init(viewModel: V, provider: any P) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Provider: \(String(describing: provider))")
        setupUI()
        binding()
        // Send the initial setup and fetch input events
        print("inputPR.send çağrılmadan önce.") // Log ekleyin
        inputPR.send(.setupUI(collectionView: collectionView))
        print("inputPR.send çağrıldı.")
        // Tüm kategoriler için input gönderimi
        // Kategori sirasi
        let categories: [MovieCategory] = [.popular, .upcoming, .topRated, .nowPlaying]
        inputVM.send(.start(categories: categories, page: 1)) // Tüm kategoriler için veri talebi
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .blue // Ana CollectionView'i kontrol etmek için
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Combine Binding

extension PopularMoviesViewController {
    /// Combine Publisher ve Subscriber’ları bağlar
    private func binding() {
        print("Binding başladı.") // Log kontrolü
        
        // ViewModel’den gelen çıktıları dinle
        let viewModelOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        viewModelOutput?.receive(on: DispatchQueue.main).sink { [weak self] event in
            print("ViewModel'den çıktı alındı: \(event)") // ViewModel'den çıkan olayları logla
            switch event {
            case .sectionUpdated(let category, let sections):
                print("Category: \(category) güncellendi. Sections: \(sections)") // Kategorileri ve section'ları logla

                // Sections'ı Dictionary formatına dönüştür
                let mappedData: [MovieCategory: [Movie]] = [
                    category: sections.flatMap { section -> [Movie] in
                        switch section {
                        case .defaultSection(let rows):
                            return rows.compactMap { row in
                                switch row {
                                case .movie(let movie):
                                    return movie
                                }
                            }
                        }
                    }
                ]

                print("Mapped Data Hazırlandı: \(mappedData)") // Mapped data'yı kontrol et
                self?.inputPR.send(.prepareCollectionView(data: mappedData))
                print("inputPR.send çağrıldı.") // Gönderim kontrolü

            case .errorOccurred(let message):
                print("Hata oluştu: \(message)")
                self?.showError(message: message)

            case .loading(isShow: let isShow):
                print("Yükleme durumu: \(isShow)")
                break
            }
        }.store(in: &cancellables)
        
        // **Provider'dan gelen çıktıları dinle**
        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.sink { [weak self] event in
            print("Provider'dan çıktı alındı: \(event)") // Provider'dan gelen olayları logla
            switch event {
            case .didSelect(let indexPath):
                print("Seçilen IndexPath: \(indexPath)")
                // Detay ekranına geçiş veya ek aksiyonlar buraya eklenebilir
            }
        }.store(in: &cancellables)
    }
}

// MARK: - Error Handling

extension PopularMoviesViewController {
    /// Hata mesajını kullanıcıya gösterir
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
