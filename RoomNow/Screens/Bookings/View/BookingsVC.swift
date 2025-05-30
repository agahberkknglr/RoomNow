//
//  BookingsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class BookingsVC: UIViewController {
    
    private let viewModel = BookingsVM()
    private let tableView = UITableView()
    private let emptyView: UILabel = {
        let label = UILabel()
        label.text = "You haven't booked any hotels yet."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLatestReservations()
    }
    
    private func setupUI(){
        view.backgroundColor = .appBackground
        title = "Bookings"
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.registerCell(type: BookingCell.self)

        view.addSubview(tableView)
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        fetchLatestReservations()
    }
    
    private func fetchLatestReservations() {
        showLoadingIndicator()
        viewModel.fetchReservations { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingIndicator()
                let isEmpty = self.viewModel.groupedReservations.isEmpty
                self.tableView.isHidden = isEmpty
                self.emptyView.isHidden = !isEmpty
                self.tableView.reloadData()
            }
        }
    }
}

extension BookingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(BookingCell.self, for: indexPath)
        let reservation = viewModel.reservation(at: indexPath)
        let imageUrl = viewModel.imageURL(for: reservation.hotelId)
        cell.configure(with: reservation, imageURL: imageUrl)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.cityTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .appBackground

        let titleLabel = UILabel()
        titleLabel.applyTitleStyle()
        titleLabel.text = viewModel.cityTitle(for: section)
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

extension BookingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reservation = viewModel.reservation(at: indexPath)
        
        guard let id = reservation.id else {
            print("Reservation missing ID")
            return
        }

        let detailVM = BookingDetailVM(reservation: reservation, reservationId: id)
        let detailVC = BookingDetailVC(viewModel: detailVM)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
}
