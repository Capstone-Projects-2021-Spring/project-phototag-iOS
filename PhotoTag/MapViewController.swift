//  MapViewController.swift
//  PhotoTag
//  Created by Alex St.Clair on 4/1/21.
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{

    var user: User?
    @IBOutlet var mapView: MKMapView!
    static var reuseIdentifier = "Annotation"
    static var MapToPhotoSegueIdentifier = "MapToPhotoSegueIdentifier"
    
    //view loaded, pull all location data from photos in DB
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MapViewController.reuseIdentifier)
        
        addPhotoAnnotations()
    }
    
    /** Adds Annotations to the map view for each photo that has a location */
    private func addPhotoAnnotations(){
        if user != nil {
            for id in user!.photosMap {   //for each photo
                let tempPhoto = user!.getPhoto(id: id)
                if tempPhoto!.location != nil {    //if the photo has a location
                    let tempAnnotation = MKPointAnnotation()
                    tempAnnotation.subtitle = tempPhoto!.id
                    tempAnnotation.coordinate =  tempPhoto!.location!.coordinate
                    mapView.addAnnotation(tempAnnotation)
                }
            }
        }else{
            print("User object passed to map VC was null")
        }
    }
    
    //This function is used to create a view along with each annotation
    //it is also used to add a button to each annotation that segues to the SinglePhotoView for that photo.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        //var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewController.reuseIdentifier)
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MapViewController.reuseIdentifier)
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButton.ButtonType.detailDisclosure)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let photoId = view.annotation?.subtitle, let user = user {
            if photoId != nil {
                
                let photo = user.getPhoto(id: photoId!)
                performSegue(withIdentifier: MapViewController.MapToPhotoSegueIdentifier, sender: photo)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MapViewController.MapToPhotoSegueIdentifier {
            if let viewController = segue.destination as? SinglePhotoViewController {
                viewController.photo = (sender as! Photo)
            }
        }
    }
}
