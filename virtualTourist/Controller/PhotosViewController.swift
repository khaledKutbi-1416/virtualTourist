//  PhotosViewController.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 07/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.



import UIKit
import MapKit
import CoreData


class PhotoViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource , MKMapViewDelegate,NSFetchedResultsControllerDelegate{

    
    
    //MARK:- Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    //MARK:- Propeeties
    var cordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var selectedPin: Pin!
    var flickerImages = ["hi","hi"]
//    [Photo]!
//    var fetchedRequest: NSFetchRequest<Photo>!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegation()
//        setupFetchRequest()
        getFlickerPhotos()
        setupFetchedResultsController()
        configurCollectionFlowLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        addSelectedPinLocation()
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          
          fetchedResultsController = nil
      }
    
    //MARK: - Actions
    @IBAction func newCollection(_ sender: Any) {
        
        
        selectedPin.photos = nil
               print(dataController.viewContext.hasChanges)
               try? self.dataController.viewContext.save()
               photoCollection.reloadData()
               flickerImages.removeAll()
               //TODO:
               getFlickerPhotos()
        
    }
    
    
    //MARK: - Handlers
     private func getFlickerPhotos() {
          // Decide if we need to retrieve photos from Flickr
        
        FlickerClient.getFlickerPhotoSearch(latitude: cordinate.longitude, longitude: cordinate.longitude) { (photos, error) in
                  if let photos = photos {
                      self.addPhotosInfoCoreData(photos: photos)
                      print("here is the : photos: \(photos)")
                      self.photoCollection.reloadData()
                  } else {
                    self.showALert(title: "Message", message: "No image exist in this location.")
                  }
              
          }
        
      }
    private func getData(from photo: Photo, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
          if let data = photo.imageData {
              completion(data, nil, nil)
          } else {
              URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!, completionHandler: completion).resume()
          }
      }
    //save photo to core data
    func addPhotosInfoCoreData(photos: [String]) {
        photos.forEach { (photoUrl) in
            let photo = Photo(context: dataController.viewContext)
            photo.imageURL = photoUrl
            photo.pin = selectedPin
            
            dataController.viewContext.insert(photo)
            
            try? dataController.viewContext.save()
        }
    }
//    func setupFetchRequest() {
//        let predicate = NSPredicate(format: "pin == %@", selectedPin)
//              fetchedRequest = Photo.fetchRequest()
//            fetchedRequest.predicate = predicate
//        if let result = try? dataController.viewContext.fetch(fetchedRequest){
//            flickerImages = result
//        }
//    }
    func setupFetchedResultsController() {
          
          let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
          let predicate = NSPredicate(format: "pin == %@", selectedPin)
          fetchRequest.predicate = predicate
          fetchRequest.sortDescriptors = []
          
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
          fetchedResultsController.delegate = self
          do{
              try fetchedResultsController.performFetch()
          }catch{
              fatalError("The fetch could not be performed: \(error.localizedDescription)")
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
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photoCollectionCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        getData(from: photo) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                cell.flickerImage.image = UIImage(data: data)
                }
            }
            
            
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        photoCollection.reloadData()
    }
    
    func configurCollectionFlowLayout(){
           let space:CGFloat = 3.0
           let dimension = (view.frame.size.width - (2 * space)) / 3.0

           flowLayout.minimumInteritemSpacing = space
           flowLayout.minimumLineSpacing = space
           flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
