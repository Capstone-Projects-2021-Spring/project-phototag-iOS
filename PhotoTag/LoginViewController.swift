//
//  LoginViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/4/21.
//
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.alpha = 0

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func valid() -> String? {
        
        if(emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            return "Fill in all fields"
        }
        return nil
    }
    
    @IBAction func loginClick(_ sender: Any) {
        
        let err = valid()
        
        //check if fields are filled
        if(err != nil){
            errorLabel.text = err!
            errorLabel.alpha = 1
        }
        else{
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (res, error) in
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }else{
                    self.goToGallery()
                }
            }
            
        
        }
        
        
    }
    
    func goToGallery(){
        
       //performSegue(
        
        let galleryView = storyboard?.instantiateViewController(withIdentifier: "GalleryView") as! ViewController
        self.navigationController?.pushViewController(galleryView, animated: true)
        
    }
    
}
