//
//  MovieCell.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/14/25.
//


import UIKit

class MovieCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let releaseDateLabel = UILabel()
    private let stackView = UIStackView()
    static let reuseIdentifier = "MovieCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // StackView yapılandırması
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        // Title Label yapılandırması
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        stackView.addArrangedSubview(titleLabel)

        // Release Date Label yapılandırması
        releaseDateLabel.font = UIFont.systemFont(ofSize: 14)
        releaseDateLabel.textColor = .gray
        stackView.addArrangedSubview(releaseDateLabel)

        // StackView kısıtlamaları
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        releaseDateLabel.text = "Release Date: \(movie.releaseDate)"
    }
}
