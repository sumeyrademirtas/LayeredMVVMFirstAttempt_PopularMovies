//
//  MovieCollectionViewCell.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/23/25.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    private let posterImageView = UIImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        // Poster ImageView
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.layer.masksToBounds = true
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)

        // Constraints
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1)
        ])
    }

    override func prepareForReuse() { // MARK: - GEREKLI MI?
        super.prepareForReuse()
        posterImageView.image = nil
    }

    // MARK: - Configure Cell

    func configure(with movie: Movie) {
        loadImage(from: movie.fullPosterURL)
    }

    // URL'den resim yükleme metodu
    private func loadImage(from url: String) {
        guard let url = URL(string: url) else {
            posterImageView.image = UIImage(named: "placeholder") // Varsayılan bir görsel kullan
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(named: "placeholder") // Hata durumunda varsayılan görsel
                }
                return
            }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
