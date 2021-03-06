//
//  Photo.swift
//  PhotoTag
//
//  Created by Seb Tota on 3/1/21.
//

import Foundation
import UIKit
import Photos

/*
 * A representation of a photo and all of its associated metadata.
 */

class Photo {
    var id: String
    var location: CLLocation?
    var date: Date?
    var tags: [String] = []
    var photoAsset: PHAsset
    
    let galleyPreviewPhotoSize = CGSize(width:100, height: 100)
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.location = asset.location
        self.date = asset.creationDate
        self.photoAsset = asset
    }
    
    /*
     * Create a lower resolution preview image of the photo asset
     * @return  UIImage Low resolution preview image
     */
    public func getPreviewImage() -> UIImage {
        // Facilitates retreving previews and the photo assets themselves
        let imageManager = PHImageManager.default()
        
        // Set the options for the retrieving individual photos
        let requestOptions = PHImageRequestOptions()
        
        // Retreive data synchronously
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        var retImage: UIImage = UIImage()
        
        imageManager.requestImage(for: photoAsset, targetSize: galleyPreviewPhotoSize, contentMode: .default, options: requestOptions, resultHandler: { (image, error) in
            retImage = image!
        })
        
        return retImage
    }
    
    /*
     * Create a full resolution image of the photo asset
     * @return  UIImage Full resolution image
     */
    public func getImage() -> UIImage {
        // Facilitates retreving previews and the photo assets themselves
        let imageManager = PHImageManager.default()
        
        // Set the options for the retrieving individual photos
        let requestOptions = PHImageRequestOptions()
        
        // Retreive data synchronously
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        var retImage: UIImage = UIImage()
        
        imageManager.requestImage(for: photoAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (image, error) in
            retImage = image!
        })
        
        return retImage
    }
    
    /*
     * Getter for the tag list
     * @return  the string array of tags
     */
    public func getTags() -> [String]{
        return self.tags
    }
    
    /*
     * Setter for the tag list
     * @return  true on success, false if the taglist given was empty
     */
    public func setTags(tags: [String]) -> Bool{
        if tags.isEmpty{
            return false
        }else{
            self.tags = tags
            return true
        }
    }
    
    /*
     * Adds a tag to the list of tags for this photo
     * @return  true on success, false on used/empty string
     */
    public func addTag(tag : String) -> Bool{
        if self.tags.contains(tag) || tag.isEmpty{
            return false
        }else{
            self.tags.append(tag)
            return true
        }
    }
}
