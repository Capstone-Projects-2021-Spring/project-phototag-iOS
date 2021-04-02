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
    let tagCollectionView = TTGTextTagCollectionView()
    
    var tags: [String] = []
    var selectedTagIndex = 0
    
    //TODO: Change this when Ryan's login code modifies a user object
    let testUser = User(un: "testUsername")
    var photo: Photo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(photo.id)
        loadPhoto()

        addTagsToView(tagList: photo.getTags(), selected: true)
        
        setupTagUI()
        
        // listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    private func setupTagUI() {
        tagCollectionView.alignment = .center
        tagCollectionView.delegate = self
        tagCollectionView.frame = CGRect(x: 0, y: view.frame.size.height - 200, width: view.frame.size.width, height: 200)
        view.addSubview(tagCollectionView)
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        print("Tag: \(tagText) : Selected: \(selected)")
    }
    
    /*
     * Add a list of tags to the tag view. Tag them as selected or not
     * @param   [String]    List of tags to add
     * @param   Bool        True - Tags should be marked as selected, False otherwise
     */
    private func addTagsToView(tagList: [String], selected: Bool) {
        for tag in tagList {
            
            if tags.contains(tag) {
                // Tag already exists, so only update the tag to marked if the selected bool is true
                if selected == true && tags.firstIndex(of: tag) != nil && tags.firstIndex(of: tag)! > selectedTagIndex {
                    let curIndex = tags.firstIndex(of: tag)!
                    print("Current index: \(curIndex), SelectedTagIndex: \(selectedTagIndex)")
                    
                    // Remove tag from current index
                    tags.remove(at: curIndex)
                    tagCollectionView.removeTag(at: UInt(curIndex))
                    
                    // Insert at new index
                    tags.insert(tag, at: selectedTagIndex)
                    tagCollectionView.insertTag(tag, at: UInt(selectedTagIndex))
                    
                    // Mark tag as selected
                    tagCollectionView.setTagAt(UInt(selectedTagIndex), selected: true)
                    
                    selectedTagIndex += 1
                }
            } else {
                // Tag doesn't yet exist. Add it as a marked tag or an unmarked tag
                if selected == true {
                    // Add new tag to the end of the selected tags and mark as selected
                    tags.insert(tag, at: selectedTagIndex)
                    tagCollectionView.insertTag(tag, at: UInt(selectedTagIndex))
                    tagCollectionView.setTagAt(UInt(selectedTagIndex), selected: true)
                    selectedTagIndex += 1
                } else {
                    // Add new tag to the end of the list and do NOT mark as selected
                    tags.append(tag)
                    tagCollectionView.addTag(tag)
                }
            }
            
        }
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
                    self.addTagsToView(tagList: tags, selected: false)
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
