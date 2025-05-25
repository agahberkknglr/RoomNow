//
//  SavedHotelsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.05.2025.
//

import UIKit

final class SavedHotelsVC: UIViewController {

    private let viewModel: SavedHotelsVM
    private let collectionView: UICollectionView
    
    private let emptyView: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No saved hotels yet."
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(city: String, hotels: [SavedHotel]) {
        self.viewModel = SavedHotelsVM(city: city, savedHotels: hotels)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        self.title = city.capitalized
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateEmptyViewVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadSavedHotels { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.updateEmptyViewVisibility()
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        collectionView.backgroundColor = .clear

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SavedHotelCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear

        view.addSubview(collectionView)
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func showUnsaveAlert(for hotel: SavedHotel, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Remove Hotel",
            message: "Are you sure you want to remove this hotel from your saved list?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            FirebaseManager.shared.deleteSavedHotel(hotelId: hotel.hotelId) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.viewModel.removeHotel(at: indexPath.item)
                        self?.collectionView.deleteItems(at: [indexPath])
                        self?.updateEmptyViewVisibility()
                    }
                case .failure(let error):
                    print("❌ Failed to unsave hotel:", error.localizedDescription)
                }
            }
        })

        present(alert, animated: true)
    }
    
    private func updateEmptyViewVisibility() {
        let isEmpty = viewModel.numberOfItems == 0
        emptyView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
}

extension SavedHotelsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let saved = viewModel.hotel(at: indexPath.item)
        let cell = collectionView.dequeue(SavedHotelCell.self, for: indexPath)
        cell.configure(with: saved)
        print(viewModel.hotel(at: indexPath.item).hotelName)
        
        cell.onSaveTapped = { [weak self] in
            self?.showUnsaveAlert(for: saved, at: indexPath)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let saved = viewModel.hotel(at: indexPath.item)
        
        FirebaseManager.shared.fetchHotel(by: saved.hotelId) { [weak self] result in
            switch result {
            case .success(let fullHotel):
                FirebaseManager.shared.fetchRooms(for: [saved.hotelId]) { roomResult in
                    switch roomResult {
                    case .success(let rooms):
                        let params = HotelSearchParameters(
                            destination: saved.city,
                            checkInDate: saved.checkInDate,
                            checkOutDate: saved.checkOutDate,
                            guestCount: saved.guestCount,
                            roomCount: saved.roomCount
                        )
                        let detailVM = HotelDetailVM(hotel: fullHotel, rooms: rooms, searchParams: params)
                        let detailVC = HotelDetailVC(viewModel: detailVM)
                        DispatchQueue.main.async {
                            self?.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    case .failure(let error):
                        print("❌ Failed to fetch rooms:", error.localizedDescription)
                    }
                }
            case .failure(let error):
                print("❌ Failed to fetch hotel:", error.localizedDescription)
            }
        }
    }

}

