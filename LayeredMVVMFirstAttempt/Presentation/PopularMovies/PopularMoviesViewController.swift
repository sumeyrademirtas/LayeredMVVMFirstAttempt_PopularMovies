//
//  PopularMoviesViewController.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//


import UIKit
import Combine

final class PopularMoviesViewController: UIViewController {
    // MARK: - Types
    typealias P = PopularMoviesTableViewProvider
    typealias V = PopularMoviesViewModel
    
    // MARK: - Properties
    private var viewModel: V?
    private var provider: (any P)?
    
    // Combine Binding
    private let inputVM = PassthroughSubject<PopularMoviesViewModel.PopularVMInput, Never>()
    private let inputPR = PassthroughSubject<PopularMoviesTableViewProviderImpl.PopularMoviesProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // UI Elements
    private let tableView = UITableView()
    
    // MARK: - Initialization
    init(viewModel: V, provider: any P) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        // Send the initial setup and fetch input events
        inputPR.send(.setupUI(tableView: tableView))
        inputVM.send(.start(page: 1)) // İlk sayfa verisini getir
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}


// MARK: - Combine Binding
extension PopularMoviesViewController {
    /// Combine Publisher ve Subscriber’ları bağlar
    private func binding() {
        // ViewModel’den gelen çıktıları dinle
        let viewModelOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        viewModelOutput?.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .moviesUpdated(let sections):
                self?.inputPR.send(.prepareTableView(data: sections))
            case .errorOccurred(let message):
                self?.showError(message: message)
            case .loading(isShow: let isShow):
                break
            }
        }.store(in: &cancellables)
        
        // Provider’dan gelen çıktıları dinle
        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.sink { [weak self] event in
            switch event {
            case .didSelect(let indexPath):
                print("Selected cell at row: \(indexPath.row)")
                // Detay ekranına geçiş gibi işlemler yapılabilir
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
