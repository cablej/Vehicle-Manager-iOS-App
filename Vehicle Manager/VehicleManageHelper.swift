//
//  VehicleManageHelper.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

var primaryColor = UIColor(red: 188/255.0, green: 33/255.0, blue: 49/255.0, alpha: 1)
var secondaryColor = UIColor(red: 42/255.0, green: 48/255.0, blue: 53/255.0, alpha: 1)

let defaults = NSUserDefaults.standardUserDefaults()

class VehicleManageHelper: NSObject {
    
    
    class func alert(title: String, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        viewController.presentViewController(alert, animated: true, completion: nil)
        return
    }
    
    class func initializeViewController(viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.navigationBar.barTintColor = primaryColor
            navigationController.toolbar.barTintColor = primaryColor
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    
    
}
