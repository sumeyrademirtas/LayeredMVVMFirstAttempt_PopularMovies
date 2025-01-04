//
//  PopularMoviesViewController.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import UIKit

class PopularMoviesViewController: UIViewController {
    private let viewModel: PopularMoviesViewModel
    private let customView = PopularMoviesView()

    // Dependency Injection
    init(viewModel: PopularMoviesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchMovies()
    }

    private func setupTableView() {
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        customView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
    }

    private func fetchMovies() {
        viewModel.fetchPopularMovies(page: 1) { [weak self] in
            DispatchQueue.main.async {
                if let error = self?.viewModel.errorMessage {
                    self?.showError(error)
                } else {
                    self?.customView.tableView.reloadData()
                }
            }
        }
    }

    private func showError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

extension PopularMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = viewModel.movies[indexPath.row]
        cell.textLabel?.text = movie.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMovie = viewModel.movies[indexPath.row]
        print("Selected Movie: \(selectedMovie.title)")
    }
}
