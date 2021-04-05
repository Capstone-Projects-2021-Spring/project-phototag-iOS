//
//  SettingsViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/12/21.
//

import UIKit

class SettingsViewController: UIViewController{

    
    
    @IBOutlet weak var automaticTaggingLabel: UILabel!
    @IBOutlet weak var serverTaggingLabel: UILabel!
    
    @IBOutlet weak var automaticTaggingSwitch: UISwitch!
    @IBOutlet weak var serverTaggingSwitch: UISwitch!
    
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
    
    
}



    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   /* @IBAction func switchDidChange(sender: UISwitch){
        if sender.isOn{
            view.backgroundColor = .red
        }
    }*/
    /*
    func numberOfSections(in tV: UITableView) -> Int{
        return 1
    }
    */

    

    
   /* func tableView(_ tv: UITableView, cellForRowAt section: Int)->{
        return 2
    }*/


