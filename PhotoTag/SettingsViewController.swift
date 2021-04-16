//
//  SettingsViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/12/21.
//

import UIKit
import GoogleSignIn

class SettingsViewController: UIViewController, GIDSignInDelegate{

    
    
    @IBOutlet weak var automaticTaggingLabel: UILabel!
    @IBOutlet weak var serverTaggingLabel: UILabel!
    
    @IBOutlet weak var automaticTaggingSwitch: UISwitch!
    @IBOutlet weak var serverTaggingSwitch: UISwitch!
    
    @IBOutlet weak var signoutButton: UIButton!
    
    
    var automaticTagOn  = UserDefaults.standard.bool(forKey: "Autotag")
    var serverTagOn = UserDefaults.standard.bool(forKey: "Servertag")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //set swithces to saved settings
        automaticTaggingSwitch.setOn(automaticTagOn, animated: false)
        serverTaggingSwitch.setOn(serverTagOn, animated: false)
        
        if(automaticTagOn){
            //enable server tag on if auto tag is on
            serverTaggingSwitch.isEnabled = true
            serverTaggingLabel.isEnabled = true
        }else{
            serverTaggingSwitch.isEnabled = false
            serverTaggingLabel.isEnabled = false
        }
        
    }

    //on switch, reverse "Autotag" value in user defaults, enable/disable server tag as necessary
    @IBAction func automaticTagSwitchChange(_ sender: Any) {
        var state = !automaticTagOn
        UserDefaults.standard.set(state, forKey: "Autotag")
        automaticTagOn = !automaticTagOn
        if(state){
            //if automatic tag is on
            serverTaggingSwitch.isEnabled = true
            serverTaggingLabel.isEnabled = true
        }else{
            UserDefaults.standard.set(false, forKey: "Servertag")
            serverTagOn = false
            serverTaggingSwitch.setOn(false, animated: false)
            serverTaggingSwitch.isEnabled = false
            serverTaggingLabel.isEnabled = false
        }
    }
    
    //on switch, update user defaults
    @IBAction func serverTagSwitchChange(_ sender: Any) {
        var state = !serverTagOn
        UserDefaults.standard.set(state, forKey: "Servertag")
        serverTagOn = !serverTagOn
    }
    
    
    //signOut
    @IBAction func signOutButtonClicked(_ sender: Any) {
        //print(GIDSignIn.sharedInstance()?.hasPreviousSignIn())
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.disconnect()
        //print(GIDSignIn.sharedInstance().hasPreviousSignIn())
        navigationController?.popToRootViewController(animated: true)
        //let homeView = storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeScreenViewController
        //self.navigationController?.pushViewController(homeView, animated: true)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {

    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
    
    
}

