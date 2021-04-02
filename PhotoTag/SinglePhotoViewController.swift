//
//  SinglePhotoViewController.swift
//  PhotoTag
//
//

import UIKit
import Firebase
import TTGTagCollectionView

class SinglePhotoViewController: UIViewController, TTGTextTagCollectionViewDelegate {

    @IBOutlet weak var imageDisplay: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    let existingTagsCollectionView = TTGTextTagCollectionView()
    let suggestedTagsCollectionView = TTGTextTagCollectionView()
    
    //TODO: Change this when Ryan's login code modifies a user object
    let testUser = User(un: "testUsername")
    var photo: Photo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()

        existingTagsCollectionView.addTags(photo.getTags())
        // self.tagLabel.text = photo.getTags().joined(separator: ", ")
        
        setupTagUI()
        
        // listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    private func setupTagUI() {
        existingTagsCollectionView.alignment = .center
        existingTagsCollectionView.delegate = self
        existingTagsCollectionView.frame = CGRect(x: 0, y: view.frame.size.height - 250, width: view.frame.size.width, height: 200)
        view.addSubview(existingTagsCollectionView)
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        print("Tag: \(tagText) : Selected: \(selected)")
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
                labeler.labelImage(image: image) { (tags: [String]) -> () in
                    print(tags)
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
            
            
            
//            if !photo.addTag(tag: tagString){
//                print("failed to save")
//            }
            // suggestedTagsCollectionView.addNewTag(named: tagString)
        }else{
            print("Tag string empty")
        }
        
//        // Update tag label
//        self.tagLabel.text = photo.getTags().joined(separator: ", ")
//
//        //clear the text in the textfield
//        if self.textField.text != ""{
//            self.textField.text = ""
//        }
        
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
