//
//  SettingsViewController.swift
//  PhotoTag
//
//  Created by Ryan on 3/12/21.
//

import UIKit
import QuickTableViewController

class SettingsViewController: UIViewController{

    
    
    @IBOutlet weak var automaticTaggingLabel: UILabel!
    @IBOutlet weak var localTaggingLabel: UILabel!
    
    @IBOutlet weak var automaticTaggingSwitch: UISwitch!
    @IBOutlet weak var localTaggingSwitch: UISwitch!
    
    var settingsArray: [String] = ["Automatic Tagging", "Local Tagging"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var automaticTagOn  = UserDefaults.standard.bool(forKey: "Autotag")
        var localTagOn = UserDefaults.standard.bool(forKey: "Localtag")

        automaticTaggingSwitch.setOn(automaticTagOn, animated: false)
        localTaggingSwitch.setOn(localTagOn, animated: false)
        
    }


    @IBAction func automaticTagSwitchChange(_ sender: Any) {
        var state = UserDefaults.standard.bool(forKey: "Autotag")
        state = !state
        UserDefaults.standard.set(state, forKey: "Autotag")
    }
    
    @IBAction func localTagSwitchChange(_ sender: Any) {
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


