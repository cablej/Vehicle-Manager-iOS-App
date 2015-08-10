//
//  ReservationViewController.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class ReservationTableViewController: UITableViewController {
    
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    var reservations: [Reservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        VehicleManageHelper.initializeViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateReservations()
    }
    
    func updateReservations() {
        
        self.reservations = []
        
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
                    self.reservations.append(reservation)
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
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
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if defaults.objectForKey("school") == nil {
            return
        }
        let school = defaults.objectForKey("school") as! String
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            ServerHelper.sendRequest(REQUEST_URL, postString:"action=RemoveReservation&vehicleName=\(reservations[indexPath.row].vehicleName)&owner=\(reservations[indexPath.row].owner)&startTime=\(reservations[indexPath.row].startTime)&endTime=\(reservations[indexPath.row].endTime)&school=\(school)") {
                response in
                
                if let error = ServerHelper.error(response) {
                    print(error)
                    return
                }
            }

            reservations.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReservationCell", forIndexPath: indexPath) as! ReservationTableViewCell
        
        let reservation = reservations[indexPath.row]
        
        cell.vehicleNameLabel.text = reservation.vehicleName
        cell.ownerNameLabel.text = reservation.owner
        cell.startTimeLabel.text = VehicleManageHelper.formatDate(VehicleManageHelper.dateFromTimestamp(reservation.startTime))
        cell.endTimeLabel.text = VehicleManageHelper.formatDate(VehicleManageHelper.dateFromTimestamp(reservation.endTime))
        
        return cell
    }
    

}
