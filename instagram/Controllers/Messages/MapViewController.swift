//
//  MapViewController.swift
//  instagram
//
//  Created by Müge Deniz on 21.12.2024.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var region: MKCoordinateRegion?
    var placeName: String?
    var location: CLLocation?
    private var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let region = region {
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = region.center
            annotation.title = placeName ?? "Bilinmeyen Yer"
            mapView.addAnnotation(annotation)
        }
    }

}


