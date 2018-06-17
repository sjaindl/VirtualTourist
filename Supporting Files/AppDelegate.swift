//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Stefan Jaindl on 15.06.18.
//  Copyright © 2018 Stefan Jaindl. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController: DataController = DataController(modelName: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(Constants.GOOGLE_MAPS_API_KEY)
        checkIfFirstLaunch()
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsListViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationsListViewController.dataController = dataController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        save()
    }
    
    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.USER_DEFAULT_LAUNCHED_BEFORE) {
            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.USER_DEFAULT_LAUNCHED_BEFORE)
            UserDefaults.standard.set(Constants.UserDefaults.STANDARD_ZOOM_LEVEL, forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
            UserDefaults.standard.set(Constants.UserDefaults.STANDARD_LONGITUDE, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LONGITUDE)
            UserDefaults.standard.set(Constants.UserDefaults.STANDARD_LATITUDE, forKey: Constants.UserDefaults.USER_DEFAULT_MAP_LATITUDE)
        }
    }
    
    func save() {
        try? dataController.save()
    }
}
