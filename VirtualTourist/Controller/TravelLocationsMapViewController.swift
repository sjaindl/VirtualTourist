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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        // Do any additional setup after loading the view.
        
        initCamera()
        initResultsController()
        fetchData()
    }
    
    func initResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
    }
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            if let result = fetchedResultsController.fetchedObjects {
                for pin in result {
                    let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                    addPinToMap(with: coordinate)
                }
            }
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initCamera() {
        let zoom = UserDefaults.standard.float(forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
        let longitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
        let latitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom: zoom)
        
        map.camera = camera
    }
}

extension TravelLocationsMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print(position.target)
        print(position.zoom)
        
        UserDefaults.standard.set(position.target.latitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        UserDefaults.standard.set(position.target.longitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
        UserDefaults.standard.set(position.zoom, forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        addPinToMap(with: coordinate)
        persistPin(with: coordinate)
    }
    
    func addPinToMap(with coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "Hello World"
        marker.map = map
    }
    
    func persistPin(with coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? dataController.save()
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
}
