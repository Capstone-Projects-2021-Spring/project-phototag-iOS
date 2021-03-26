//  User.swift
//  PhotoTag
//
//  The purpose of this class is to represent a user object locally
//
//  Created by Alex St.Clair on 3/4/21.

import Foundation

class User{
    
    var username: String        //the unique id of the user stored in firebase
    var schedules: [String]     //list of user's schedules
    var photos: [String: Photo] = [:]
    var photosMap: [String] = []
    
    let defaults = UserDefaults.standard
    
    //initializer
    init(un: String){
        self.username = un
        schedules = [String]()
        settings()
    }
    
    /*
     * Add a new photo to the user object
     * @param   Photo   New photo to be added
     */
    public func addPhoto(photo: Photo){
        photosMap.append(photo.id)
        photos[photo.id] = photo
    }
    
    /*
     * Add a new photo to the user object at a specific index in the array
     * @param   Photo   New photo to be added
     * @param   Int     Index at which the photo should be inserted
     */
    public func addPhoto(photo: Photo, index: Int) {
        photosMap.insert(photo.id, at: index)
        photos[photo.id] = photo
    }
    
    public func getPhoto(index: Int) -> Photo {
        return photos[photosMap[index]]!
    }
    
    //retrieves a photo from the user's list of photos
    public func getPhoto(id: String) -> Photo? {
        return photos[id]
    }
    
    //set default setting values
    public func settings(){
        if(UserDefaults.standard.object(forKey: "Autotag") == nil){
            defaults.set(true, forKey: "Autotag")
        }
        defaults.set(true, forKey: "Localtag")
    }
}
