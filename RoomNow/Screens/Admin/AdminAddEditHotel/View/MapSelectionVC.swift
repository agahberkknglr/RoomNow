//
//  MapSelectionVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 11.06.2025.
//

import UIKit
import MapKit

final class MapSelectionVC: UIViewController {

    private let mapView = MKMapView()
    private var selectedCoordinate: CLLocationCoordinate2D?
    var initialCoordinate: CLLocationCoordinate2D?
    var onLocationSelected: ((CLLocationCoordinate2D) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Location"
        view.backgroundColor = .systemBackground
        setupMap()
        setupNavBar()
    }

    private func setupMap() {
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(gesture)

        if let coord = initialCoordinate {
            dropPin(at: coord)
            selectedCoordinate = coord // ✅ This allows "Select" to work without tapping again
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(selectTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(dismissSelf))
    }

    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        selectedCoordinate = coord

        mapView.removeAnnotations(mapView.annotations)

        dropPin(at: coord)
    }

    private func dropPin(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Selected Location"
        mapView.addAnnotation(annotation)
    }

    @objc private func selectTapped() {
        guard let coordinate = selectedCoordinate else {
            let alert = UIAlertController(title: "No location", message: "Tap a location on the map to select it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        onLocationSelected?(coordinate)
        dismiss(animated: true)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

