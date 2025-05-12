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
}

extension ResultVC: ResultVMDelegate {
    func didFetchHotels() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = self.viewModel.hotels.count > 0
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
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 250)
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HotelCell.self, forCellWithReuseIdentifier: HotelCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = view.backgroundColor
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        viewModel.hotels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotelCell.identifier, for: indexPath) as? HotelCell else {
            return UICollectionViewCell()
        }
        
        let hotel = viewModel.hotels[indexPath.item]
        cell.configure(with: hotel, searchParams: viewModel.searchParameters)
        return cell
    }
}

extension ResultVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHotel = viewModel.hotels[indexPath.item]
        let detailVM = HotelDetailVM(hotel: selectedHotel, searchParams: viewModel.searchParameters)
        let detailVC = HotelDetailVC(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
