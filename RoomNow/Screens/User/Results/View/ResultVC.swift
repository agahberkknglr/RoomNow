//
//  ResultVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

import UIKit

protocol ResultVCProtocol: AnyObject {
    func configureVC()
}

final class ResultVC: UIViewController {
    
    private var viewModel: ResultVMProtocol
    private var collectionView: UICollectionView!
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No hotels found"
        label.textAlignment = .center
        label.textColor = .appSecondaryText
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    private let titleButton = UIButton()
    private let destinationButton = SearchOptionButton()
    private let dateButton = SearchOptionButton()
    private let roomButton = SearchOptionButton()
    private let expandableSearchBar: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    private let backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    private var isFirstAppearance = true
    private let refreshControl = UIRefreshControl()

    init(searchParameters: HotelSearchParameters) {
        let vm = ResultVM(searchParameters: searchParameters)
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
        vm.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        setupNavigationTitle()
        setupBackdropView()
        setupExpandableSearchBar()
        updateSearchBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitleFromSearchParams()
        if isFirstAppearance {
            showLoadingIndicator()
            isFirstAppearance = false
        }
        collectionView.reloadData()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title =  ""
    }
    
    private func setTitleFromSearchParams() {
        let city = viewModel.searchParameters.destination.capitalized

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")

        let checkIn = formatter.string(from: viewModel.searchParameters.checkInDate)
        let checkOut = formatter.string(from: viewModel.searchParameters.checkOutDate)

        let title = "\(city)   \(checkIn) - \(checkOut)"
        titleButton.setTitle(title, for: .normal)
        print(title)
    }
    
    private func setupNavigationTitle() {
        titleButton.setTitleColor(.label, for: .normal)
        titleButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        titleButton.addTarget(self, action: #selector(toggleSearchOptions), for: .touchUpInside)
        navigationItem.titleView = titleButton
    }
    
    private func setupExpandableSearchBar() {
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)

        [destinationButton, dateButton, roomButton].forEach {
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            expandableSearchBar.addArrangedSubview($0)
        }

        view.addSubview(expandableSearchBar)
        expandableSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expandableSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            expandableSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expandableSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    
    private func updateSearchBarButtons() {
        destinationButton.setTitle(viewModel.searchParameters.destination.capitalized, for: .normal)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        let checkIn = formatter.string(from: viewModel.searchParameters.checkInDate)
        let checkOut = formatter.string(from: viewModel.searchParameters.checkOutDate)
        dateButton.setTitle("\(checkIn) - \(checkOut)", for: .normal)

        let roomText = "\(viewModel.searchParameters.roomCount) room\(viewModel.searchParameters.roomCount > 1 ? "s" : ""), \(viewModel.searchParameters.guestCount) guest\(viewModel.searchParameters.guestCount > 1 ? "s" : "")"
        roomButton.setTitle(roomText, for: .normal)
    }

    
    
    private func refreshResults() {
        setTitleFromSearchParams()
        updateSearchBarButtons()
        showLoadingIndicator()
        viewModel.fetchHotels()
    }
    
    @objc private func openDestinationSheet() {
        let vc = DestinationVC()
        vc.delegate = self
        presentBottomSheet(with: vc, detents: [.large()])
    }
    
    @objc private func openDateSheet() {
        let dateVC = DateVC()
        dateVC.selectedStartDate = viewModel.searchParameters.checkInDate
        dateVC.selectedEndDate = viewModel.searchParameters.checkOutDate
        dateVC.delegate = self
        presentBottomSheet(with: dateVC, detents: [.medium()])
    }

    @objc private func openRoomSheet() {
        let roomVM = RoomVM(
            rooms: viewModel.searchParameters.roomCount,
            adults: viewModel.searchParameters.guestCount,
            children: 0
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
    
    private func setupBackdropView() {
        view.addSubview(backdropView)
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSearchOptions))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleSearchOptions() {
        isSearchOptionsVisible ? hideSearchOptions() : showSearchOptions()
    }

    private var isSearchOptionsVisible: Bool {
        return !expandableSearchBar.isHidden
    }

    private func showSearchOptions() {
        backdropView.isHidden = false
        expandableSearchBar.isHidden = false
        expandableSearchBar.alpha = 0
        backdropView.alpha = 0

        UIView.animate(withDuration: 0.5) {
            self.backdropView.alpha = 1
            self.expandableSearchBar.alpha = 1
        }
    }

    private func hideSearchOptions() {
        UIView.animate(withDuration: 0.5, animations: {
            self.backdropView.alpha = 0
            self.expandableSearchBar.alpha = 0
        }, completion: { _ in
            self.backdropView.isHidden = true
            self.expandableSearchBar.isHidden = true
        })
    }

}

extension ResultVC: ResultVMDelegate {
    func didFetchHotels() {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = self.viewModel.filteredHotelRooms.count > 0
        }
    }
}

extension ResultVC: ResultVCProtocol {
    func configureVC() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupEmptyLabel()
        viewModel.fetchHotels()
        setupFilterButton()
    }
    
    private func setupFilterButton() {
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(openFilterVC))
        navigationItem.rightBarButtonItem = filterButton
    }
    
    @objc private func openFilterVC() {
        let currentFilter = (viewModel as? ResultVM)?.currentFilter
        let filterVC = FilterSortVC(currentFilter: currentFilter)
        filterVC.onApplyFilter = { [weak self] options in
            (self?.viewModel as? ResultVM)?.applyFilter(options)
        }
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }

    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 230)
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HotelCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = view.backgroundColor
        
        refreshControl.addTarget(self, action: #selector(refreshHotels), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func refreshHotels() {
        viewModel.fetchHotels()
    }
    
    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func applyFilterAndSort(_ options: HotelFilterOptions) {
        viewModel.applyFilter(options)
    }
}

extension ResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredHotelRooms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(HotelCell.self, for: indexPath)
        let item = viewModel.filteredHotelRooms[indexPath.item]
        let cellVM = HotelCellVM(hotel: item.hotel, rooms: item.rooms, searchParams: viewModel.searchParameters)
        cell.configure(with: cellVM)
        return cell
    }
}

extension ResultVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.filteredHotelRooms[indexPath.item]
        let detailVM = HotelDetailVM(hotel: item.hotel, rooms: item.rooms, searchParams: viewModel.searchParameters)
        let detailVC = HotelDetailVC(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ResultVC: DestinationVCDelegate {
    func didSelectCity(_ city: City) {
        viewModel.searchParameters.destination = city.name
        updateSearchBarButtons()
        refreshResults()
    }
}

extension ResultVC: DateVCDelegate {
    func didSelectDateRange(_ startDate: Date, _ endDate: Date) {
        viewModel.searchParameters.checkInDate = startDate
        viewModel.searchParameters.checkOutDate = endDate
        updateSearchBarButtons()
        refreshResults()
    }
}

extension ResultVC: RoomVCDelegate {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int) {
        viewModel.searchParameters.roomCount = roomCount
        viewModel.searchParameters.guestCount = adults
        updateSearchBarButtons()
        refreshResults()
    }
}
