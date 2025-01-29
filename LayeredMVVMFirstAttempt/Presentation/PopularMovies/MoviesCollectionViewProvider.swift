//
//  Untitled.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/23/25.
//

import Combine
import Foundation
import UIKit

/// Yeni versiyon

// MARK: - MoviesCollectionViewProvider Protocol

protocol MoviesCollectionViewProvider: CollectionViewProvider where T == [MoviesViewModel.SectionType], I == IndexPath {
    func activityHandler(input: AnyPublisher<MoviesCollectionViewProviderImpl.MoviesProviderInput, Never>) -> AnyPublisher<MoviesCollectionViewProviderImpl.MoviesProviderOutput, Never>
}

// MARK: - MoviesCollectionProvider Implementation

final class MoviesCollectionViewProviderImpl: NSObject, MoviesCollectionViewProvider {
    func prepareCollectionView(data: [[MoviesViewModel.SectionType]]) {}

    typealias T = [MoviesViewModel.SectionType]
    typealias I = IndexPath
    var dataList = [MoviesViewModel.SectionType]()
    /// Binding subjects for interaction events
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<MoviesProviderOutput, Never>()
    weak var collectionView: UICollectionView?
}

// MARK: - Input & Output Definitions

extension MoviesCollectionViewProviderImpl {
    enum MoviesProviderOutput {
        case didSelect(indexPath: IndexPath)
    }

    enum MoviesProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [MoviesViewModel.SectionType])
    }
}

// MARK: - Binding Methods - Activity Handler

extension MoviesCollectionViewProviderImpl {
    func activityHandler(input: AnyPublisher<MoviesProviderInput, Never>) -> AnyPublisher<MoviesProviderOutput, Never> {
        print("activityHandler çağrıldı.")
        input.sink { [weak self] event in
            print("MoviesProviderInput alındı: \(event)")
            switch event {
                case .setupUI(let collectionView):
                    print("setupUI çağrılıyor.")
                    self?.setupCollectionView(collectionView: collectionView)
                case .prepareCollectionView(let data):
                    print("prepareCollectionView çağrılıyor. Gelen veri: \(data)")
                    self?.prepareCollectionView(sections: data)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - CollectionView Setup

extension MoviesCollectionViewProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// CollectionView temel ayarları
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        // Hücre ve header register işlemleri
        self.collectionView?.register(SectionCell.self, forCellWithReuseIdentifier: SectionCell.reuseIdentifier)
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DefaultHeaderView")
    }

    /// Header View Ayarları
    /// Header View Ayarları
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind: \(kind)")
        }

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DefaultHeaderView", for: indexPath)

        header.subviews.forEach { $0.removeFromSuperview() }

        let category = MovieCategory.orderedCategories[indexPath.section]

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: collectionView.frame.width - 32, height: 30))
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.text = category.displayName
        header.addSubview(titleLabel)

        return header
    }

    /// Header boyutları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }

    /// Section sayısı
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataList.count
    }

    /// Hücre sayısı
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Her section bir adet SectionCell içerecek
    }

    /// Hücre boyutları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200) // Tüm genişlik + uygun yükseklik SECTION IN YUKSEKLIGI GENISLIGI BURASI.
    }

    /// Section kenar boşlukları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Sol ve sağ boşluk
    }

    /// Satır arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Satırlar arası boşluk
    }

    /// Hücreler arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Hücreler arası boşluk.
    }

    /// Hücreyi oluştur ve ayarla
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SectionCell.reuseIdentifier, for: indexPath) as? SectionCell else {
            fatalError("Unable to dequeue SectionCell")
        }
        let section = dataList[indexPath.section]
        switch section {
            case .popular(rows: let rows):
                let row = rows[indexPath.row]
                switch row {
                    case .movie(let movie):
                        cell.setUpDataList(movie: movie)
                }
            case .upcoming(rows: let rows):
                let row = rows[indexPath.row]
                switch row {
                    case .movie(let movie):
                        cell.setUpDataList(movie: movie)
                }
            case .nowPlaying(rows: let rows):
                let row = rows[indexPath.row]
                switch row {
                    case .movie(let movie):
                        cell.setUpDataList(movie: movie)
                }
            case .topRated(rows: let rows):
                let row = rows[indexPath.row]
                switch row {
                    case .movie(let movie):
                        cell.setUpDataList(movie: movie)
                }
        }
        return cell
    }

    /// Hücre seçimi
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let category = Array(dataList.keys)[indexPath.section]
//        if let movie = dataList[category]?[indexPath.row] {
//            print("Selected movie: \(movie.title)")
//            output.send(.didSelect(indexPath: indexPath)) // Burada hangi filmi seçtiğini gönderiyoruz.
//        }
//    }
}

// MARK: - Data Management

extension MoviesCollectionViewProviderImpl {
    /// Veriyi hazırla
    func prepareCollectionView(sections: [MoviesViewModel.SectionType]) {
        dataList = sections
        reloadCollectionView()
    }

    /// CollectionView'i yeniden yükle
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}
