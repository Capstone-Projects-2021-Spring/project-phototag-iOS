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
    
    let defaults = UserDefaults.standard
    
    //initializer
    init(un: String){
        self.username = un
        schedules = [String]()
        photos = [Photo]()
        settings()
    }
    
    /*
     * Add a new photo to the user object
     * @param   Photo   New photo to be added
     */
    public func addPhoto(photo: Photo){
        photos.append(photo)
    }
    
    //set default setting values
    public func settings(){
        if(UserDefaults.standard.object(forKey: "Autotag") == nil){
            defaults.set(true, forKey: "Autotag")
            defaults.set(true, forKey: "Localtag")
        }
    }
}
