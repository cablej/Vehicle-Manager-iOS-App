//
//  ServerHelper.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

let REQUEST_URL = "http://d214mfsab.org/request.php"

class ServerHelper: NSObject {
    
    class func sendRequest(url: String, postString: String, completionHandler : (String) -> ()){
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        var responseString = ""
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if(error != nil) {
                print("error=\(error)")
                return
            }
            
            responseString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            
            //print(responseString)
            
            completionHandler(responseString)
            
        }
        
        task.resume()
    }
    
    class func getVehicles(success: ((vehiclesArray: [String]?) -> Void)) {
        guard let school = NSUserDefaults.standardUserDefaults().objectForKey("school") else {
            return
        }
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=GetVehicles&school=\(school)") {
            response in
            
            if let error = ServerHelper.error(response) {
                print(error)
                return
            }
            
            if let responseJSON = ServerHelper.stringToJSON(response) {
                var vehicles: [String] = []
                for vehicle in responseJSON {
                    vehicles.append(vehicle.1["vehicleName"].stringValue)
                }
                success(vehiclesArray: vehicles)
            }
        }
    }
    
    class func getSchools(success: ((schoolArray: [School]?) -> Void)) {
        ServerHelper.sendRequest(REQUEST_URL, postString:"action=GetSchools") {
            response in
            
            if let error = ServerHelper.error(response) {
                print(error)
                return
            }
            
            if let responseJSON = ServerHelper.stringToJSON(response) {
                var schools: [School] = []
                for school in responseJSON {
                    let newSchool = School()
                    newSchool.name = school.1["name"].stringValue
                    newSchool.primaryColor = school.1["primaryColor"].stringValue
                    newSchool.secondaryColor = school.1["secondaryColor"].stringValue
                    schools.append(newSchool)
                }
                success(schoolArray: schools)
            }
        }
    }
    
    class func getReservations(school: String, success:((reservations: Dictionary<String, [Reservation]>) -> Void)) {
        var reservations = Dictionary<String, [Reservation]>()
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
                    
                    let monthDay = ServerHelper.formatMonthDay(ServerHelper.dateFromTimestamp( reservation.startTime))
                    
                    if let dayReservations = reservations[monthDay] {
                            reservations[monthDay] = dayReservations + [reservation]
                    } else {
                        reservations[monthDay] = [reservation]
                    }
                }
                success(reservations: reservations)
            }
        }
    }
    
    func reservationObjectFromJSON(json: JSON) -> Reservation {
        let reservation = Reservation(vehicleName: json["vehicleName"].stringValue, owner: json["owner"].stringValue, startTime: json["startTime"].intValue, endTime: json["endTime"].intValue)
        return reservation
    }
    
    func propertiesFromJSON(json: JSON) -> [String: String] {
        var properties = Dictionary<String, String>()
        
        for (key, object) in json {
            properties[key] = object.stringValue
        }
        
        return properties
    }
    
    class func stringToJSON(string: String) -> JSON? {
        let jsonObject : AnyObject?
        
        let json : JSON
        
        do {
            
            try jsonObject = NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: NSJSONReadingOptions.MutableContainers)
            
            
            json = JSON(jsonObject!)
            
            return json
        } catch {
            return nil
        }
    }
    
    class func error(response: String) -> String? {
        if let json = stringToJSON(response) {
            let error = json["error"].stringValue
            
            if(error != "") {
                return error
            }
        }
        return nil
    }
    
    class func formatMonthDay(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFromTimestamp(timestamp: Int) -> NSDate {
        return NSDate(timeIntervalSince1970: Double(timestamp))
    }
    
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
    
    
    class func getDateForSection(section: Int) -> NSDate {
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let offsetComponents = NSDateComponents()
        offsetComponents.day = section
        
        let day = gregorian.dateByAddingComponents(offsetComponents, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
        
        return gregorian.startOfDayForDate(day)
        
    }

}
