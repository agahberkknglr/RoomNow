//
//  ViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

final class SearchVC: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let destinationButton = SearchOptionButton()
    private let dateButton = SearchOptionButton()
    private let roomButton = SearchOptionButton()
    private let searchButton = UIButton()
    private let titleLabel = UILabel()
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
    
    private var recentSearchesTableHeightConstraint: NSLayoutConstraint?

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
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.applyPrimaryStyle(with: "Search Now")
        
        [destinationButton, dateButton, roomButton, searchButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            contentStack.addArrangedSubview($0)
        }
        
        contentStack.setCustomSpacing(32, after: searchButton)
        
        titleLabel.text = "Continue your search"
        titleLabel.applyTitleStyle()
        contentStack.addArrangedSubview(titleLabel)

        recentSearchesTableView.backgroundColor = .clear
        recentSearchesTableView.separatorStyle = .none
        recentSearchesTableView.isScrollEnabled = false
        recentSearchesTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.delegate = self
        recentSearchesTableView.registerCell(type: HistoryCell.self)
        
        contentStack.addArrangedSubview(recentSearchesTableView)

        let initialHeight = CGFloat(0)
        let constraint = recentSearchesTableView.heightAnchor.constraint(equalToConstant: initialHeight)
        constraint.isActive = true
        self.recentSearchesTableHeightConstraint = constraint
        
        contentStack.addArrangedSubview(emptyStateLabel)
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

        let count = viewModel.numberOfRecentSearches()
        let isEmpty = count == 0
        recentSearchesTableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
        titleLabel.isHidden = isEmpty

        recentSearchesTableHeightConstraint?.constant = CGFloat(min(count, 5) * 80)

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
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HistoryCell {
            cell.animateForSwipe()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath,
           let cell = tableView.cellForRow(at: indexPath) as? HistoryCell {
            cell.resetSwipeState()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }

            if let cell = tableView.cellForRow(at: indexPath) as? HistoryCell {
                cell.animateDelete {
                    self.viewModel.deleteRecentSearch(at: indexPath.row)
                    completion(true)
                }
            } else {
                self.viewModel.deleteRecentSearch(at: indexPath.row)
                completion(true)
            }
        }
        
        deleteAction.backgroundColor = .appBackground
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
