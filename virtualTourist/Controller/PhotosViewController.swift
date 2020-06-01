//  PhotosViewController.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 07/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.



import UIKit
import MapKit
import CoreData


class PhotoViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource , MKMapViewDelegate{

    
    
    //MARK:- Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    //MARK:- Propeeties
    var cordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var selectedPin: Pin!
    var flickerImages: [Photo]!
    var fetchedRequest: NSFetchRequest<Photo>!
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegation()
        setupFetchRequest()
        getPhotos()
    }
    override func viewWillAppear(_ animated: Bool) {
        addSelectedPinLocation()
    }
    
    //MARK: - Actions
    @IBAction func newCollection(_ sender: Any) {
        
        
        selectedPin.photos = nil
               print(dataController.viewContext.hasChanges)
               try? self.dataController.viewContext.save()
               photoCollection.reloadData()
               flickerImages.removeAll()
               //TODO:
//               getPhotos()
        
    }
    
    
    
    //MARK: - Handlers
     func getPhotos() {
        // Decide if we need to retrieve photos from Flickr
            FlickerClient.getFlickerPhotoSearch(latitude: cordinate.latitude, longitude: cordinate.longitude) { (photos, error) in
                if let photos = photos {
                    print("here is the : photos: \(photos)")
                    self.addPhotosInfoCoreData(photos: photos)
                    
                    self.photoCollection.reloadData()
                } else {
                    // Show the user a proper error message
                }
        }
    }
    func addPhotosInfoCoreData(photos: [String]) {
        photos.forEach { (photoUrl) in
            let photo = Photo(context: dataController.viewContext)
            photo.imageURL = photoUrl
            photo.pin = selectedPin
            
            dataController.viewContext.insert(photo)
            
            try? dataController.viewContext.save()
        }
    }
    func setupFetchRequest() {
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
              fetchedRequest = Photo.fetchRequest()
            fetchedRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchedRequest){
            flickerImages = result
        }
    }
    func addSelectedPinLocation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        mapView.addAnnotation(annotation)
               
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        let region = MKCoordinateRegion(center: cordinate, span: coordinateSpan)
        self.mapView.setRegion(region, animated: true)
    }
    func delegation(){
        self.mapView.delegate = self
        self.photoCollection.delegate = self
        self.photoCollection.dataSource = self
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photoCollectionCell
        
//        cell?.flickerImage.image =
        return cell
    }
    
    
    
}


class photoCollectionCell:UICollectionViewCell{
    
    @IBOutlet weak var flickerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}


extension PhotoViewController{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
