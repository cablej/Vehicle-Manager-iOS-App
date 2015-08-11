//
//  SelectVehicleTableViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class SelectSchoolTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet var schoolSearchBar: UISearchBar!
    
    var schools: [School] = []
    var filteredSchoolArray: [School] = []
    
    var parentLogInViewController: LogInViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VehicleManageHelper.initializeViewController(self)
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        ServerHelper.getSchools { (schoolsArray) -> Void in
            if let tempSchools = schoolsArray {
                self.schools = tempSchools
                self.filteredSchoolArray = tempSchools
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredSchoolArray.count
        } else {
            return self.schools.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "")
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            cell.textLabel?.text = filteredSchoolArray[indexPath.row].name
        } else {
            cell.textLabel?.text = schools[indexPath.row].name
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = filteredSchoolArray[indexPath.row]
        defaults.setObject(school.name, forKey: "school")
        defaults.setObject(school.primaryColor, forKey: "primaryColor")
        defaults.setObject(school.secondaryColor, forKey: "secondaryColor")
        if parentLogInViewController != nil {
            parentLogInViewController!.dismissView()
        }
        dismissView()
    }
    
    func filterContentForSearchText(searchText: String) {
        self.filteredSchoolArray = schools.filter({(school: School) -> Bool in
            let stringMatch = school.name.rangeOfString(searchText)
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
