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
    var photos: [Photo]         //local list of user's photos
    
    //initializer
    init(un: String){
        self.username = un
        schedules = [String]()
        photos = [Photo]()
    }
    
    /*
     * Add a new photo to the user object
     * @param   Photo   New photo to be added
     */
    public func addPhoto(photo: Photo){
        photos.append(photo)
    }
    
    //retrieves a photo from the user's list of photos
    public func getPhoto(id: String) -> Photo {
        var returnPhoto: Photo?
        for photo in photos{
            print("checking \(id) against \(photo.id)")
            if photo.id == id{
                returnPhoto = photo
            }
        }
        return returnPhoto!
    }
}
