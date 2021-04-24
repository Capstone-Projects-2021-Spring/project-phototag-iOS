//  User.swift
//  PhotoTag
//
//  The purpose of this class is to represent a user object locally
//
//  Created by Alex St.Clair on 3/4/21.

import Foundation
import Firebase

class User{
    
    var username: String        //the unique id of the user stored in firebase
    var schedules: [String]     //list of user's schedules
    var photos: [String: Photo] = [:]
    var photosMap: [String] = []
    var photoCount = 0
    
    let defaults = UserDefaults.standard
    
    //initializer
    init(un: String){
        self.username = Photo.firebaseEncodeString(str: un)
        print(self.username)
        schedules = [String]()
        settings()
    }
    
    public func getPhotoCount() -> Int {
        return photoCount
    }
    
    /*
     * Add a new photo to the user object
     * @param   Photo   New photo to be added
     */
    public func addPhoto(photo: Photo){
        photosMap.append(photo.id)
        photos[photo.id] = photo
        photoCount += 1
    }
    
    /*
     * Add a new photo to the user object at a specific index in the array
     * @param   Photo   New photo to be added
     * @param   Int     Index at which the photo should be inserted
     */
    public func addPhoto(photo: Photo, index: Int) {
        photosMap.insert(photo.id, at: index)
        photos[photo.id] = photo
        photoCount += 1
    }
    
    public func getPhoto(index: Int) -> Photo {
        return photos[photosMap[index]]!
    }
    
    //retrieves a photo from the user's list of photos
    public func getPhoto(id: String) -> Photo? {
        return photos[id]
    }
    
    //set default setting values
    //if no settings exist, then default auto tag to true, server tag to false
    public func settings(){
        if(UserDefaults.standard.object(forKey: "Autotag") == nil){
            defaults.set(true, forKey: "Autotag")
        }
        if(UserDefaults.standard.object(forKey: "Servertag") == nil){
            defaults.set(false, forKey: "Servertag")
        }
    }
    
    /*
     * Get all of the tags associated with any photo this user has access to
     * @param   Callback    Callback function passing resulting tags as a parameter
     */
    public func getAllTags(callback: @escaping ([String]) -> ()) {
        let ref: DatabaseReference = Database.database().reference().child("iOS/\(username)/photoTags")
        ref.getData { (error, dataSnapshot) in
            var tags: [String] = []
            if let error = error {
                print("Error getting all tags belonging to this user. Error: \(error)")
            } else if dataSnapshot.exists() {
                for child in dataSnapshot.children {
                    let childTag = child as! DataSnapshot
                    let tag = childTag.key
                    tags.append(tag)
                }
            } else {
                print("No tags exist for this user")
            }
            
            callback(tags)
        }

    }
}
