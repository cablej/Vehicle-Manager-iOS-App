//
//  SettingsTableViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/8/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var lastNameTextField: UITextField!

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var schoolLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        VehicleManageHelper.initializeViewController(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if defaults.objectForKey("lastName") == nil || defaults.objectForKey("email") == nil || defaults.objectForKey("school") == nil {
            return
        }
        
        lastNameTextField.text = defaults.objectForKey("lastName") as? String
        emailTextField.text = defaults.objectForKey("email") as? String
        let str : String = "School: " + (defaults.objectForKey("school") as! String)
        schoolLabel.text = str
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        defaults.setObject(lastNameTextField.text, forKey: "lastName")
        defaults.setObject(emailTextField.text, forKey: "email")
        //defaults.setObject(schoolNameTextField.text, forKey: "school")
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        //schoolNameTextField.resignFirstResponder()
    }

    @IBAction func onLastNameTextFieldEnd(sender: AnyObject) {
        defaults.setObject(lastNameTextField.text, forKey: "lastName")
    }
    
    @IBAction func onEmailTextFieldEnd(sender: AnyObject) {
        defaults.setObject(emailTextField.text, forKey: "email")
    }
    
}
