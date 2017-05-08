//
//  Prize.swift
//  LocoMotive
//
//  Created by Tolga Caner on 08/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation

class Prize {
    
    init(id : Int64, latitude : Double, longitude : Double, color : String, points : Int, claimer : Int64) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.color = color
        self.points = points
        self.claimer = claimer
    }
    
    var id : Int64 // Database primary key
    
    var latitude : Double
    
    var longitude : Double
    
    var color : String
    
    var points : Int
    
    var claimer : Int64
    
}
