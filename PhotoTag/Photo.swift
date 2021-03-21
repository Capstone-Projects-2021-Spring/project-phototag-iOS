//
//  Photo.swift
//  PhotoTag
//
//

import Foundation
import UIKit
import Photos
import Firebase
import CryptoKit

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
    var tagRef: DatabaseReference = Database.database().reference()
    
    let galleyPreviewPhotoSize = CGSize(width:100, height: 100)
    
    init(asset: PHAsset, callback: @escaping () -> ()) {
        self.id = asset.localIdentifier
        self.location = asset.location
        self.date = asset.creationDate
        self.photoAsset = asset
        
        autoreleasepool {
            self.id = hashImage(image: self.getImage()!)
        }
        
        let escapedId = self.id.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        ref = ref.child("iOS/sebastiantota/Photos/\(escapedId)")
        tagRef = tagRef.child("iOS/sebastiantota/photoTags")

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
            callback()
        })
    }
    
    private func hashImage(image: UIImage) -> String {
        let data: Data = image.pngData()!
        return SHA256.hash(data: data).description
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
    public func getPreviewImage() -> UIImage? {
        // Facilitates retreving previews and the photo assets themselves
        let imageManager = PHImageManager.default()
        
        // Set the options for the retrieving individual photos
        let requestOptions = PHImageRequestOptions()
        
        // Retreive data synchronously
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        var retImage:UIImage? = nil
        
        imageManager.requestImage(for: photoAsset, targetSize: galleyPreviewPhotoSize, contentMode: .default, options: requestOptions, resultHandler: { (image, error) in
            retImage = image
        })
        
        return retImage
    }
    
    /*
     * Create a full resolution image of the photo asset
     * @return  UIImage Full resolution image
     */
    public func getImage() -> UIImage? {
        // Facilitates retreving previews and the photo assets themselves
        let imageManager = PHImageManager.default()
        
        // Set the options for the retrieving individual photos
        let requestOptions = PHImageRequestOptions()
        
        // Retreive data synchronously
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        var retImage: UIImage? = nil
        
        imageManager.requestImage(for: photoAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (image, error) in
            retImage = image
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
     * addTag() helper function. This should not be used directly.
     */
    private func addTagHelper(tag: String) {
        tagRef.child(tag).getData(completion: { (error, snapshot) in
            if let error = error {
                print("Error getting tag. Error: \(error)")
            } else if snapshot.exists() {
                // Get current photo id's associated with this tag
                var photoIds: [String] = snapshot.value! as! [String]
                // Add current photos id
                if !photoIds.contains(self.id) {
                    photoIds.append(self.id)
                    // Update db to represent new change
                    self.fbSetTags(tag: tag, photoIds: photoIds)
                }
            } else {
                // Tag doesn't exist in db
                self.fbSetTags(tag: tag, photoIds: [self.id])
            }
        })
    }
    
    /*
     * Update the photoId array for a given tag in the firebase db
     * @param   String      Tag (key) to assign new array to
     * @param   [String]    The array of strings (value) to set for the given tag
     */
    private func fbSetTags(tag: String, photoIds: [String]) {
        tagRef.child(tag).setValue(photoIds)
    }
    
    /*
     * Adds an array of tags, making sure to only add new tags
     */
    //TODO: Fix this to actually ad multiple tags at once
    public func addTags(tags: [String]) {
        // Combine the current list of tags with the new tags, only keeping unique values
        //self.tags = Array(Set(tags + self.tags))
        //ref.child("photo_tags").setValue(self.tags)
        
        for tag in tags {
            self.addTag(tag: tag)
        }
    }
    
    /*
     * Add a single tag to the tag list, making sure the tag is a new tag
     * @return  Bool    Returns true if the added tag is a new and unique tag
     */
    public func addTag(tag : String) -> Bool {
        if !(self.tags.contains(tag) || tag.isEmpty) {
            let tag = tag.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            self.tags.append(tag)
            ref.child("photo_tags").setValue(self.tags)
            // tagRef.updateChildValues(["mountain": FieldValue.arrayUnion([self.id])])
            self.addTagHelper(tag: tag)
            return true
        }
        return false
    }
    
    /*
     * Remove a single tag from the photo object
     */
//    public func removeTag(tag: String) {
//        if (self.tags.contains(tag)) {
//
//        }
//    }
    
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
    
    /*
     * Return if photo has already been processed using autotag
     */
    public func checkTagged() -> Bool {
        return self.autoTagged
    }
    
    /*
     * Mark photo as having already been preocessed using autotag
     */
    public func markTagged() {
        self.autoTagged = true
        ref.child("auto_tagged").setValue(true)
    }
}
