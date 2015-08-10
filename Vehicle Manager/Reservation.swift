//
//  Reservation.swift
//  Vehicle Manager
//
//  Created by Jack Cable on 8/7/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class Reservation: NSObject {
    
    var vehicleName: String = ""
    var owner: String = ""
    var startTime: Int = 0
    var endTime: Int = 0
    
    init(vehicleName: String, owner: String, startTime: Int, endTime: Int) {
        super.init()
        
        self.vehicleName = vehicleName
        self.owner = owner
        self.startTime = startTime
        self.endTime = endTime
    }
    
}
