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
    
    private let viewModel: ResultVMProtocol
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
        viewModel.fetchHotels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        setTitleFromSearchParams()
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

        self.title = "\(city)    \(checkIn) - \(checkOut)"
    }
}

extension ResultVC: ResultVMDelegate {
    func didFetchHotels() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = self.viewModel.hotelRooms.count > 0
        }
    }
}

extension ResultVC: ResultVCProtocol {
    func configureVC() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupEmptyLabel()
        viewModel.fetchHotels()
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
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hotelRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(HotelCell.self, for: indexPath)
        let item = viewModel.hotelRooms[indexPath.item]
        let cellVM = HotelCellVM(hotel: item.hotel, rooms: item.rooms, searchParams: viewModel.searchParameters)
        cell.configure(with: cellVM)
        return cell
    }
}

extension ResultVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.hotelRooms[indexPath.item]
        let detailVM = HotelDetailVM(hotel: item.hotel, rooms: item.rooms, searchParams: viewModel.searchParameters)
        let detailVC = HotelDetailVC(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
