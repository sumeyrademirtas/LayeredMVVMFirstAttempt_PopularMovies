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

protocol MoviesCollectionViewProvider: CollectionViewProvider where T == [MovieCategory: [Movie]], I == IndexPath {
    func activityHandler(input: AnyPublisher<MoviesCollectionViewProviderImpl.MoviesProviderInput, Never>) -> AnyPublisher<MoviesCollectionViewProviderImpl.MoviesProviderOutput, Never>
}

// MARK: - MoviesCollectionProvider Implementation

final class MoviesCollectionViewProviderImpl: NSObject, MoviesCollectionViewProvider {
    typealias T = [MovieCategory: [Movie]]
    typealias I = IndexPath
    var dataList: [MovieCategory: [Movie]] = [:]
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
        case prepareCollectionView(data: [MovieCategory: [Movie]])
    }
}

// MARK: - Binding Methods - Activity Handler

extension MoviesCollectionViewProviderImpl {
    func activityHandler(input: AnyPublisher<MoviesProviderInput, Never>) -> AnyPublisher<MoviesProviderOutput, Never> {
        print("activityHandler çağrıldı.")
        input.sink { [weak self] event in
            print("MoviesProviderInput alındı: \(event)")
            switch event {
            case let .setupUI(collectionView):
                print("setupUI çağrılıyor.")
                self?.setupCollectionView(collectionView: collectionView)
            case let .prepareCollectionView(data):
                print("prepareCollectionView çağrılıyor. Gelen veri: \(data)")
                self?.prepareCollectionView(data: data)
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

        let category = Array(dataList.keys)[indexPath.section]

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: collectionView.frame.width - 32, height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
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
        let sectionCount = dataList.keys.count
        print("Toplam section sayısı: \(sectionCount)")
        return sectionCount
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
        return CGSize(width: collectionView.frame.width, height: 250) // Tüm genişlik + uygun yükseklik SECTION IN YUKSEKLIGI GENISLIGI BURASI.
    }

    /// Section kenar boşlukları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    /// Satır arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5 // Satırlar arası boşluk
    }

    /// Hücreler arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5 // Hücreler arası boşluk.
    }

    /// Hücreyi oluştur ve ayarla
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SectionCell.reuseIdentifier, for: indexPath) as? SectionCell else {
            fatalError("Unable to dequeue SectionCell")
        }
        let category = Array(dataList.keys)[indexPath.section]
        cell.movies = dataList[category] ?? []

        return cell
    }
    
    /// Hücre seçimi
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(dataList.keys)[indexPath.section]
        if let movie = dataList[category]?[indexPath.row] {
            print("Selected movie: \(movie.title)")
            output.send(.didSelect(indexPath: indexPath)) // Burada hangi filmi seçtiğini gönderiyoruz.
        }
    }
}


// MARK: - Data Management

extension MoviesCollectionViewProviderImpl {
    /// Veriyi hazırla
    func prepareCollectionView(data: [MovieCategory: [Movie]]) {
        dataList.merge(data) { _, new in new }
        reloadCollectionView()
    }

    /// CollectionView'i yeniden yükle
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}
