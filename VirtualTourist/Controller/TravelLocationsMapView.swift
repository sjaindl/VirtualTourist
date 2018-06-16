//
//  TravelLocationsMapView.swift
//  VirtualTourist
//
//  Created by Stefan Jaindl on 15.06.18.
//  Copyright © 2018 Stefan Jaindl. All rights reserved.
//

import CoreLocation
import GoogleMaps
import UIKit

class TravelLocationsMapView: UIViewController {

    @IBOutlet weak var map: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        // Do any additional setup after loading the view.
        
        initCamera()
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

extension TravelLocationsMapView: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print(position.target)
        print(position.zoom)
        
        UserDefaults.standard.set(position.target.latitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        UserDefaults.standard.set(position.target.longitude, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
        UserDefaults.standard.set(position.zoom, forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
    }
}
