//
//  CalenderTableViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class CalenderTableViewController: UITableViewController {

    var reservations: [String : [Reservation]] = Dictionary<String, [Reservation]>()
    var vehicles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl!)
        
    }
    
    func refresh(sender:AnyObject)
    {
        updateReservations()
        updateVehicles()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? UINavigationController {
            if let dvc = nvc.viewControllers.first as? AddReservationViewController {
                let row = tableView.indexPathForSelectedRow?.row
                let section = tableView.indexPathForSelectedRow?.section
                dvc.vehicleNames = [vehicles[row!]]
                dvc.startDate = ServerHelper.getDateForSection(section!)
            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        
        
        if let color = defaults.objectForKey("primaryColor") as? String {
            if color != "" {
                primaryColor = UIColor(rgba: "#" + color)
            }
        }
        if let color = defaults.objectForKey("secondaryColor") as? String {
            if color != "" {
                secondaryColor = UIColor(rgba: "#" + color)
            }
        }
        
        VehicleManageHelper.initializeViewController(self)
        
        if defaults.objectForKey("lastName") == nil || defaults.objectForKey("email") == nil || defaults.objectForKey("school") == nil || defaults.objectForKey("lastName") as? String == "" || defaults.objectForKey("email") as? String == "" {
            performSegueWithIdentifier("DisplayLogin", sender: self)
            return
        }
        if defaults.objectForKey("hasOpenedFirstTime") == nil {
            defaults.setObject(true, forKey: "hasOpenedFirstTime")
            VehicleManageHelper.alert("Welcome", message: "Select a vehicle to begin your reservation.", viewController: self)
        }
        
        updateReservations()
        updateVehicles()
    }
    
    func updateReservations() {
        
        self.reservations = Dictionary<String, [Reservation]>()
        
        if defaults.objectForKey("school") == nil {
            return
        }
        let school = defaults.objectForKey("school") as! String
        
        ServerHelper.getReservations(school) { (reservations) in
            self.reservations = reservations
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
    }
    
    func updateVehicles() {
        ServerHelper.getVehicles { (vehiclesArray) -> Void in
            if let tempVehicles = vehiclesArray {
                self.vehicles = tempVehicles
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 365
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ServerHelper.formatMonthDay(ServerHelper.getDateForSection(section))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("AddReservation", sender: nil)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 20))
        headerView.backgroundColor = secondaryColor
        
        let headerLabel = UILabel(frame: CGRectMake(0, 1.5, headerView.frame.size.width, headerView.frame.size.height))
        
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.text = ServerHelper.formatMonthDay(ServerHelper.getDateForSection(section))
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CalenderCell", forIndexPath: indexPath) as! CalenderTableViewCell
        var timesTaken = "Free"
        var timeTaken = 0
        
        if let reservationsForDay = reservations[ServerHelper.formatMonthDay(ServerHelper.getDateForSection(indexPath.section))] {
            timesTaken = ""
            var hasChanged = false
            for reservation in reservationsForDay {
                if reservation.vehicleName == vehicles[indexPath.row] {
                    hasChanged = true
                    timesTaken += "\(reservation.owner) \(ServerHelper.formatDateToTime(ServerHelper.dateFromTimestamp(reservation.startTime))) - \(ServerHelper.formatDateToTime(ServerHelper.dateFromTimestamp(reservation.endTime)))"
                    timeTaken += reservation.endTime - reservation.startTime
                }
            }
            if(!hasChanged) {
                timesTaken = "Free"
            }
        }
        
        cell.vehicleNameLabel.text = vehicles[indexPath.row]
        cell.timesTakenLabel.text = timesTaken
        let progress: Float = 1 - Float(timeTaken)/(24.0*60.0*60.0)
        cell.percentageTaken.setProgress(progress, animated: true)

        return cell
    }

}
