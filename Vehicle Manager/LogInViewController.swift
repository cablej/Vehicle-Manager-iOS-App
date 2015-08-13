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
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var accessCodeTextField: UITextField!
    
    var requiresCode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accessCodeTextField.hidden = true
        
        checkRequiresCode()
        
        VehicleManageHelper.initializeViewController(self)
        
        nextButton.backgroundColor = primaryColor
        
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        accessCodeTextField.delegate = self
        
    }
    
    func checkRequiresCode() {
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=RequiresCode") {
            response in
            if(response == "false") {
                self.requiresCode = false
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.requiresCode {
                    self.accessCodeTextField.hidden = false
                }
            })
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onNextButtonTapped(sender: AnyObject) {
        if requiresCode {
            ServerHelper.sendRequest(REQUEST_URL, postString:"action=SubmitCode&code=\(accessCodeTextField.text!)") {
                response in
                if(response == "success") {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.proceed()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        VehicleManageHelper.alert("Error", message: "Access code not valid.", viewController: self)
                    })
                }
            }
        } else {
            proceed()
        }
        
    }
    
    func proceed() {
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
