//
//  Photo.swift
//  PhotoTag
//
//

import Foundation
import UIKit
import Photos
import Firebase

/*
 * A representation of a photo and all of its associated metadata.
 */

class Photo {
    var id: String
    var location: CLLocation?
    var date: Date?
    var tags: [String] = []
    var photoAsset: PHAsset
    var autoTagged: Bool = false
    var ref: DatabaseReference = Database.database().reference()
    
    let galleyPreviewPhotoSize = CGSize(width:100, height: 100)
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.location = asset.location
        self.date = asset.creationDate
        self.photoAsset = asset
        
        ref = ref.child("testUsername/Photos/\(id)")
        ref.getData(completion: { (error, snapshot) in
            if let error = error {
                print("Error getting data for photo: \(self.id). Error: \(error)")
            } else if snapshot.exists() {
                // The photo object already exists in the DB
                self.syncFromFirebase(snapshot: snapshot)
            } else {
                // The photo object does not yet exist in the DB
                self.syncToFirebase()
            }
        })
    }
    
    /*
     * Syncs local photo object with the infromation in the Firebase Database
     */
    private func syncFromFirebase(snapshot: DataSnapshot) {
        // Sync tags from database
        if snapshot.hasChild("photo_tags") {
            let dbTags: [String] = snapshot.childSnapshot(forPath: "photo_tags").value! as! [String]
            self.addTags(tags: dbTags)
        }
        
        // Sync auto-tagged boolean
        if snapshot.hasChild("auto_tagged") {
            let dbTagged: Bool = snapshot.childSnapshot(forPath: "auto_tagged").value! as! Bool
            self.autoTagged = dbTagged
        }
    }
    
    /*
     * Pushes the entire object to Firebase to either override or create a new instance of said object in the Firebase Database
     */
    private func syncToFirebase() {
        var obj = ["auto_tagged": self.autoTagged,
                   "photo_tags": self.tags] as [String : Any]
        
        if self.location != nil {
            obj["location"] = ["latitude": self.location!.coordinate.latitude, "longitude": self.location!.coordinate.longitude]
        }
        
        if self.date != nil {
            obj["date"] = self.dateToString(date: self.date!)
        }
        
        self.ref.setValue(obj)
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
    public func getTags() -> [String] {
        return self.tags
    }
    
    /*
     * Adds an array of tags, making sure to only add new tags
     */
    public func addTags(tags: [String]) {
        // Combine the current list of tags with the new tags, only keeping unique values
        self.tags = Array(Set(tags + self.tags))
        ref.child("photo_tags").setValue(self.tags)
    }
    
    /*
     * Add a single tag to the tag list, making sure the tag is a new tag
     * @return  Bool    Returns true if the added tag is a new and unique tag
     */
    public func addTag(tag : String) -> Bool {
        if !(self.tags.contains(tag) || tag.isEmpty) {
            self.tags.append(tag)
            ref.child("photo_tags").setValue(self.tags)
            return true
        }
        return false
    }
    
    /*
     * Represent a Date object as a string, including complete date and time
     * @param   Date    Date object to be changed to a string
     * @return  String  Resulting String representation of the given Date object
     */
    private func dateToString(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        return dateFormater.string(from: date)
    }
}
