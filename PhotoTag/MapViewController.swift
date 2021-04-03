//  MapViewController.swift
//  PhotoTag
//  Created by Alex St.Clair on 4/1/21.
import Foundation
import MapKit

class MapViewController: UIViewController{
    @IBOutlet var mapView: MKMapView!
    var user: User!
    
    //view loaded, pull all location data from photos in DB
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addPhotoAnnotations()
    }
    
    /** Adds Annotations to the map view for each photo that has a location */
    private func addPhotoAnnotations(){
        for id in user.photosMap {   //for each photo
            let tempPhoto = user.getPhoto(id: id)
            if tempPhoto?.location != nil {    //if the photo has a location
                let tempAnnotation = MKPointAnnotation()
                tempAnnotation.title = tempPhoto?.id
                tempAnnotation.coordinate =  (tempPhoto?.location!.coordinate)!
                mapView.addAnnotation(tempAnnotation)
            }
        }
    }
}
