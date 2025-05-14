//
//  HotelMapCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit
import MapKit

final class HotelMapCell: UITableViewCell {
    
    private let view = UIView()
    private let mapView = MKMapView()
    private let addressLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .appBackground
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.backgroundColor = .clear

        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        mapView.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .appPrimaryText
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 2
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapView)
        view.addSubview(addressLabel)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 160),

            addressLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(locationText: String, mockCoordinate: CLLocationCoordinate2D) {
        addressLabel.text = locationText

        let region = MKCoordinateRegion(center: mockCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = mockCoordinate
        annotation.title = locationText
        mapView.addAnnotation(annotation)
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openInMaps))
        contentView.addGestureRecognizer(tap)
    }

    @objc private func openInMaps() {
        // Example: open in Apple Maps with fake coordinate
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784) // Istanbul by default
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = addressLabel.text
        mapItem.openInMaps(launchOptions: nil)
    }

}
