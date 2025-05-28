//
//  BookingMapInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.05.2025.
//

import UIKit
import MapKit

final class BookingMapInfoCell: UITableViewCell {
    
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = false
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 12
        map.layer.masksToBounds = true
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isUserInteractionEnabled = true
        return map
    }()
    
    private var latitude: Double = 0
    private var longitude: Double = 0
    private var name = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground
        contentView.addSubview(view)
        view.addSubview(mapView)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openInMaps))
        mapView.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(latitude: Double, longitude: Double, name: String) {
        self.latitude = latitude; self.longitude = longitude; self.name = name
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
    }
    
    @objc private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: nil)
    }
}
