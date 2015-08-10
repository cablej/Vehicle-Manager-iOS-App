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
    
    @IBOutlet var schoolNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VehicleManageHelper.initializeViewController(self)
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        schoolNameTextField.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        lastNameTextField.text = defaults.objectForKey("lastName") as? String
        emailTextField.text = defaults.objectForKey("email") as? String
        schoolNameTextField.text = defaults.objectForKey("school") as? String
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        defaults.setObject(lastNameTextField.text, forKey: "lastName")
        defaults.setObject(emailTextField.text, forKey: "email")
        defaults.setObject(schoolNameTextField.text, forKey: "school")
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        schoolNameTextField.resignFirstResponder()
    }

}
