//
//  SignUpViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/4/21.
//
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
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

        if(firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            return "Fill in all fields"
        }
        return nil
    }


    @IBAction func signUpClick(_ sender: Any) {

        let err = valid()

        //check if fields are filled
        if(err != nil){
            errorLabel.text = err!
            errorLabel.alpha = 1
        }
        //proceed with adding user to firebase
        else{
            print(1)

            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (res, error) in
                //error adding user to firebase
                if error != nil{
                    self.errorLabel.text = "Could not create user"
                    self.errorLabel.alpha = 1
                }
                //enter user data in firebase
                else{
                    print(2)
                    //let database = Firestore.firestore()
                    
                    let database = Database.database().reference()
                    //database.child("User").setValue(["uid": res!.user.uid])
                   // database.child("User").child(res!.user.uid).setValue(["user_first_name": self.firstNameTextField.text!])
                   // database.child("User").child(res!.user.uid).setValue(["user_last_name": self.lastNameTextField.text!])
                   // database.child("User").child(res!.user.uid).setValue(["user_email": self.emailTextField.text!])
                    

                    database.child("User/\(res!.user.uid)/user_first_name").setValue(self.firstNameTextField.text!)
                    database.child("User/\(res!.user.uid)/user_last_name").setValue(self.lastNameTextField.text!)
                    database.child("User/\(res!.user.uid)/user_email").setValue(self.emailTextField.text!)

                    /*database.collection("User").addDocument(data: ["user_first_name" : self.firstNameTextField.text!, "user_last_name" : self.lastNameTextField.text!, "user_email" : self.emailTextField.text!, "uid" : res!.user.uid]) { (error) in
                        if error != nil{
                            self.errorLabel.text = "Error entering user data in database"
                            self.errorLabel.alpha = 1
                        }
                    }*/
                }

            }
            self.goToGallery()
        }


    }


    func goToGallery(){
        let galleryView = storyboard?.instantiateViewController(identifier: "GalleryView") as! ViewController

        self.navigationController?.pushViewController(galleryView, animated: true)
        

    }

}