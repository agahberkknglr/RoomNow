//
//  FilterSortVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.06.2025.
//

import UIKit

struct HotelFilterOptions {
    var minRating: Double?
    var sortBy: SortType?
    var selectedAmenities: [Amenity]

    enum SortType: String, CaseIterable {
        case priceAsc = "Price: Low to High"
        case priceDesc = "Price: High to Low"
        case ratingAsc = "Rating: Low to High"
        case ratingDesc = "Rating: High to Low"
    }
}

final class FilterSortVC: UIViewController {
    
    var onApplyFilter: ((HotelFilterOptions) -> Void)?
    
    private var selectedSort: HotelFilterOptions.SortType?
    private var selectedMinRating: Double?
    private var selectedAmenities: [Amenity] = []
    private let availableAmenities: [Amenity] = Amenity.allCases
    private var showAllAmenities = false


    
    init(currentFilter: HotelFilterOptions?) {
        if let filter = currentFilter {
            self.selectedSort = filter.sortBy
            self.selectedMinRating = filter.minRating
            self.selectedAmenities = filter.selectedAmenities
        } else {
            self.selectedSort = nil
            self.selectedMinRating = nil
            self.selectedAmenities = []
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private enum Section: Int, CaseIterable {
        case sort, rating, amenities
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Filter & Sort"
        setupTableView()
        setupNavButtons()
    }
    
    private func setupNavButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    @objc private func applyTapped() {
        let options = HotelFilterOptions(
            minRating: selectedMinRating,
            sortBy: selectedSort,
            selectedAmenities: selectedAmenities
        )
        onApplyFilter?(options)
        dismiss(animated: true)
    }

    @objc private func resetTapped() {
        selectedSort = nil
        selectedMinRating = nil
        selectedAmenities = []
        tableView.reloadData()
    }
}

extension FilterSortVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .sort:
            return HotelFilterOptions.SortType.allCases.count
        case .rating:
            return 5
        case .amenities:
            return showAllAmenities ? availableAmenities.count + 1 : min(5, availableAmenities.count) + 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        switch sec {
        case .sort: return "Sort By"
        case .rating: return "Minimum Rating"
        case .amenities: return "Amenities"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sec = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textAlignment = .natural
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.imageView?.image = nil
        cell.accessoryType = .none

        switch sec {
        case .sort:
            let sort = HotelFilterOptions.SortType.allCases[indexPath.row]
            cell.textLabel?.text = sort.rawValue
            cell.accessoryType = (sort == selectedSort) ? .checkmark : .none

        case .rating:
            let rating = Double(indexPath.row + 1)
            cell.textLabel?.text = "\(rating)+ stars"
            cell.accessoryType = (rating == selectedMinRating) ? .checkmark : .none

        case .amenities:
            let visibleCount = showAllAmenities ? availableAmenities.count : min(5, availableAmenities.count)
            
            if indexPath.row < visibleCount {
                let amenity = availableAmenities[indexPath.row]
                cell.textLabel?.text = amenity.title
                cell.imageView?.image = amenity.icon
                cell.imageView?.tintColor = .appAccent
                cell.accessoryType = selectedAmenities.contains(amenity) ? .checkmark : .none
            } else {
                cell.textLabel?.text = showAllAmenities ? "Show Less" : "Show More"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .appAccent
            }
        }

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sec = Section(rawValue: indexPath.section) else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        switch sec {
        case .sort:
            selectedSort = HotelFilterOptions.SortType.allCases[indexPath.row]
        case .rating:
            let rating = Double(indexPath.row + 1)
            selectedMinRating = (selectedMinRating == rating) ? nil : rating
        case .amenities:
            if indexPath.row < min(availableAmenities.count, showAllAmenities ? availableAmenities.count : 5) {
                let amenity = availableAmenities[indexPath.row]
                if selectedAmenities.contains(amenity) {
                    selectedAmenities.removeAll { $0 == amenity }
                } else {
                    selectedAmenities.append(amenity)
                }
            } else {
                showAllAmenities.toggle()
            }

            tableView.reloadSections([indexPath.section], with: .automatic)


        }

        tableView.reloadSections([indexPath.section], with: .automatic)
    }
}


