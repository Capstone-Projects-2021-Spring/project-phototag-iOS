//
//  HomeScreenViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/4/21.
//
import UIKit

import Firebase
import GoogleSignIn

class HomeScreenViewController: UIViewController, GIDSignInDelegate {

    //login, signUp buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().presentingViewController = self
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }


    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    //Sign in functionality will be handled here
        if let error = error {
        print(error.localizedDescription)
        return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
        if let error = error {
        print(error.localizedDescription)
        } else {
        print("Login Successful.")
        //This is where you should add the functionality of successful login
        //i.e. dismissing this view or push the home view controller etc
        }
        }
        
    }

}
