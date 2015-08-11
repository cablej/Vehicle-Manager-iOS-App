//
//  LogInViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/10/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VehicleManageHelper.initializeViewController(self)
        
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onNextButtonTapped(sender: AnyObject) {
        if lastNameTextField.text == "" || emailTextField.text == "" {
            VehicleManageHelper.alert("Please complete the required fields.", message: "Please complete the required fields.", viewController: self)
            return
        }
        defaults.setObject(lastNameTextField.text, forKey: "lastName")
        defaults.setObject(emailTextField.text, forKey: "email")
        defaults.setObject(nil, forKey: "hasOpenedFirstTime")
        performSegueWithIdentifier("SelectSchool", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? UINavigationController {
            if let dvc = nvc.viewControllers.first as? SelectSchoolTableViewController {
                dvc.parentLogInViewController = self
            }
        }
    }
    
    func dismissView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
}
