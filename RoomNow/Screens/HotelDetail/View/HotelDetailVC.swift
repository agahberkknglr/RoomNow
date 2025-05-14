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
}

final class HotelDetailVC: UIViewController {
    
    private let viewModel: HotelDetailVMProtocol
    private let tableView = UITableView(frame: .zero, style: .plain)
    
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelTitleCell.self), for: indexPath) as? HotelTitleCell else {
                return UITableViewCell()
            }
            cell.configure(name: viewModel.hotelName, location: viewModel.location, rating: viewModel.ratingText)
            return cell

        case .imageGallery:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelImageCell.self), for: indexPath) as? HotelImageCell,
                  let imageUrls = section.data as? [String] else {
                return UITableViewCell()
            }
            cell.configure(with: imageUrls)
            return cell
        //case .imageGallery:
        //    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelImageCell.self), for: indexPath) as? HotelImageCell,
        //          let imageUrls = section.data as? [String] else {
        //        return UITableViewCell()
        //    }
        //    cell.configure(with: imageUrls)
        //    return cell
        
        case .checkInOut:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelCheckInOutCell.self), for: indexPath) as? HotelCheckInOutCell else {
                return UITableViewCell()
            }
            cell.configure(checkIn: viewModel.checkInDateText, checkOut: viewModel.checkOutDateText)
            return cell
        
        case .roomGuestInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelRoomGuestInfoCell.self), for: indexPath) as? HotelRoomGuestInfoCell else {
                return UITableViewCell()
            }
            cell.configure(info: viewModel.guestInfoText)
            return cell
            
        case .cheapestRoom:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelCheapestRoomCell.self), for: indexPath) as? HotelCheapestRoomCell else {
                return UITableViewCell()
            }
            cell.configure(price: viewModel.cheapestRoom?.price ?? 0, startDate: viewModel.checkInDate, endDate: viewModel.checkOutDate)
            return cell
            
        case .map:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelMapCell.self), for: indexPath) as? HotelMapCell else {
                return UITableViewCell()
            }
            cell.configure(locationText: viewModel.location, mockCoordinate: viewModel.mockCoordinate)
            return cell
            
        case .amenities:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelAmenitiesCell.self), for: indexPath) as? HotelAmenitiesCell else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel.amenities)
            return cell
        case .description:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDescriptionCell.self), for: indexPath) as? HotelDescriptionCell else {
                return UITableViewCell()
            }
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

}
