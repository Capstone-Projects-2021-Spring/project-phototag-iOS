//
//  ScheduleTagViewController.swift
//  PhotoTag
//
//  Created by Ryan on 4/6/21.
//


import UIKit
import Photos
import FirebaseDatabase



class ScheduleTagViewController: UIViewController{
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveScheduleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveScheduleButtonDidClick(_ sender: Any) {
        
        let scheduleStart = fromDatePicker.date
        let scheduleEnd = toDatePicker.date
        print(scheduleStart)
        
        //TODO seque view (back to settings?)
        //TODO add date to server
        
    }
    
}
