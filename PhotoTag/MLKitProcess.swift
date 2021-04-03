//
//  MLKitProcess.swift
//  PhotoTag
//
//  Created by Seb Tota on 3/3/21.
//

import Foundation
import Photos
import MLKit
import Alamofire

/*
 * Process an image, or collection of images, using Google ML Kit API.
 */

class MLKitProcess {
    let confidenceScore = NSNumber(floatLiteral: 0.7)
    
    /*
     * Labels a collection of Photo objects and adds any newly found tags to the photo object
     * @param   [String: Photo] User photo dictionary object
     * @param   () -> ()        Callback upon finishing labeling all photos
     */
    func labelAllPhotos(photos: [String: Photo]?, callback: @escaping ()->()) {
        guard let photos = photos else { return }
        
        // Create a background task
        DispatchQueue.global(qos: .background).async {
            var options: CommonImageLabelerOptions!
            options = ImageLabelerOptions()
            
            // Define threashold confidence for returning labels
            options.confidenceThreshold = self.confidenceScore

            // Init on device labeler
            let onDeviceLabeler = ImageLabeler.imageLabeler(options: options)
            
            var i = 0
            
            for (_, photo) in photos {
                
                // Skip already tagged photos
                if photo.checkTagged() == true {
                    continue
                }
                
                autoreleasepool  {
                    let tempImage: UIImage? = photo.getImage()
                    
                    var image: UIImage = UIImage()
                    
                    if tempImage != nil {
                        image = photo.getImage()!
                        
                        let visionImage: VisionImage = VisionImage(image: image)
                        visionImage.orientation = image.imageOrientation
                        
                        var objects: [ImageLabel]
                        do {
                          objects = try onDeviceLabeler.results(in: visionImage)
                        } catch let error {
                          print("Failed to detect object with error: \(error.localizedDescription).")
                          return
                        }
                        // Iterate over all the found tags and the associated metadata
                        
                        var foundTags: [String] = []
                        
                        for obj in objects {
                            // Only add new tags to the photo object
                            foundTags.append(obj.text)
                        }
                        
                        photo.addTags(tags: foundTags)
                        photo.markTagged()
                        
                        print("processed photo \(i)")
                        
                    }
                    
                    i += 1
                }
            }
            
            // Run after all the photos have been proceessed leaving the async function
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    /*
     * Process image through ML Kit to find associated labels
     * @para    callback([String]) Callback function to call once the image has been labeled, passing an array of the assoicated tags
     */
    func labelImage(image: UIImage?, callback: @escaping ([String])->()) {
        guard let image = image else { return }
        
        var options: CommonImageLabelerOptions!
        options = ImageLabelerOptions()
        
        // Define threashold confidence for returning labels
        options.confidenceThreshold = self.confidenceScore

        // Init on device labeler
        let onDeviceLabeler = ImageLabeler.imageLabeler(options: options)
        
        // Initialize a VisionImage object with the given UIImage.
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        // Array of resulting labels associated with the image
        var labels: [String] = []
        
        // Process image using on device ML Kit image labeler
        onDeviceLabeler.process(visionImage) { mlLables, error in
            
            // Iterate through all the labels, only keeping the label text and dropping the confidence score and other
            // unnecessary data
            for i in mlLables! {
                labels.append(i.text.lowercased())
            }
            
            callback(labels)
        }
    }
    
    func labelImageServer(photo: Photo){
        let photoMedia = photo.getImage()?.jpegData(compressionQuality: 1.0)!
            
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
            ]
        
//        let params: [String: String] = ["email": "sebastiantota",
//                                        "password": "admin123",
//                                        "platform": "iOS",
//                                        "photo_identifier": photo.id]
            
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        photoMedia!,
                        withName: "image",
                        fileName: "image",
                        mimeType: "image/jpeg"
                    )
                    multipartFormData.append(Data("sebastiantota".utf8), withName: "email")
                    multipartFormData.append(Data("admin123".utf8), withName: "password")
                    multipartFormData.append(Data("iOS".utf8), withName: "platform")
                    multipartFormData.append(Data(photo.id.utf8), withName: "photo_identifier")
//                    for param in params {
//                        let value = param.value.data(using: String.Encoding.utf8)!
//                        multipartFormData.append(value, withName: param.key)
//                    }
                },
                to: "https://api.sebtota.com:5000/uploadImage",
                method: .post ,
                headers: headers
            )
            .response { response in
                print(response)
                
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Response: \(json!)")
                }

            }
        }
}
