//
//  CreatePostViewController.swift
//  instagram
//
//  Created by Müge Deniz on 14.11.2024.
//

import UIKit
import FirebaseStorage
import MapKit
import CoreLocation

protocol CreatePostDelegate {
    func refreshPage()
}

class CreatePostViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var postInfoTextView: UITextView!
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var locationMapView: MKMapView!
    
    var selectedImage: UIImage?
    var delegate: CreatePostDelegate?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var selectedPlaceName: String?
    var selectedPlacePhoto: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = selectedImage {
            postPhotoImageView.image = selectedImage
        } else {
            print("Görüntü alınamadı.")
        }
        setupLocationManager()
        addPinToMap()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Konum İzni Gerekli",
                                          message: "Lütfen konum hizmetlerini etkinleştirin.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            locationManager.startUpdatingLocation()
        }    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationManager.stopUpdatingLocation()
            print("Konum alındı: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
    
    func addPinToMap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
        locationMapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTapMap(_ sender: UITapGestureRecognizer) {
        
        locationMapView.removeAnnotations(locationMapView.annotations)
        
        let tapLocation = sender.location(in: locationMapView)
        let coordinates = locationMapView.convert(tapLocation, toCoordinateFrom: locationMapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Konum alınıyor..."
        locationMapView.addAnnotation(annotation)
        
        currentLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        let geocoder = CLGeocoder()
        let selectedLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geocoder.reverseGeocodeLocation(selectedLocation) { placemarks, error in
            if let error = error {
                print("Yer adı alınamadı: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first {
                let placeName = placemark.name ?? "Bilinmeyen Yer"
                annotation.title = placeName
                self.selectedPlaceName = placeName
                
                print("Yer Adı: \(placeName)")
                self.savePlaceNameAndPhoto(placeName: placeName, coordinates: coordinates)
            }
        }
    }
    
    
    func savePlaceNameAndPhoto(placeName: String, coordinates: CLLocationCoordinate2D) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = placeName
        searchRequest.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Yer fotoğrafı alınamadı: \(error.localizedDescription)")
                return
            }
            
            if let mapItem = response?.mapItems.first {
                let placePhoto = mapItem.url?.absoluteString ?? ""
                print("Place Name: \(placeName), Place Photo URL: \(placePhoto)")
                
                if placePhoto.isEmpty {
                    print("Fotoğraf URL'si boş!")
                }
                
                if let location = self.currentLocation {
                    let locationModel = LocationModel(latitude: location.coordinate.latitude,
                                                      longitude: location.coordinate.longitude)
                    let placeModel = PlaceModel(locationModel: locationModel,
                                                placeName: placeName,
                                                placePhoto: placePhoto)
                    
                    self.selectedPlacePhoto = placePhoto
                }
            }
        }
    }

    @IBAction func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonAction() {
        guard let data = postPhotoImageView.image?.jpegData(compressionQuality: 1) else { return }
        let postModel = PostModel(dictionary: [:])
        Helper.shared.showHud(text: "", view: view)
        
        FirebaseManager.shared.uploadUserPostPic(imageData: data) { url in
            var postPhotoArray = [String]()
            postPhotoArray.append(url ?? "")
            postModel.newPostPhotoInfo = self.postInfoTextView.text
            postModel.postPhoto = postPhotoArray
            postModel.postId = Helper.shared.generateRandomID(length: 23, isNumber: false)
            postModel.timestamp = "\(Date().timeIntervalSince1970)"
            postModel.likeArray = [String]()
            postModel.commentDict = []
            
            if let location = self.currentLocation,
               let placeName = self.selectedPlaceName,
               let placePhoto = self.selectedPlacePhoto {
                
                let locationModel = LocationModel(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude)
                
                let placeModel = PlaceModel(locationModel: locationModel,
                                            placeName: placeName,
                                            placePhoto: placePhoto)
                postModel.locationInfo = placeModel
            } else {
                print("Konum veya yer bilgisi eksik.")
            }
            
            FirebaseManager.shared.createPostPhoto(postModel: postModel) { success in
                Helper.shared.hideHud()
                if success {
                    self.delegate?.refreshPage()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Gönderi kaydedilemedi.")
                }
            }
        }
    }
    
}


