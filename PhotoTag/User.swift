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
    
    public func addPhoto(photo: Photo){
        photos.append(photo)
    }
}