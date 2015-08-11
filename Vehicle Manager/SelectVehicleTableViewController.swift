//
//  SelectVehicleTableViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class SelectVehicleTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet var vehicleSearchBar: UISearchBar!

    var vehicles: [String] = []
    var filteredVehicleArray: [String] = []
    
    var selectedVehicles: [String] = []
    
    var parent: AddReservationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VehicleManageHelper.initializeViewController(self)
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        ServerHelper.getVehicles { (vehiclesArray) -> Void in
            if let tempVehicles = vehiclesArray {
                self.vehicles = tempVehicles
                self.filteredVehicleArray = tempVehicles
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredVehicleArray.count
        } else {
            return self.vehicles.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "")
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            cell.textLabel?.text = filteredVehicleArray[indexPath.row]
        } else {
            cell.textLabel?.text = vehicles[indexPath.row]
        }
        
        for vehicleName in selectedVehicles {
            if vehicleName == cell.textLabel?.text {
                cell.accessoryType = .Checkmark
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == .Checkmark {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .Checkmark
        }
    }
    
    @IBAction func onDoneButtonTapped(sender: AnyObject) {
        var vehicleNames: [String] = []
        for(var i=0; i<tableView.numberOfRowsInSection(0); i++) {
            let cellPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(cellPath)
            if cell?.accessoryType == .Checkmark {
                vehicleNames.append(filteredVehicleArray[i])
            }
        }
        if vehicleNames.count < 0 {
            VehicleManageHelper.alert("Please select at least one vehicle.", message: "Please select at least one vehicle.", viewController: self)
            return
        }
        parent.updateVehicles(vehicleNames)
        dismissView()
    }
    
    func filterContentForSearchText(searchText: String) {
        self.filteredVehicleArray = vehicles.filter({(name: String) -> Bool in
            let stringMatch = name.rangeOfString(searchText)
            return (stringMatch != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissView()
    }
    
    func dismissView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }

}
