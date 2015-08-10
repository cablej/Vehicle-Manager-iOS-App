//
//  VehicleManageHelper.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

let TINT_COLOR = UIColor(red: 2/255.0, green: 10/255.0, blue: 117/255.0, alpha: 1)

let defaults = NSUserDefaults.standardUserDefaults()

class VehicleManageHelper: NSObject {

    class func formatDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd hh:mm a"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func formatDateToTime(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func formatMonthDay(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func initializeViewController(viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.navigationBar.barTintColor = TINT_COLOR
            navigationController.toolbar.barTintColor = TINT_COLOR
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    class func dateFromTimestamp(timestamp: Int) -> NSDate {
        return NSDate(timeIntervalSince1970: Double(timestamp))
    }
    
}
