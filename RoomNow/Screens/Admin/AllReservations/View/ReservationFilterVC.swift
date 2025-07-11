//
//  ReservationFilterVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.06.2025.
//

import UIKit

final class ReservationFilterVC: UIViewController {

    var cities: [String]
    var hotels: [String]
    var selected: ReservationFilter
    var onFilterSelected: ((ReservationFilter) -> Void)?
    private let statuses = ReservationStatus.allCases

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search name or email"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private enum Section: Int, CaseIterable {
        case city
        case hotel
        case status
    }


    init(cities: [String], hotels: [String], selected: ReservationFilter) {
        self.cities = cities
        self.hotels = hotels
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Filter Reservations"
        view.backgroundColor = .appBackground

        view.addSubview(searchBar)
        searchBar.delegate = self

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let applyButton = UIButton(type: .system)
        applyButton.applyPrimaryStyle(with: "Apply Filter")
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.translatesAutoresizingMaskIntoConstraints = false

        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        navigationItem.leftBarButtonItem = clearButton

        let footer = UIView()
        footer.addSubview(applyButton)
        applyButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16).isActive = true
        applyButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16).isActive = true
        applyButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 12).isActive = true
        applyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        tableView.tableFooterView = footer
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
    }


    @objc private func applyTapped() {
        onFilterSelected?(selected)
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        selected = ReservationFilter()
        tableView.reloadData()
    }
}

extension ReservationFilterVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .city: return cities.count
        case .hotel: return hotels.count
        case .status: return statuses.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .city: return "City"
        case .hotel: return "Hotel"
        case .status: return "Status"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .city:
            let value = cities[indexPath.row]
            cell.textLabel?.text = value.capitalized
            cell.accessoryType = selected.selectedCities.contains(value) ? .checkmark : .none

        case .hotel:
            let value = hotels[indexPath.row]
            cell.textLabel?.text = value
            cell.accessoryType = selected.selectedHotels.contains(value) ? .checkmark : .none
            
        case .status:
            let value = statuses[indexPath.row]
            cell.textLabel?.text = value.rawValue.capitalized
            cell.accessoryType = selected.selectedStatuses.contains(value) ? .checkmark : .none
            cell.textLabel?.textColor = value.color

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .city:
            let value = cities[indexPath.row]
            if selected.selectedCities.contains(value) {
                selected.selectedCities.remove(value)
            } else {
                selected.selectedCities.insert(value)
            }

        case .hotel:
            let value = hotels[indexPath.row]
            if selected.selectedHotels.contains(value) {
                selected.selectedHotels.remove(value)
            } else {
                selected.selectedHotels.insert(value)
            }
            
        case .status:
            let value = statuses[indexPath.row]
            if selected.selectedStatuses.contains(value) {
                selected.selectedStatuses.remove(value)
            } else {
                selected.selectedStatuses.insert(value)
            }
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ReservationFilterVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        selected.userQuery = searchText
    }
}
