//
//  AddReservationViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class AddReservationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var vehicleNameLabel: UILabel!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    var vehicleName = ""
    var startDate: NSDate?
    var endDate: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VehicleManageHelper.initializeViewController(self)
        addBarButton.enabled = false
        
        updateVehicle(vehicleName)
        if let date = startDate {
            startDatePicker.setDate(date, animated: false)
            endDatePicker.setDate(date, animated: false)
            endDatePicker.minimumDate = date
        }
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        let startTimeStamp = startDatePicker.date.timeIntervalSince1970
        let endTimeStamp = endDatePicker.date.timeIntervalSince1970
        
        if defaults.objectForKey("lastName") == nil || defaults.objectForKey("email") == nil || defaults.objectForKey("school") == nil {
            alert("Settings not entered", message: "You have not entered your information in settings. Please edit your settings and return.")
            return
        }
        
        let lastName = defaults.objectForKey("lastName") as! String
        let email = defaults.objectForKey("email") as! String
        let school = defaults.objectForKey("school") as! String
        
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=SubmitRequest&school=\(school)&email=\(email)&vehicleName=\(vehicleName)&owner=\(lastName)&startTime=\(Int(startTimeStamp))&endTime=\(Int(endTimeStamp))") {
            response in
            
            if let error = ServerHelper.error(response) {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertController(title: "Success", message: "Successfully submitted your request. You will be sent an email when it is reviewed.", preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in
                    self.dismissView()
                })
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func alert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        return
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? UINavigationController {
            if let dvc = nvc.viewControllers.first as? SelectVehicleTableViewController {
                dvc.parent = self
            }
        }
    }
    
    func updateVehicle(name: String) {
        vehicleName = name
        vehicleNameLabel.text = "Vehicle name: \(name)"
        checkAddBarButton()
    }
    
    @IBAction func onStartDateValueChanged(sender: UIDatePicker) {
        endDatePicker.minimumDate = startDatePicker.date
        checkAddBarButton()
    }
    
    @IBAction func onEndDateValueChanged(sender: UIDatePicker) {
        checkAddBarButton()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func checkAddBarButton() {
        if(vehicleName != "") {
            let startTimeStamp = Int(startDatePicker.date.timeIntervalSince1970)
            let endTimeStamp = Int(endDatePicker.date.timeIntervalSince1970)
            if(startTimeStamp < endTimeStamp) {
                addBarButton.enabled = true
                return
            }
        }
        addBarButton.enabled = false
    }
    
    func dismissView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }

}
