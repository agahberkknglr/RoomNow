//
//  ViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

final class SearchVC: UIViewController {
    
    private let destinationButton = SearchOptionButton()
    private let dateButton = SearchOptionButton()
    private let roomButton = SearchOptionButton()
    private let searchButton = UIButton()
    private let recentSearchesTableView = UITableView()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No recent searches yet."
        label.textColor = .appSecondaryText
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let viewModel: SearchVMProtocol
    
    init(viewModel: SearchVMProtocol = SearchVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.viewDidLoad()
        viewModel.loadRecentSearches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadRecentSearches()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.applyPrimaryStyle(with: "Search Now")
        
        let stackView = UIStackView(arrangedSubviews: [destinationButton, dateButton, roomButton, searchButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            destinationButton.heightAnchor.constraint(equalToConstant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(recentSearchesTableView)
        recentSearchesTableView.backgroundColor = .clear
        recentSearchesTableView.separatorStyle = .none
        recentSearchesTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.delegate = self
        recentSearchesTableView.registerCell(type: HistoryCell.self)
        
        NSLayoutConstraint.activate([
            recentSearchesTableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            recentSearchesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentSearchesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recentSearchesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 40)
        ])
    }

    private func updateButtonStates() {
        destinationButton.setTitle(viewModel.getDestinationTitle().capitalized, for: .normal)
        dateButton.setTitle(viewModel.getDateButtonTitle(), for: .normal)
        roomButton.setTitle(viewModel.getRoomButtonTitle(), for: .normal)

        let isEnabled = viewModel.isSearchEnabled()
        searchButton.isEnabled = isEnabled
        searchButton.setTitleColor(isEnabled ? .appAccent : .appPrimaryText, for: .normal)
        searchButton.alpha = isEnabled ? 1.0 : 0.5
    }

    @objc private func searchButtonTapped() {
        viewModel.saveRecentSearch()

        guard let parameters = viewModel.getSearchParameters() else {
            print("Missing search data")
            return
        }

        let resultVC = ResultVC(searchParameters: parameters)
        resultVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(resultVC, animated: true)
    }


    @objc private func openDestinationSheet() {
        let destinationVC = DestinationVC()
        destinationVC.delegate = self
        presentBottomSheet(with: destinationVC, detents: [.large()])
    }

    @objc private func openDateSheet() {
        let dateVC = DateVC()
        dateVC.selectedStartDate = viewModel.selectedStartDate
        dateVC.selectedEndDate = viewModel.selectedEndDate
        dateVC.delegate = self
        presentBottomSheet(with: dateVC, detents: [.medium()])
    }
    
    @objc private func openRoomSheet() {
        guard let searchVM = viewModel as? SearchVM else {
            print("Failed to cast ViewModel")
            return
        }

        let roomVM = RoomVM(
            rooms: searchVM.numberOfRooms,
            adults: searchVM.numberOfAdults,
            children: searchVM.numberOfChildren
        )

        let roomVC = RoomVC(viewModel: roomVM)
        roomVC.delegate = self
        presentBottomSheet(with: roomVC, detents: [.medium()])
    }

    private func presentBottomSheet(with viewController: UIViewController, detents: [UISheetPresentationController.Detent]) {
        let nav = UINavigationController(rootViewController: viewController)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(nav, animated: true)
    }
}

extension SearchVC: SearchVMDelegate {
    func updateUI() {
        updateButtonStates()

        let isEmpty = viewModel.numberOfRecentSearches() == 0
        recentSearchesTableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty

        recentSearchesTableView.reloadData()
    }
}

extension SearchVC: DestinationVCDelegate {
    func didSelectCity(_ city: City) {
        viewModel.updateSelectedCity(city)
    }
}

extension SearchVC: DateVCDelegate {
    func didSelectDateRange(_ startDate: Date, _ endDate: Date) {
        viewModel.updateSelectedDates(start: startDate, end: endDate)
    }
}

extension SearchVC: RoomVCDelegate {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int) {
        viewModel.updateSelectedRoomInfo(rooms: roomCount, adults: adults, children: children)
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRecentSearches()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(HistoryCell.self, for: indexPath)
        let vm = viewModel.historyCellViewModel(at: indexPath.row)
        cell.configure(with: vm)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .appBackground

        let titleLabel = UILabel()
        titleLabel.applyTitleStyle()
        titleLabel.text = "Continue your search"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parameters = viewModel.recentSearch(at: indexPath.row) else { return }
        let resultVC = ResultVC(searchParameters: parameters)
        resultVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.numberOfRecentSearches() == 0 ? 0 : 44
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }

            self.viewModel.deleteRecentSearch(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            let isEmpty = self.viewModel.numberOfRecentSearches() == 0
            self.recentSearchesTableView.isHidden = isEmpty
            self.emptyStateLabel.isHidden = !isEmpty

            completion(true)
        }

        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.image?.withTintColor(.appError)
        deleteAction.backgroundColor = .appBackground

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
