//
//  ViewController.swift
//  PhotoTag
//
//  Created by Seb Tota on 2/28/21.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getGalleryPermission(callback: postPermissionCheck, failure: failedPermissionCheck)
        
    }
    
    private func postPermissionCheck() {
        print("Got the needed permissions")
    }
    
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


}

