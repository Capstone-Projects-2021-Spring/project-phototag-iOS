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
    
    //TODO: Change this when Ryan's login code modifies a user object
    let testUser = User(un: "testUsername")
    var photo: Photo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()
        self.tagLabel.text = photo.getTags().joined(separator: ", ")
        
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
     * Populate the UIImageView with the full size photo asynchonously
     */
    private func loadPhoto() {
        DispatchQueue.global(qos: .utility).async {
            let image: UIImage = self.photo.getImage()!
            
            DispatchQueue.main.async {
                self.imageDisplay.image = image
                let labeler = MLKitProcess()
                labeler.labelImage(image: image) { [self] (tags: [String]) -> () in
                    suggestedLabel.text! = tags.joined(separator: ", ")
                }
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
            if !photo.addTag(tag: tagString){
                print("failed to save")
            }
        }else{
            print("Tag string empty")
        }
        
        // Update tag label
        self.tagLabel.text = photo.getTags().joined(separator: ", ")
        
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
