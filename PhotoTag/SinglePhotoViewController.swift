//
//  SinglePhotoViewController.swift
//  PhotoTag
//
//

import UIKit
import Firebase

class SinglePhotoViewController: UIViewController {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet var tagLabel: UILabel!    //a label to display the tags
    @IBOutlet var textField: UITextField!   //the text field used to manually tag
    @IBOutlet weak var suggestedLabel: UILabel!
    
    let testUser = User(un: "testUsername")
    var photo: Photo!
    var ref: DatabaseReference = Database.database().reference() //create a DB reference
    var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()
        
        //here we need to check the DB to see if the photo has any tags
        //attach a listener to the tag list of the specific photo
        databaseHandle = ref
            .child("\(testUser.username)")
            .child("Photos")
            .child("\(photo.id)")
            .child("photo_tags")
            .observe(.value, with: { (snapshot) in
            
            //when a change has been found to the tags, update the label
            let tags = snapshot.value as? [String]  //gets the tags as a string array
            if let nonNullTags = tags{
                self.tagLabel.text = nonNullTags.joined(separator: " , ")   //updates the label with the tags
                
                //also ensure the local copy is updated
                if !self.photo.setTags(tags: tags ?? [String]()){
                    print("failed to update local Photo class tag list.")
                }
            }
        })
        
        // listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    //removes the listeners for keyboard events after theyre needed
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /*
     * Populate the UIImageView with the full size photo
     */
    private func loadPhoto() {
        let image = photo.getImage()
        imageDisplay.image = image
        let labeler = MLKitProcess()
        labeler.labelImage(image: image) { [self] (tags: [String]) -> () in
            for tag in tags {
                suggestedLabel.text! += "\(tag), "
            }
        }
    }
    
    //called when the keyboard animation changes
    @objc func keyboardWillChange(notification: Notification){
        //print("Keyboard will show: \(notification.name.rawValue)")
        
        //get the size of the keyboard for moving the screen
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification{
        
            view.frame.origin.y = -keyboardRect.height
        }else{
            view.frame.origin.y = 0
        }
    }
    
    
    //when the user clicks on the text box, bring up the keyboard
    @IBAction func onTextFieldTouched(_ sender: UITextField) {
        self.textField.becomeFirstResponder()
    }
    
    //called when the text field has been used to create a tag
    @IBAction func ReturnButtonTriggered(_ sender: UITextField) {
        let tagString = (sender.text ?? "") as String
        
        if !tagString.isEmpty{
            print(tagString)
            
            //add the tag locally
            if !photo.addTag(tag: tagString){
                print("failed to add tag locally")
            }
            
            //add this tag to the local user's tagged photo collection
            testUser.addPhoto(photo: photo)
            
            //write entire photo object to firebase db
            self.ref
                .child("\(testUser.username)")
                .child("Photos")
                .child("\(photo.id)")
                .child("photo_tags")
                .setValue(photo.getTags())
            
            //contribute this tag to the firebase list
            
            //self.ref.child("Photo/\(photo.id)/photo_tags").setValue(photo.getTags())
        }else{
            print("Tag string empty")
        }
        
        //clear the text in the textfield
        if self.textField.text != ""{
            self.textField.text = ""
        }
        
        self.textField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
