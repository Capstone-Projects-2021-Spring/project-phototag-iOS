//
//  SinglePhotoViewController.swift
//  PhotoTag
//
//  Created by Seb Tota on 3/1/21.
//

import UIKit

class SinglePhotoViewController: UIViewController {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet var tagLabel: UILabel!    //a label to display the tags
    @IBOutlet var textField: UITextField!   //the text field used to manually tag
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()
        // Do any additional setup after loading the view.
    }
    
    /*
     * Populate the UIImageView with the full size photo
     */
    private func loadPhoto() {
        imageDisplay.image = photo.getImage()
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
