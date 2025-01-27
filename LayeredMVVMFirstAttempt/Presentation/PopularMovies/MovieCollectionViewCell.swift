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
    private let titleLabel = UILabel()
    private let voteAverageLabel = UILabel()

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

        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Vote Average Label
        voteAverageLabel.font = UIFont.systemFont(ofSize: 12)
        voteAverageLabel.textColor = .gray
        voteAverageLabel.textAlignment = .center
        voteAverageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(voteAverageLabel)

        // Constraints
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            voteAverageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            voteAverageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            voteAverageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            voteAverageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    // MARK: - Configure Cell

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        voteAverageLabel.text = "Rating: \(movie.voteAverage)"
        // Resmi yükle
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
