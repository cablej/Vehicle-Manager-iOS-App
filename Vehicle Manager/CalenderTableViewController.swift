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
        
        VehicleManageHelper.initializeViewController(self)
        
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
                dvc.vehicleName = vehicles[tableView.indexPathForSelectedRow!.row]
                dvc.startDate = getDateForSection(tableView.indexPathForSelectedRow!.section)
            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        updateReservations()
        updateVehicles()
    }
    
    func updateReservations() {
        
        self.reservations = Dictionary<String, [Reservation]>()
        
        if defaults.objectForKey("school") == nil {
            return
        }
        let school = defaults.objectForKey("school") as! String
        
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=GetVehiclesReserved&school=\(school)") {
            response in
            
            if let error = ServerHelper.error(response) {
                print(error)
                return
            }
            
            if let responseJSON = ServerHelper.stringToJSON(response) {
                for reservation in responseJSON {
                    let reservationJSON: JSON = reservation.1
                    let reservation = Reservation(vehicleName: reservationJSON["vehicleName"].stringValue, owner: reservationJSON["owner"].stringValue, startTime: reservationJSON["startDateTime"].intValue, endTime: reservationJSON["endDateTime"].intValue)
                    
                    let monthDay = VehicleManageHelper.formatMonthDay(VehicleManageHelper.dateFromTimestamp( reservation.startTime))
                    
                    if let dayReservations = self.reservations[monthDay] {
                         self.reservations[monthDay] = dayReservations + [reservation]
                    } else {
                        self.reservations[monthDay] = [reservation]
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
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
        return 90
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return VehicleManageHelper.formatMonthDay(getDateForSection(section))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("AddReservation", sender: nil)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 20))
        headerView.backgroundColor = UIColor(red: 129/255.0, green: 166/255.0, blue: 194/255.0, alpha: 1)
        
        let headerLabel = UILabel(frame: CGRectMake(0, 1.5, headerView.frame.size.width, headerView.frame.size.height))
        
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.text = VehicleManageHelper.formatMonthDay(getDateForSection(section))
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CalenderCell", forIndexPath: indexPath) as! CalenderTableViewCell
        var timesTaken = "Free"
        var timeTaken = 0
        
        if let reservationsForDay = reservations[VehicleManageHelper.formatMonthDay(getDateForSection(indexPath.section))] {
            timesTaken = ""
            var hasChanged = false
            for reservation in reservationsForDay {
                if reservation.vehicleName == vehicles[indexPath.row] {
                    hasChanged = true
                    timesTaken += "\(reservation.owner) \(VehicleManageHelper.formatDateToTime(VehicleManageHelper.dateFromTimestamp(reservation.startTime))) - \(VehicleManageHelper.formatDateToTime(VehicleManageHelper.dateFromTimestamp(reservation.endTime)))"
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
    
    func getDateForSection(section: Int) -> NSDate {
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let offsetComponents = NSDateComponents()
        offsetComponents.day = section
        let day = gregorian.dateByAddingComponents(offsetComponents, toDate: NSDate(), options: [])!
        
        return gregorian.startOfDayForDate(day)

    }

}
