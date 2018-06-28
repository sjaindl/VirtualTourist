//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Stefan Jaindl on 17.06.18.
//  Copyright © 2018 Stefan Jaindl. All rights reserved.
//

import CoreData
import GoogleMaps
import UIKit

class AlbumViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    public var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initCamera()
        initResultsController()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFlowLayout()
    }
    
    func setupFlowLayout() {
        let width = view.frame.size.width
        let height = view.frame.size.height
        let min = width > height ? height : width
        let max = width > height ? width : height
        
        let space:CGFloat = 3
        let isPortraitMode = UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown
        let dimension = isPortraitMode ? (min - (2 * space)) / 2 : (max - (2 * space)) / 3
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func initResultsController() {
        
        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            if let result = fetchedResultsController.fetchedObjects {
                if result.count == 0 {
                    fetchDataFromFlickr()
                }
                else {
                    for photo in result {
                        let imageUrl = photo.imageUrl
                        let title = photo.title
                        //TODO
                        
                        images.append(imageUrl!) //todo: replace
                        
                        
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func fetchDataFromFlickr() {
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        DispatchQueue.global().async {
            FlickrClient.sharedInstance.fetchPhotos(latitude, longitude: longitude) { (error, isEmpty, photos) in
                if let error = error {
                    //todo: error message
                } else {
                    guard let photos = photos else {
                        //todo: alert
                        return
                    }
                    
                    DispatchQueue.main.async {
                        for photo in photos {
                            self.persistPhoto(photo: photo)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func initCamera() {
        let zoom = UserDefaults.standard.float(forKey: Constants.UserDefaults.USER_DEFAULT_ZOOM_LEVEL)
        let camera = GMSCameraPosition.camera(withLatitude: pin.latitude,
                                              longitude: pin.longitude,
                                              zoom: zoom)
        
        map.camera = camera
    }
    
    
    func persistPhoto(photo: [String: AnyObject]) -> Photos? {
        if let title = photo[FlickrConstants.FlickrResponseKeys.Title] as? String,
            /* Does the photo have a key for 'url_m'? */
            let imageUrlString = photo[FlickrConstants.FlickrResponseKeys.MediumURL] as? String {
            
            let photo = Photos(context: dataController.viewContext)
            
            photo.pin = self.pin
            photo.title = title
            photo.imageUrl = imageUrlString
            
            images.append(imageUrlString) // todo replace
            
            try? dataController.save()
            
            return photo
        }
        
        return nil
    }
//}
//
//extension TravelLocationsMapViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return FlickrClient.sharedInstance.flickrPhotos.count
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ALBUM_CELL_REUSE_ID, for: indexPath) as! AlbumCollectionViewCell
        
        let imageURL = URL(string: images[indexPath.row])
        if let imageData = try? Data(contentsOf: imageURL!) {
            DispatchQueue.main.async {
                cell.locationImage.image = UIImage(data: imageData)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        performSegue(withIdentifier: MemeIds.MEME_DETAIL_SEGUE_ID, sender: indexPath.row)
    }
}
