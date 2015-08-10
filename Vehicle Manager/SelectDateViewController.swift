//
//  SelectDateViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var minimumDate: NSDate?
    var currentDate: NSDate?
    
    var dateType = ""
    var parent: AddReservationViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        VehicleManageHelper.initializeViewController(self)
        
        if currentDate != nil {
            datePicker.setDate(currentDate!, animated: true)
        }
        if minimumDate != nil {
            datePicker.minimumDate = minimumDate!
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        if dateType == "start" {
            //parent.updateStartDate(datePicker.date)
        } else {
            //parent.updateEndDate(datePicker.date)
        }
        dismissView()
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        dismissView()
    }
    
    func dismissView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
}
