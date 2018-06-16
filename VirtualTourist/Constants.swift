//
//  Constants.swift
//  VirtualTourist
//
//  Created by Stefan Jaindl on 15.06.18.
//  Copyright © 2018 Stefan Jaindl. All rights reserved.
//

import Foundation

struct Constants {
    static let GOOGLE_MAPS_API_KEY = "AIzaSyBHKiv3bi0757Tw2yKVY6fm3F5oNDXqzKc"
    
    struct UserDefaults {
        static let USER_DEFAULT_LAUNCHED_BEFORE = "hasLaunchedBefore"
        static let USER_DEFAULT_MAP_LATITUDE = "mapLatitude"
        static let USER_DEFAULT_MAP_LONGITUDE = "mapLongitude"
        static let USER_DEFAULT_ZOOM_LEVEL = "zoomLevel"
        
        static let STANDARD_ZOOM_LEVEL = 6.0
        static let STANDARD_LATITUDE = 47.0
        static let STANDARD_LONGITUDE = 15.5
    }
}
