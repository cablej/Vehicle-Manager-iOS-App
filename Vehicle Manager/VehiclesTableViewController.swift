//
//  VehiclesTableViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class VehiclesTableViewController: UITableViewController {
    
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    var vehicles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        VehicleManageHelper.initializeViewController(self)

    }
    
    override func viewWillAppear(animated: Bool) {
        ServerHelper.getVehicles { (vehiclesArray) -> Void in
            if let tempVehicles = vehiclesArray {
                self.vehicles = tempVehicles
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    @IBAction func onEditButtonTapped(sender: AnyObject) {
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing {
            editBarButton.title = "Done"
        } else {
            editBarButton.title = "Edit"
        }
    }
    
    @IBAction func onAddButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Vehicle", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add vehicle"
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            let vehicleTextField = alert.textFields![0] as UITextField
            
            if defaults.objectForKey("school") == nil {
                return
            }
            let school = defaults.objectForKey("school") as! String
            
            ServerHelper.sendRequest(REQUEST_URL, postString:"action=AddVehicle&vehicleName=\(vehicleTextField.text!)&school=\(school)") {
                response in
                
                if let error = ServerHelper.error(response) {
                    print(error)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.vehicles.append(vehicleTextField.text!)
                    self.tableView.reloadData()
                })
                
            }
            
        }
        
        alert.addAction(addAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            if defaults.objectForKey("school") == nil {
                return
            }
            let school = defaults.objectForKey("school") as! String
            
            ServerHelper.sendRequest(REQUEST_URL, postString:"action=RemoveVehicle&vehicleName=\(vehicles[indexPath.row])&school=\(school)") {
                response in
                
                if let error = ServerHelper.error(response) {
                    print(error)
                    return
                }
            }
            
            vehicles.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vehicles.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "")
        
        cell.textLabel?.text = vehicles[indexPath.row]
        
        return cell
    }

}
