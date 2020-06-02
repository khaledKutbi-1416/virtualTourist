//  PhotosViewController.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 07/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.



import UIKit
import MapKit
import CoreData


class PhotoViewController: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
  
    //MARK:- Propeeties
    var cordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var selectedPin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegation()
        setupFetchedResultsController()
        checkPhotoInlocation()
        getFlickerPhotos()
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
         fetchedResultsController.fetchedObjects?.forEach({ (photo) in
                   dataController.viewContext.delete(photo)

                   try? dataController.viewContext.save()
               })
              
                photoCollection.reloadData()
                
                getFlickerPhotos()
        
    }
    
    
    //MARK: - Handlers
    func checkPhotoInlocation(){
        if fetchedResultsController.fetchedObjects!.isEmpty{
                   showALertNextAction(title: "Messgae", message: "No sush photo in this location.")
               }
    }
     private func getFlickerPhotos() {
          // Decide if we need to retrieve photos from Flickr
        
        FlickerClient.getFlickerPhotoSearch(latitude: cordinate.longitude, longitude: cordinate.longitude) { (photos, error) in
                  if let photos = photos {
                      self.addPhotosInfoCoreData(photos: photos)
                      print("here is the : photos: \(photos)")
                      self.photoCollection.reloadData()
                  
                  } else {
                  }
              
          }
        
      }
    //Helper functions
    private func getData(from photo: Photo, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
          if let data = photo.imageData {
            DispatchQueue.main.async{
              completion(data, nil, nil)
            }
          } else {
              URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!, completionHandler: completion).resume()
          }
      }
    //Save photo to data model
    func addPhotosInfoCoreData(photos: [String]) {
        photos.forEach { (photoUrl) in
            let photo = Photo(context: dataController.viewContext)
            photo.imageURL = photoUrl
            photo.pin = selectedPin
            
            dataController.viewContext.insert(photo)
            
            try? dataController.viewContext.save()
        }
    }
    // Fetch the result form local data model
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
    //MARK - Show the pin that selected from previos view
    func addSelectedPinLocation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        mapView.addAnnotation(annotation)
               
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        let region = MKCoordinateRegion(center: cordinate, span: coordinateSpan)
        self.mapView.setRegion(region, animated: true)
    }
    //delgation for uikit
    func delegation(){
        self.mapView.delegate = self
        self.photoCollection.delegate = self
        self.photoCollection.dataSource = self
    }
  //alert message with action to notic user
      func showALertNextAction(title : String , message: String){
                 let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                 alert.view.tintColor = .blue
                 alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (action) in
                  self.navigationController?.popViewController(animated: true)
                 }))
                 self.present(alert, animated: true, completion: nil)
             
    }
    
}

//MARK: - Flicker image collections cell class
class photoCollectionCell:UICollectionViewCell{
    
    @IBOutlet weak var flickerImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
//MARK: PhotoViewContoller class Extension

// collectionView
extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource   {
   
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
    
}
//MapKit
extension PhotoViewController: MKMapViewDelegate{
    
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
// controller to manage fetchedRequest object by doing somw operation
extension PhotoViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollection.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollection.deleteItems(at: [indexPath!])
            break
        default:
            break
        }
    }
}
