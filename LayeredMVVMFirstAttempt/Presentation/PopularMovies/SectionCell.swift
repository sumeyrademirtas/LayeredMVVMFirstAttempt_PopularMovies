//
//  SectionCell.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/27/25.
//

import UIKit

class SectionCell: UICollectionViewCell {
    static let reuseIdentifier = "SectionCell"

    private let innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Section içi yatay kaydırma
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 200)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    var movies: [Movie] = [] {
        didSet {
            innerCollectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(innerCollectionView)
        innerCollectionView.dataSource = self
        innerCollectionView.delegate = self
        innerCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCollectionViewCell")
        innerCollectionView.backgroundColor = .red
        innerCollectionView.alwaysBounceHorizontal = true

        NSLayoutConstraint.activate([
            innerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            innerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension SectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Unable to dequeue MovieCollectionViewCell")
        }
        cell.configure(with: movies[indexPath.row])
        return cell
    }
}
