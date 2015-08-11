//
//  HelpViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/10/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        VehicleManageHelper.initializeViewController(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        dismissView()
    }
    
    func dismissView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
    @IBAction func onContactButtonTapped(sender: AnyObject) {
        let email = "jackhcable@gmail.com"
        if let url = NSURL(string: "mailto:\(email)") {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
    
    @IBAction func onAdminButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: "http://d214mfsab.org") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
