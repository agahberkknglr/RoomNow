//
//  AdminAddEditHotelVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 10.06.2025.
//

import UIKit

final class AdminAddEditHotelVC: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let cityField = UITextField()
    private let ratingField = UITextField()
    private let locationField = UITextField()
    private let descriptionView = UITextView()
    private let latitudeField = UITextField()
    private let longitudeField = UITextField()
    private let imageUrlField = UITextField()
    private let amenitiesField = UITextField()

    private let saveButton = UIButton(type: .system)

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
        view.backgroundColor = .systemBackground
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
        styledField("City", cityField)
        styledField("Rating (e.g. 4.5)", ratingField)
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

        styledField("Latitude (e.g. 41.0082)", latitudeField)
        styledField("Longitude (e.g. 28.9784)", longitudeField)
        styledField("Image URL (optional)", imageUrlField)
        styledField("Amenities (comma-separated)", amenitiesField)

        saveButton.setTitle("Save Hotel", for: .normal)
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
        cityField.text = viewModel.city
        ratingField.text = viewModel.rating
        locationField.text = viewModel.location
        descriptionView.text = viewModel.description
        latitudeField.text = viewModel.latitude
        longitudeField.text = viewModel.longitude
        imageUrlField.text = viewModel.imageURL
        amenitiesField.text = viewModel.amenities
    }

    @objc private func saveTapped() {
        viewModel.name = nameField.text ?? ""
        viewModel.city = cityField.text ?? ""
        viewModel.rating = ratingField.text ?? ""
        viewModel.location = locationField.text ?? ""
        viewModel.description = descriptionView.text ?? ""
        viewModel.latitude = latitudeField.text ?? ""
        viewModel.longitude = longitudeField.text ?? ""
        viewModel.imageURL = imageUrlField.text ?? ""
        viewModel.amenities = amenitiesField.text ?? ""

        viewModel.saveHotel { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
