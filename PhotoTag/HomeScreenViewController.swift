//
//  HomeScreenViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/4/21.
//
import UIKit

import Firebase
import GoogleSignIn

import FirebaseAuth


class HomeScreenViewController: UIViewController, GIDSignInDelegate {


    //login, signUp buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet var logo: UIImageView!
    
    //google sign in button
    @IBOutlet var gIDSignInButton: GIDSignInButton!
    
    var g_username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        //GIDSignIn.sharedInstance()?.signOut()
        
        if(GIDSignIn.sharedInstance().hasPreviousSignIn()) {
            print("Already signed in")
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        } else {
            print("Not yet signed in")
        }
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //handle google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if (error == nil) {
        // successful sign in
            //get Google id & access tokens
           // g_username = Auth.auth().currentUser!.email!
            
            guard let authentication = user.authentication else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            //authenticate with firebase
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                }
                // User is signed in
                self.g_username = Auth.auth().currentUser!.email! //Auth.auth().currentUser!.uid
                self.goToGallery()
            }
        } else {
          print("\(error.localizedDescription)")
        }
    }
    
    //handle open url request
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    
    func goToGallery(){
       //performSegue
        let galleryView = storyboard?.instantiateViewController(withIdentifier: "GalleryView") as! ViewController
        galleryView.username = g_username
        //galleryView.user.username = g_username
        self.navigationController?.pushViewController(galleryView, animated: true)
    }
}
