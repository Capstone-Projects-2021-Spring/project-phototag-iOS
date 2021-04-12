//
//  ScheduleTagViewController.swift
//  PhotoTag
//
//  Created by Ryan on 4/6/21.
//


import UIKit
import Photos
import Firebase


class ScheduleViewController: UIViewController{

    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    
    
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thuButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    @IBOutlet weak var sunButton: UIButton!
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBOutlet weak var createScheduleButton: UIButton!
    
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    let startTimePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    
    var daysSelected:[Bool] = [false, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDatePicker()
        initButtons()
    }
    
    func initDatePicker(){
        //start date picker
        let startDateToolbar = UIToolbar()
        startDateToolbar.sizeToFit()
        let doneStartDate = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartDateClicked))
        startDateToolbar.setItems([doneStartDate], animated: true)
        //end date picker
        let endDateToolbar = UIToolbar()
        endDateToolbar.sizeToFit()
        let doneEndDate = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndDateClicked))
        endDateToolbar.setItems([doneEndDate], animated: true)
        //start time
        let startTimeToolbar = UIToolbar()
        startTimeToolbar.sizeToFit()
        let doneStartTime = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartTimeClicked))
        startTimeToolbar.setItems([doneStartTime], animated: true)
        //end time
        let endTimeToolbar = UIToolbar()
        endTimeToolbar.sizeToFit()
        let doneEndTime = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndTimeClicked))
        endTimeToolbar.setItems([doneEndTime], animated: true)
        
        
        //center allgined
        startDate.textAlignment = .right
        endDate.textAlignment = .right
        startTimeTextField.textAlignment = .right
        endTimeTextField.textAlignment = .right
        
        //add toolbar, set to wheel style
        startDate.inputAccessoryView = startDateToolbar
        endDate.inputAccessoryView = endDateToolbar
        startDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.preferredDatePickerStyle = .wheels
        
        //wheel style, time only
        startTimeTextField.inputAccessoryView = startTimeToolbar
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.datePickerMode = UIDatePicker.Mode.time
        endTimeTextField.inputAccessoryView = endTimeToolbar
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.datePickerMode = UIDatePicker.Mode.time

        
        //add picker view to text field
        startDate.inputView = startDatePicker
        endDate.inputView = endDatePicker
        startTimeTextField.inputView = startTimePicker
        endTimeTextField.inputView = endTimePicker
        
    }
    
    @objc func doneStartDateClicked(){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        startDate.text = formatter.string(from: startDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneEndDateClicked(){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        endDate.text = formatter.string(from: endDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneStartTimeClicked(){
        let formatter = DateFormatter()
        //formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        startTimeTextField.text = formatter.string(from: startTimePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneEndTimeClicked(){
        let formatter = DateFormatter()
        //formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        endTimeTextField.text = formatter.string(from: endTimePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func monButtonClicked(_ sender: Any) {
        if self.monButton.backgroundColor == UIColor.lightGray{
            monButton.backgroundColor = UIColor.systemBlue
            daysSelected[0] = true
        }else {
            monButton.backgroundColor = UIColor.lightGray
            daysSelected[0] = false
        }
    }
    
    @IBAction func tueButtonClicked(_ sender: Any) {
        if self.tueButton.backgroundColor == UIColor.lightGray{
            tueButton.backgroundColor = UIColor.systemBlue
            daysSelected[1] = true
        }else {
            tueButton.backgroundColor = UIColor.lightGray
            daysSelected[1] = false
        }
    }
        
    @IBAction func wedButtonClicked(_ sender: Any) {
        if self.wedButton.backgroundColor == UIColor.lightGray{
            wedButton.backgroundColor = UIColor.systemBlue
            daysSelected[2] = true
        }else {
            wedButton.backgroundColor = UIColor.lightGray
            daysSelected[2] = false
        }
    }
    @IBAction func thuButtonClicked(_ sender: Any) {
        if self.thuButton.backgroundColor == UIColor.lightGray{
            thuButton.backgroundColor = UIColor.systemBlue
            daysSelected[3] = true
        }else {
            thuButton.backgroundColor = UIColor.lightGray
            daysSelected[3] = false
        }
    }
    
    @IBAction func friButtonClicked(_ sender: Any) {
        if self.friButton.backgroundColor == UIColor.lightGray{
            friButton.backgroundColor = UIColor.systemBlue
            daysSelected[4] = true
        }else {
            friButton.backgroundColor = UIColor.lightGray
            daysSelected[4] = false
        }
    }
    
    @IBAction func satButtonClicked(_ sender: Any) {
        if self.satButton.backgroundColor == UIColor.lightGray{
            satButton.backgroundColor = UIColor.systemBlue
            daysSelected[5] = true
        }else {
            satButton.backgroundColor = UIColor.lightGray
            daysSelected[5] = false
        }
    }
    
    @IBAction func sunButtonClicked(_ sender: Any) {
        if self.sunButton.backgroundColor == UIColor.lightGray{
            sunButton.backgroundColor = UIColor.systemBlue
            daysSelected[6] = true
        }else {
            sunButton.backgroundColor = UIColor.lightGray
            daysSelected[6] = false
        }
        print(daysSelected)
    }

    func initButtons(){
        monButton.backgroundColor = UIColor.lightGray
        tueButton.backgroundColor = UIColor.lightGray
        wedButton.backgroundColor = UIColor.lightGray
        thuButton.backgroundColor = UIColor.lightGray
        friButton.backgroundColor = UIColor.lightGray
        satButton.backgroundColor = UIColor.lightGray
        sunButton.backgroundColor = UIColor.lightGray
    }
    
    
    @IBAction func createScheduledTagButtonClicked(_ sender: Any) {
        
        let scheduleDict = ["start date" : startDate.text!,
                            "end date" : endDate.text!,
                            "start time" : startTimeTextField.text!,
                            "end time" : endTimeTextField.text!,
                            "days" : arrayToBitMask(),
                            "tag" : tagTextField.text!]
        
        print(scheduleDict)
        
        var username = UserDefaults.standard.string(forKey: "Username")
        username = ScheduleViewController.firebaseEncodeString(str: username!)
        
        var ref: DatabaseReference = Database.database().reference()
        
        //ref = ref.child("iOS/\(username)/Schedules/\(self.id)")
        //ref = ref.child("iOS/\(username)/Schedules/")
        ref = Database.database().reference().child("iOS").child(username!).child("Schedules")
      
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        var key = timeInterval.truncatingRemainder(dividingBy: 1)
        
        
        
        print(timeInterval)
        print(key)
        var keyAsStr = ScheduleViewController.firebaseEncodeString(str: String(key))
        
        ref.child(keyAsStr).setValue(scheduleDict)
        
        //let galleryView = storyboard?.instantiateViewController(withIdentifier: "GalleryView") as! ViewController
        //galleryView.username = User.username!
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    func arrayToBitMask() -> String{
        var mask:Int = 0;
        if daysSelected[0] == true{
            mask += 1;
        }
        if daysSelected[1] == true{
            mask += 2;
        }
        if daysSelected[2] == true{
            mask += 4;
        }
        if daysSelected[3] == true{
            mask += 8;
        }
        if daysSelected[4] == true{
            mask += 16;
        }
        if daysSelected[5] == true{
            mask += 32;
        }
        if daysSelected[6] == true{
            mask += 64;
        }
        return String(mask)
    }
    /*
     * Encode a string to be firebase key friendly
     * @param   String  String to encode
     * @return  String  Endoded, firebase friendly, string
     */
    static func firebaseEncodeString(str: String) -> String {
        var newStr = str
        newStr = newStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        newStr = newStr.replacingOccurrences(of: ".", with: "---|")
        newStr = newStr.replacingOccurrences(of: "#", with: "--|-")
        newStr = newStr.replacingOccurrences(of: "$", with: "-|--")
        newStr = newStr.replacingOccurrences(of: "[", with: "|---")
        newStr = newStr.replacingOccurrences(of: "]", with: "|--|")
        return newStr
    }
    
}
