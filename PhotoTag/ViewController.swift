//
//  ViewController.swift
//  PhotoTag
//
//  Created by Seb Tota on 2/28/21.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    // Storyboard outlets
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    
    // Class variables
    var photos = [PHAsset]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGalleryPermission(callback: postPermissionCheck, failure: failedPermissionCheck)
        
    }
    
    /*
     * Callback function after gallery permissions have been sucessfully granted
     */
    private func postPermissionCheck() {
        print("Got the needed permissions")
        loadPhotos()
    }
    
    /*
     * Callback function after gallery permissions have NOT been granted
     */
    private func failedPermissionCheck() {
        print("Did not receive the appropriate permission to view gallery")
    }
    
    /*
     * Checks the user permission to make sure the application has access to the local photo gallery
     * @param   callback    Callback function to continue application execution post approval
     */
    private func getGalleryPermission(callback: @escaping () -> (), failure: @escaping () -> ()) {
        let photosCheck = PHPhotoLibrary.authorizationStatus()
        
        // Cheeck if app has access to users local photo gallerey
        if (photosCheck == .notDetermined) {
            // Request read and write permission for photo gallery
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (accessStatus) in
                if (accessStatus == .authorized) {
                    // Successfully granted access to photo gallery
                    callback()
                } else {
                    // User denied the application access to the photo gallery
                    failure()
                }
            }
        } else if (photosCheck == .authorized) {
            // User already authorized access to the gallery before
            callback()
        }
    }
    
    /*
     * Create a list referncing all the local photos the application has access to
     */
    private func loadPhotos() {
        
        // Create a background task
        DispatchQueue.global(qos: .utility).async {
        
            // Create fetch options to return photos in order of creation
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // Retrieve local photos (photos only, no video)
            let photoResults: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            // Append all images to photos array
            if (photoResults.count > 0) {
                for i in 0..<photoResults.count {
                    self.photos.append(photoResults[i])
                }
            } else {
                // Returing array is 0 indcating the application can not view any of the local photos
                print("No Photos were found")
            }
            
            // Callback after retrieveing images is complete
            DispatchQueue.main.async {
                print("Retrieved all local photos")
            }
        }
    }


}

