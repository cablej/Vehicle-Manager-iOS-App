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
    
    var vehicleNames: [String] = []
    var startDate: NSDate?
    var endDate: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VehicleManageHelper.initializeViewController(self)
        addBarButton.enabled = false
        
        updateVehicles(vehicleNames)
        if let date = startDate {
            startDatePicker.setDate(date, animated: false)
            endDatePicker.setDate(date, animated: false)
            endDatePicker.minimumDate = date
        }
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        let startTimeStamp = startDatePicker.date.timeIntervalSince1970
        let endTimeStamp = endDatePicker.date.timeIntervalSince1970
        
        if(vehicleNames.count == 0) {
            VehicleManageHelper.alert("Please select at least one vehicle.", message: "Please select at least one vehicle.", viewController: self)
        }
        
        if defaults.objectForKey("lastName") == nil || defaults.objectForKey("email") == nil || defaults.objectForKey("school") == nil {
            VehicleManageHelper.alert("Settings not entered", message: "You have not entered your information in settings. Please edit your settings and return.", viewController: self)
            return
        }
        
        let lastName = defaults.objectForKey("lastName") as! String
        let email = defaults.objectForKey("email") as! String
        let school = defaults.objectForKey("school") as! String
        
        var vehiclePostNames = "&vehicleName=" + vehicleNames[0]
        
        if vehicleNames.count > 1 {
            vehiclePostNames = ""
            for(var i=0; i<vehicleNames.count; i++) {
                vehiclePostNames += "&vehicles[]=\(vehicleNames[i])"
            }
        }
        
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=SubmitRequest&school=\(school)&email=\(email)\(vehiclePostNames)&owner=\(lastName)&startTime=\(Int(startTimeStamp))&endTime=\(Int(endTimeStamp))") {
            response in
            
            print(response)
            
            if let error = ServerHelper.error(response) {
                print(error)
                VehicleManageHelper.alert("Error", message: error, viewController: self)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertController(title: "Success", message: "You have successfully submitted your request. You will be sent an email when it is reviewed.", preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in
                    self.dismissView()
                })
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? UINavigationController {
            if let dvc = nvc.viewControllers.first as? SelectVehicleTableViewController {
                dvc.parent = self
                dvc.selectedVehicles = vehicleNames
            }
        }
    }
    
    func updateVehicles(vehicles: [String]) {
        vehicleNames = vehicles
        if vehicles.count == 1 {
            vehicleNameLabel.text = "Vehicle name: \(vehicles[0])"
        } else if vehicles.count > 1 {
            var labelString = "Vehicle names: \(vehicles[0])"
            for(var i=1; i<vehicles.count; i++) {
                labelString += ", \(vehicles[i])"
            }
            vehicleNameLabel.text = labelString
        }
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
        if(vehicleNames.count > 0) {
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
