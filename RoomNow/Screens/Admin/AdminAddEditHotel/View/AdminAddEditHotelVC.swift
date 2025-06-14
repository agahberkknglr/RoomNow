//
//  AdminAddEditHotelVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 10.06.2025.
//

import UIKit
import MapKit
import PhotosUI

final class AdminAddEditHotelVC: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let locationField = UITextField()
    private let descriptionView = UITextView()
    private let citySelectorButton = UIButton(type: .system)
    private let ratingStack = UIStackView()
    private var starButtons: [UIButton] = []
    private var selectedRating: Int = 0
    private let saveButton = UIButton(type: .system)
    private let mapPreview = MKMapView()
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var photoCollectionView: UICollectionView!
    private var hotelImages: [HotelImage] = []
    private var decodedImages: [UIImage] {
        viewModel.base64Images.compactMap {
            guard let data = Data(base64Encoded: $0) else { return nil }
            return UIImage(data: data)
        }
    }
    private var selectedAmenities: Set<Amenity> = []
    private var amenityCollectionView: UICollectionView!
    private let availabilitySwitch = UISwitch()
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Available"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

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
        setupNavBar()
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
    
    private func setupNavBar() {
        if viewModel.isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Manage Rooms",
                style: .plain,
                target: self,
                action: #selector(manageRoomsTapped)
            )
        }
    }

    private func setupFields() {
        func styledField(_ placeholder: String, _ field: UITextField) {
            field.borderStyle = .roundedRect
            field.placeholder = placeholder
            field.autocapitalizationType = .words
            contentStack.addArrangedSubview(field)
        }

        styledField("Hotel Name", nameField)
        nameField.applyButtonStyleLook()
        nameField.constrainHeight(to: 48)

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
        ratingLabel.applySubtitleSecondStyle()

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
        locationField.applyButtonStyleLook()
        locationField.constrainHeight(to: 48)

        let descLabel = UILabel()
        descLabel.text = "Description"
        descLabel.applySubtitleSecondStyle()
        contentStack.addArrangedSubview(descLabel)

        descriptionView.applyButtonStyleLook()
        contentStack.addArrangedSubview(descriptionView)
        descriptionView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let locationLabel = UILabel()
        locationLabel.text = "Hotel Location"
        locationLabel.applySubtitleSecondStyle()
        contentStack.addArrangedSubview(locationLabel)

        mapPreview.layer.cornerRadius = 8
        mapPreview.isScrollEnabled = false
        mapPreview.isUserInteractionEnabled = true
        mapPreview.heightAnchor.constraint(equalToConstant: 150).isActive = true
        contentStack.addArrangedSubview(mapPreview)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectLocationTapped))
        mapPreview.addGestureRecognizer(tapGesture)
        
        setupPhotoSection()

        let amenityLabel = UILabel()
        amenityLabel.text = "Amenities"
        amenityLabel.applySubtitleSecondStyle()
        contentStack.addArrangedSubview(amenityLabel)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 80)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8

        amenityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        amenityCollectionView.register(AmenityCell.self, forCellWithReuseIdentifier: "AmenityCell")
        amenityCollectionView.dataSource = self
        amenityCollectionView.delegate = self
        amenityCollectionView.backgroundColor = .clear
        amenityCollectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        contentStack.addArrangedSubview(amenityCollectionView)
        
        let availabilityStack = UIStackView(arrangedSubviews: [availabilityLabel, availabilitySwitch])
        availabilityStack.axis = .horizontal
        availabilityStack.spacing = 12
        availabilityStack.alignment = .center
        availabilitySwitch.addTarget(self, action: #selector(availabilitySwitchChanged), for: .valueChanged)

        contentStack.addArrangedSubview(availabilityStack)

        saveButton.applyPrimaryStyle(with: viewModel.isEditMode ? "Save Changes" : "Add Hotel")
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentStack.addArrangedSubview(saveButton)
    }

    private func fillFormIfNeeded() {
        nameField.text = viewModel.name
        locationField.text = viewModel.location
        descriptionView.text = viewModel.description
        
        let savedAmenities = viewModel.amenityList

        selectedAmenities = Set(savedAmenities.compactMap { Amenity.from(string: $0) })

        amenityCollectionView.reloadData()

        if let city = viewModel.selectedCity {
            citySelectorButton.setTitle(city.name.capitalized, for: .normal)
        }
        
        selectedRating = Int(Double(viewModel.rating) ?? 0)
        updateStarUI()
        
        if viewModel.base64Images.isEmpty == false {
            hotelImages = viewModel.base64Images.map { HotelImage.existing(base64: $0) }
        }
        
        if let lat = Double(viewModel.latitude), let lng = Double(viewModel.longitude) {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            selectedCoordinate = coord
            updateMapPreview(with: coord)
        }
        
        availabilitySwitch.isOn = viewModel.isAvailable
        availabilityLabel.text = viewModel.isAvailable ? "Hotel is Active" : "Hotel is Inactive"
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

    private func setupPhotoSection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 12

        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.showsHorizontalScrollIndicator = false

        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photoCollectionView.register(AddPhotoCell.self, forCellWithReuseIdentifier: "AddPhotoCell")

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self

        contentStack.addArrangedSubview(photoCollectionView)
    }
    
    @objc private func removePhotoTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < hotelImages.count else { return }
        hotelImages.remove(at: index)
        photoCollectionView.reloadData()
    }
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func showPhotoSourceOptions() {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.presentCamera()
            }))
        }

        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    @objc private func manageRoomsTapped() {
        guard let hotelId = viewModel.hotelToEdit?.id else { return }
        let vc = RoomListVC(hotelId: hotelId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func availabilitySwitchChanged() {
        availabilityLabel.text = availabilitySwitch.isOn ? "Hotel is Active" : "Hotel is Inactive"
    }
    
    @objc private func saveTapped() {
        saveButton.isEnabled = false
        showLoadingIndicator()

        viewModel.name = nameField.text ?? ""
        viewModel.rating = String(selectedRating)
        viewModel.location = locationField.text ?? ""
        viewModel.description = descriptionView.text ?? ""
        viewModel.setImages(hotelImages)
        viewModel.isAvailable = availabilitySwitch.isOn

        if let errorMessage = viewModel.validateFields() {
            showAlert(title: "Validation Error", message: errorMessage)
            hideLoadingIndicator()
            saveButton.isEnabled = true
            return
        }
        
        let selectedAmenityTitles = selectedAmenities.map { $0.rawValue }

        viewModel.amenityList = selectedAmenityTitles

        viewModel.saveHotel { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.saveButton.isEnabled = true
                
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

extension AdminAddEditHotelVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return hotelImages.count + 1
        } else if collectionView == amenityCollectionView {
            return Amenity.allCases.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            if indexPath.item == hotelImages.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath) as! AddPhotoCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
                cell.imageView.image = hotelImages[indexPath.item].uiImage
                cell.removeButton.tag = indexPath.item
                cell.removeButton.addTarget(self, action: #selector(removePhotoTapped(_:)), for: .touchUpInside)
                return cell
            }
        } else if collectionView == amenityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenityCell", for: indexPath) as! AmenityCell
            let amenity = Amenity.allCases[indexPath.item]
            cell.configure(with: amenity, selected: selectedAmenities.contains(amenity))
            return cell
        }

        fatalError("Unknown collectionView")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            if indexPath.item == hotelImages.count {
                showPhotoSourceOptions()
            }
        } else if collectionView == amenityCollectionView {
            let amenity = Amenity.allCases[indexPath.item]
            if selectedAmenities.contains(amenity) {
                selectedAmenities.remove(amenity)
            } else {
                selectedAmenities.insert(amenity)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension AdminAddEditHotelVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let dispatchGroup = DispatchGroup()

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                    defer { dispatchGroup.leave() }
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.hotelImages.append(.new(image: image))
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.photoCollectionView.reloadData()
        }
    }
}

extension AdminAddEditHotelVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            hotelImages.append(.new(image: image))
            photoCollectionView.reloadData()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
