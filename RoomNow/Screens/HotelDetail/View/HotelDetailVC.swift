//
//  HotelDetailVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

protocol HotelDetailVCProtocol: AnyObject {
    func configureVC()
    func setupTableView()
    func registerTableView()
    func setupSelectRoomButton()
}

final class HotelDetailVC: UIViewController {
    
    private let viewModel: HotelDetailVMProtocol
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let selectRoomButton = UIButton()
    private let buttonView = UIView()
    
    private var isDescriptionExpanded = false

    init(viewModel: HotelDetailVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        setupTableView()
        registerTableView()
        setupSelectRoomButton()
    }
}

extension HotelDetailVC: HotelDetailVCProtocol {
    func configureVC() {
        view.backgroundColor = .appBackground
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = view.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .appDivider
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func registerTableView() {
        tableView.registerCell(type: HotelTitleCell.self)
        tableView.registerCell(type: HotelImageCell.self)
        tableView.registerCell(type: HotelCheckInOutCell.self)
        tableView.registerCell(type: HotelRoomGuestInfoCell.self)
        tableView.registerCell(type: HotelCheapestRoomCell.self)
        tableView.registerCell(type: HotelMapCell.self)
        tableView.registerCell(type: HotelAmenitiesCell.self)
        tableView.registerCell(type: HotelDescriptionCell.self)
    }
    
    func setupSelectRoomButton() {
        selectRoomButton.setTitle("Select Room", for: .normal)
        selectRoomButton.backgroundColor = .appButtonBackground
        selectRoomButton.setTitleColor(.appAccent, for: .normal)
        selectRoomButton.layer.cornerRadius = 8
        selectRoomButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        selectRoomButton.addTarget(self, action: #selector(selectRoomTapped), for: .touchUpInside)
        
        buttonView.backgroundColor = .appSecondaryBackground
        
        buttonView.addSubview(selectRoomButton)
        view.addSubview(buttonView)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        selectRoomButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectRoomButton.heightAnchor.constraint(equalToConstant: 50),
            
            selectRoomButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 16),
            selectRoomButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            selectRoomButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            selectRoomButton.bottomAnchor.constraint(equalTo: buttonView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
    }
    
    @objc private func selectRoomTapped() {
        navigateToRoomTypeSelection()
    }
    
    private func navigateToRoomTypeSelection() {
        let hotel = viewModel.hotelForNavigation
        let params = viewModel.searchParamsForNavigation
        let vc = RoomSelectionVC(hotel: hotel, searchParams: params)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HotelDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        switch section.type {
        case .title:
            let cell = tableView.dequeue(HotelTitleCell.self, for: indexPath)

            cell.configure(name: viewModel.hotelName, location: viewModel.location, rating: viewModel.ratingText)
            return cell

        case .imageGallery:
            let cell = tableView.dequeue(HotelImageCell.self, for: indexPath)
            cell.configure(with: viewModel.imageUrls)
            return cell
        //case .imageGallery:
        //    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelImageCell.self), for: indexPath) as? HotelImageCell,
        //          let imageUrls = section.data as? [String] else {
        //        return UITableViewCell()
        //    }
        //    cell.configure(with: imageUrls)
        //    return cell
        
        case .checkInOut:
            let cell = tableView.dequeue(HotelCheckInOutCell.self, for: indexPath)
            cell.configure(checkIn: viewModel.checkInDateText, checkOut: viewModel.checkOutDateText)
            return cell
        
        case .roomGuestInfo:
            let cell = tableView.dequeue(HotelRoomGuestInfoCell.self, for: indexPath)
            cell.configure(info: viewModel.guestInfoText)
            return cell
            
        case .cheapestRoom:
            let cell = tableView.dequeue(HotelCheapestRoomCell.self, for: indexPath)
            cell.configure(price: viewModel.cheapestRoom?.price ?? 0, startDate: viewModel.checkInDate, endDate: viewModel.checkOutDate)
            return cell
            
        case .map:
            let cell = tableView.dequeue(HotelMapCell.self, for: indexPath)
            cell.configure(locationText: viewModel.location, mockCoordinate: viewModel.mockCoordinate)
            return cell
            
        case .amenities:
            let cell = tableView.dequeue(HotelAmenitiesCell.self, for: indexPath)
            cell.configure(with: viewModel.amenities)
            return cell
        case .description:
            let cell = tableView.dequeue(HotelDescriptionCell.self, for: indexPath)
            cell.configure(with: viewModel.description, isExpanded: isDescriptionExpanded)
            cell.onToggle = { [weak self] in
                guard let self = self else { return }
                self.isDescriptionExpanded.toggle()
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = viewModel.sections[indexPath.section].type
        switch section {
        case .imageGallery:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
}

extension HotelDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        if section.type == .cheapestRoom {
            navigateToRoomTypeSelection()
        }
    }
}
