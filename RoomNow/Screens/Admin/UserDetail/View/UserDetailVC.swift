//
//  UserDetailVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import UIKit

final class UserDetailVC: UIViewController {
    private var viewModel: UserDetailVMProtocol

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let genderLabel = UILabel()
    private let dobLabel = UILabel()
    private let countLabel = UILabel()
    private let tableView = UITableView()

    init(viewModel: UserDetailVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.onDataChanged = { [weak self] in
            self?.countLabel.text = "Reservations: \(self?.viewModel.reservations.count ?? 0)"
            self?.tableView.reloadData()
        }
        viewModel.fetchReservations()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        title = viewModel.user.username

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .appAccent
        imageView.setImage(fromBase64: viewModel.user.profileImageBase64, placeholder: "person.crop.circle.fill")

        nameLabel.text = viewModel.user.username
        nameLabel.font = .boldSystemFont(ofSize: 20)

        emailLabel.text = viewModel.user.email
        emailLabel.textColor = .secondaryLabel
        
        genderLabel.text = viewModel.user.gender
        genderLabel.textColor = .secondaryLabel
        
        dobLabel.text = viewModel.user.dateOfBirth
        dobLabel.textColor = .secondaryLabel

        countLabel.text = "Reservations: -"
        countLabel.font = .systemFont(ofSize: 14)

        let infoStack = UIStackView(arrangedSubviews: [imageView, nameLabel, emailLabel, genderLabel, dobLabel, countLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .center
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .appBackground
        tableView.registerCell(type: ReservationCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(infoStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            infoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension UserDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reservations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = viewModel.reservations[indexPath.row]
        let cell = tableView.dequeue(ReservationCell.self, for: indexPath)
        cell.configure(with: res)
        cell.backgroundColor = .appBackground
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reservation = viewModel.reservations[indexPath.row]
        guard let id = reservation.id else { return }
        let vm = BookingDetailVM(reservation: reservation, reservationId: id)
        let vc = BookingDetailVC(viewModel: vm, isAdminMode: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}

