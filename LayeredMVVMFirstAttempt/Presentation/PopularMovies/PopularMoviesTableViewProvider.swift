//
//  PopularMoviesTableViewProvider.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/6/25.
//

import Foundation
import UIKit
import Combine

protocol PopularMoviesTableViewProvider: TableViewProvider where T == PopularMoviesViewModel.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<PopularMoviesTableViewProviderImpl.PopularMoviesProviderInput, Never>) -> AnyPublisher<PopularMoviesTableViewProviderImpl.PopularMoviesProviderOutput, Never>
}

// MARK: - MainListProvider Implementation
final class PopularMoviesTableViewProviderImpl: NSObject, PopularMoviesTableViewProvider {
    typealias T = PopularMoviesViewModel.SectionType
    typealias I = IndexPath
    var dataList: [PopularMoviesViewModel.SectionType] = []

    // Binding subjects for interaction events
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<PopularMoviesProviderOutput, Never>() // Bu, output olaylarını yayınlamak için kullanılıyor.

    weak var tableView: UITableView?  // Weak reference to the table view
    
    // Constants for layout customization
    private enum Layout {
        static let headerSection: CGFloat = 200  // Height for header section
    }
}

// MARK: - Event Types
// These are the events triggered by the view model (input) and output events that the view controller listens to.
extension PopularMoviesTableViewProviderImpl {
    enum PopularMoviesProviderOutput { // Provider’ın yayacağı olayları tanımlamak için kullanılıyor.
        case didSelect(indexPath: IndexPath)
    }
    
    enum PopularMoviesProviderInput { // Provider’ın dışarıdan alabileceği olayları tanımla.
        case setupUI(tableView: UITableView)  // Set up the table view
        case prepareTableView(data: [PopularMoviesViewModel.SectionType])
    }
}

// MARK: - Binding Methods
extension PopularMoviesTableViewProviderImpl {
    // Handles the incoming events from the publisher
    // Gelen input olaylarını işle ve output olaylarını yay.
    func activityHandler(input: AnyPublisher<PopularMoviesProviderInput, Never>) -> AnyPublisher<PopularMoviesProviderOutput, Never> {
        input.sink { [weak self] eventType in
            switch eventType {
            case let .setupUI(tableView):
                self?.setupUI(tableView)
            case let .prepareTableView(data):
                self?.prepareTableView(data: data)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - UI Setup Methods
extension PopularMoviesTableViewProviderImpl {
    private func setupUI(_ tableView: UITableView) {
        setupTableView(tableView: tableView)  // Setup the table view properties
    }
    
}

// MARK: - TableView Setup and Delegation Methods
extension PopularMoviesTableViewProviderImpl: UITableViewDelegate, UITableViewDataSource {
    // Setup the table view with the necessary properties and registrations
    func setupTableView(tableView: UITableView) {
        self.tableView = tableView
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView?.estimatedRowHeight = 100
        self.tableView?.tableFooterView = UIView()
        self.tableView?.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        self.tableView?.register(MovieCell.self, forCellReuseIdentifier: "MovieCell") // Hücreyi kaydet

    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.send(.didSelect(indexPath: indexPath))
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataList.count > 0 else { return 0 } // Eğer veri yoksa 0 döner
        let sectionType = dataList[section]
        switch sectionType {
        case .defaultSection(rows: let rows):
            return rows.count // Satır sayısını döndür
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }


    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableView = self.tableView else {
               fatalError("TableView is not initialized")
           }
        
        let sectionType = dataList[indexPath.section]
            switch sectionType {
            case .defaultSection(let rows): // Bölüm türüne göre işlem yap
                let rowType = rows[indexPath.row]
                switch rowType {
                case .movie(let movie): // Satır türüne göre işlem yap
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
                    cell.configure(with: movie) // Hücreyi filmle yapılandır
                    return cell
                }
            }
    }

    
     func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
     func prepareTableView(data: [PopularMoviesViewModel.SectionType]) {
        dataList = data
        reloadTableView()
    }

    // Updates the data list with new data
    func updateDataList(data: [PopularMoviesViewModel.SectionType]){
        dataList = data
    }
}
