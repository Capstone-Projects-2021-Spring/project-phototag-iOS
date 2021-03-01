//
//  Photo.swift
//  PhotoTag
//
//  Created by Seb Tota on 3/1/21.
//

import Foundation
import UIKit
import Photos

class Photo {
    var id: String
    var location: CLLocation?
    var date: Date?
    var tags: [String] = []
    var photoAsset: PHAsset
    
    let galleyPreviewPhotoSize = CGSize(width:150, height: 150)
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.location = asset.location
        self.date = asset.creationDate
        self.photoAsset = asset
    }
    
    public func getPreviewImage() -> UIImage {
        // Facilitates retreving previews and the photo assets themselves
        let imageManager = PHImageManager.default()
        
        // Set the options for the retrieving individual photos
        let requestOptions = PHImageRequestOptions()
        
        // Retreive data synchronously since we are not in matn threead
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat // Request high quality asset
        
        var retImage: UIImage = UIImage()
        
        imageManager.requestImage(for: photoAsset, targetSize: galleyPreviewPhotoSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            retImage = image!
        })
        
        return retImage
    }
}
