//  ViewController.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 05/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController , NSFetchedResultsControllerDelegate, MKMapViewDelegate,UIGestureRecognizerDelegate{
    //MARK:- Outlet
    @IBOutlet weak var mapView: MKMapView!
    //MARK:- Properties
    var pins:[Pin] = []
    var dataController:DataController!
    
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchRequest()

        creatMapGisture()
        self.mapView.delegate = self
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          setupFetchRequest()
    
      }
    //MARK: - UI
    func creatMapGisture(){
       let Gestur = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        Gestur.minimumPressDuration = 0.4
        Gestur.delegate = self
        mapView.addGestureRecognizer(Gestur)
    }

 
    //MARK: - Actions
    @objc func addPin(gestureReconizer: UILongPressGestureRecognizer){
     
         if gestureReconizer.state == UIGestureRecognizer.State.began {
                   let location = gestureReconizer.location(in: mapView)
                   let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
                   
                   let pin = Pin(context: dataController.viewContext)
                   pin.latitude = coordinate.latitude.magnitude
                   pin.longitude = coordinate.longitude.magnitude
                    //try to save the changes in data model
                   do {
                       try dataController.viewContext.save()
                   }catch{
                       print("error")
                   }
                   pins.append(pin)
                   
                   let annotation = MKPointAnnotation()
                   annotation.coordinate = coordinate
                   mapView.addAnnotation(annotation)
               }
    }
  //MARK:- Fetch result from data model

    
    func setupFetchRequest() {
           let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
               if let result = try? dataController.viewContext.fetch(fetchRequest){
                   pins = result
                   mapView.removeAnnotations(mapView.annotations)
                   setupAnnotations()
               }
     }
    //MARK: Pin functions
    func setupAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
  
    
       
    
}
//MARK:- extentions class of maview controller for the managing object and map
extension MapViewController {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           // Check that the object is an actual pin
           guard let pin = anObject as? Pin  else { return }
           
           switch type {
           case .insert:
               // Insert the pin into the map
               mapView.addAnnotation(pin)
           default:
               break
           }
       }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // when user click on pin do this code
        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotoVC") as? PhotoViewController
        photosViewController?.cordinate = view.annotation?.coordinate
        photosViewController?.dataController = dataController

        for pin in pins{
            if pin.latitude.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                photosViewController!.selectedPin = pin
        }
           
        }
         navigationController?.pushViewController(photosViewController!, animated: true)
    }
}
