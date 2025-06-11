//
//  AdminAddEditHotelVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 10.06.2025.
//

import UIKit
import MapKit

final class AdminAddEditHotelVC: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let locationField = UITextField()
    private let descriptionView = UITextView()
    private let imageUrlField = UITextField()
    private let amenitiesField = UITextField()
    private let citySelectorButton = UIButton(type: .system)
    private let ratingStack = UIStackView()
    private var starButtons: [UIButton] = []
    private var selectedRating: Int = 0
    private let saveButton = UIButton(type: .system)
    private let mapPreview = MKMapView()
    private var selectedCoordinate: CLLocationCoordinate2D?
    
    private let viewModel: AdminAddEditHotelVM

    init(hotel: Hotel? = nil) {
        self.viewModel = AdminAddEditHotelVM(hotel: hotel)
        super.init(nibName: nil, bundle: nil)
        title = viewModel.isEditMode ? "Edit Hotel" : "Add Hotel"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupScrollView()
        setupFields()
        fillFormIfNeeded()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func setupFields() {
        func styledField(_ placeholder: String, _ field: UITextField) {
            field.borderStyle = .roundedRect
            field.placeholder = placeholder
            field.autocapitalizationType = .words
            contentStack.addArrangedSubview(field)
        }

        styledField("Hotel Name", nameField)

        citySelectorButton.setTitle("Select City ▾", for: .normal)
        citySelectorButton.contentHorizontalAlignment = .left
        citySelectorButton.titleLabel?.font = .systemFont(ofSize: 16)
        citySelectorButton.setTitleColor(.label, for: .normal)
        citySelectorButton.backgroundColor = .systemGray6
        citySelectorButton.layer.cornerRadius = 8
        citySelectorButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        citySelectorButton.addTarget(self, action: #selector(selectCityTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(citySelectorButton)

        let ratingLabel = UILabel()
        ratingLabel.text = "Hotel Rating"
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)

        ratingStack.axis = .horizontal
        ratingStack.spacing = 8
        ratingStack.distribution = .fillEqually
        ratingStack.alignment = .center

        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .appAccent
            button.tag = i
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            ratingStack.addArrangedSubview(button)
            starButtons.append(button)
        }

        contentStack.addArrangedSubview(ratingLabel)
        contentStack.addArrangedSubview(ratingStack)

        styledField("Location (e.g. Taksim)", locationField)

        let descLabel = UILabel()
        descLabel.text = "Description"
        contentStack.addArrangedSubview(descLabel)

        descriptionView.font = .systemFont(ofSize: 16)
        descriptionView.layer.borderColor = UIColor.separator.cgColor
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.cornerRadius = 8
        contentStack.addArrangedSubview(descriptionView)
        descriptionView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let locationLabel = UILabel()
        locationLabel.text = "Hotel Location"
        locationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(locationLabel)

        mapPreview.layer.cornerRadius = 8
        mapPreview.isScrollEnabled = false
        mapPreview.isUserInteractionEnabled = true
        mapPreview.heightAnchor.constraint(equalToConstant: 150).isActive = true
        contentStack.addArrangedSubview(mapPreview)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectLocationTapped))
        mapPreview.addGestureRecognizer(tapGesture)
        
        styledField("Image URL (optional)", imageUrlField)
        styledField("Amenities (comma-separated)", amenitiesField)

        saveButton.setTitle(viewModel.isEditMode ? "Save Changes" : "Add Hotel", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentStack.addArrangedSubview(saveButton)
    }

    private func fillFormIfNeeded() {
        nameField.text = viewModel.name
        locationField.text = viewModel.location
        descriptionView.text = viewModel.description
        imageUrlField.text = viewModel.imageURL
        amenitiesField.text = viewModel.amenities

        if let city = viewModel.selectedCity {
            citySelectorButton.setTitle(city.name.capitalized, for: .normal)
        }
        
        selectedRating = Int(Double(viewModel.rating) ?? 0)
        updateStarUI()
        
        if let lat = Double(viewModel.latitude), let lng = Double(viewModel.longitude) {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            selectedCoordinate = coord
            updateMapPreview(with: coord)
        }
    }

    @objc private func selectCityTapped() {
        viewModel.loadCities { [weak self] in
            guard let self = self else { return }
            let cityVC = CitySelectionVC(cities: self.viewModel.availableCities)
            cityVC.onCitySelected = { selected in
                self.viewModel.selectedCity = selected
                self.citySelectorButton.setTitle(selected.name.capitalized, for: .normal)
            }
            let nav = UINavigationController(rootViewController: cityVC)
            self.present(nav, animated: true)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarUI()
    }

    private func updateStarUI() {
        for (index, button) in starButtons.enumerated() {
            let filled = index < selectedRating
            let imageName = filled ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @objc private func selectLocationTapped() {
        let mapVC = MapSelectionVC()
        mapVC.initialCoordinate = selectedCoordinate
        mapVC.onLocationSelected = { [weak self] coordinate in
            self?.selectedCoordinate = coordinate
            self?.viewModel.latitude = String(coordinate.latitude)
            self?.viewModel.longitude = String(coordinate.longitude)
            self?.updateMapPreview(with: coordinate)
        }
        let nav = UINavigationController(rootViewController: mapVC)
        present(nav, animated: true)
    }
    
    private func updateMapPreview(with coordinate: CLLocationCoordinate2D) {
        mapPreview.removeAnnotations(mapPreview.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapPreview.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapPreview.setRegion(region, animated: false)
    }

    @objc private func saveTapped() {
        viewModel.name = nameField.text ?? ""
        viewModel.rating = String(selectedRating)
        viewModel.location = locationField.text ?? ""
        viewModel.description = descriptionView.text ?? ""
        viewModel.imageURL = imageUrlField.text ?? ""
        viewModel.amenities = amenitiesField.text ?? ""
        
        if let errorMessage = viewModel.validateFields() {
            showAlert(title: "Validation Error", message: errorMessage)
            return
        }

        viewModel.saveHotel { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }
}
