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
        if defaults.objectForKey("school") == nil {
            return
        }
        let school = defaults.objectForKey("school") as! String
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
            jsonObject = try NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding)!,
                options: NSJSONReadingOptions.AllowFragments)
            json = JSON(jsonObject!)
            
            return json
            
            
        } catch {
            
        }
        return nil;
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

}
