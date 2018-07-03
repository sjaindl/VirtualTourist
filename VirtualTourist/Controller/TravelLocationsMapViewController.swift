//
//  TravelLocationsMapView.swift
//  VirtualTourist
//
//  Created by Stefan Jaindl on 15.06.18.
//  Copyright © 2018 Stefan Jaindl. All rights reserved.
//

import CoreData
import CoreLocation
import GoogleMaps
import UIKit

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet weak var map: GMSMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var deleteMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        initCamera()
        initResultsController()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(setDeleteMode))
    }
    
    @objc
    func setDeleteMode() {
        deleteMode = !deleteMode
        navigationItem.rightBarButtonItem?.title = deleteMode ? "Tap pin to delete" : "Delete"
    }
    
    func initResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.SORT_KEY, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: Constants.CoreData.CACHE_NAME_PINS)
    }
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            if let result = fetchedResultsController.fetchedObjects {
                for pin in result {
                    let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                    let marker = addPinToMap(with: coordinate)
                    store(pin, in: marker)
                }
            }
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ALBUM_SEGUE_ID {
            let controller = segue.destination as! AlbumViewController
            controller.pin = sender as! Pin
            controller.dataController = dataController
        }
    }
    
    func initCamera() {
        let zoom = UserDefaults.standard.float(forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
        let longitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
        let latitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom: zoom)
        
        map.camera = camera
    }
    
    func addPinToMap(with coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.map = map
        
        return marker
    }
    
    func persistPin(with coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? dataController.save()
        
        return pin
    }
    
    func store(_ pin: Pin, in marker: GMSMarker) {
        marker.userData = pin
    }
}

extension TravelLocationsMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        UserDefaults.standard.set(position.target.latitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        UserDefaults.standard.set(position.target.longitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
        UserDefaults.standard.set(position.zoom, forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let marker = addPinToMap(with: coordinate)
        let pin = persistPin(with: coordinate)
        store(pin, in: marker)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if deleteMode {
            if let pin = marker.userData as? Pin, let index = fetchedResultsController.indexPath(forObject: pin) {
                let object = fetchedResultsController.object(at: index)
                dataController.viewContext.delete(object)
                try? dataController.save()
            }
            
            marker.map = nil
        } else {
            performSegue(withIdentifier: Constants.ALBUM_SEGUE_ID, sender: marker.userData)
        }
        
        return true
    }
}
