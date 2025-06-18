//
//  ManageCitiesVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.06.2025.
//

import UIKit

final class ManageCitiesVC: UIViewController {

    private var viewModel: ManageCitiesVMProtocol
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)

    init(viewModel: ManageCitiesVMProtocol = ManageCitiesVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchCities()
    }

    private func setupUI() {
        title = "Manage Cities"
        view.backgroundColor = .appBackground

        tableView.backgroundColor = .appBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.pinToEdges(of: view)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cities"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.presentAlert(title: "Error", message: message)
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ManageCitiesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = viewModel.filteredCities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = city.name.capitalized
        cell.backgroundColor = .appBackground
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("Swipe action triggered for index: \(indexPath.row)")
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.viewModel.deleteCity(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

}

extension ManageCitiesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterCities(by: searchController.searchBar.text ?? "")
    }
}
