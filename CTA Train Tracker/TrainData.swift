//
//  TrainData.swift
//  CTA Train Tracker
//
//  Created by Thomas Bart on 5/4/19.
//  Copyright © 2019 Thomas Bart. All rights reserved.
//

import Foundation

var train_data = [Route]()

enum `Type` : String {
    case brownLoop = "brownLoop"
    case brownKimbal = "brownKimbal"
    case purpleLoop = "purpleLoop"
    case purpleLinden = "purpleLinden"
    case redHoward = "redHoward"
    case red95th = "red95th"
    case unknown = "unknown"
}

class Route {
    var type : Type
    var station : String
    var direction : String
    var etas : [String]
    
    init (type: Type, direction: String, station: String, etas : [String]) {
        self.type = type
        self.direction = direction
        self.station = station
        self.etas = etas
    }
    
    func sharesRoute (with route: Route) -> Bool {
        if self.type == route.type && self.direction == route.direction && self.station == route.station {
            return true
        } else {
            return false
        }
    }
}
