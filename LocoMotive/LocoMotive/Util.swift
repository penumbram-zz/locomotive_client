//
//  Util.swift
//  LocoMotive
//
//  Created by Tolga Caner on 06/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation


class Util {
    
    class func secondsFromNow(_ seconds : TimeInterval) -> String {
        var dateString : String
        let date = Date().addingTimeInterval(seconds)
        let calendar = Calendar.current
        let year = dateComponent(.year, date: date, calendar: calendar)
        let month = dateComponent(.month, date: date, calendar: calendar)
        let day = dateComponent(.day, date: date, calendar: calendar)
        
        let hour = dateComponent(.hour, date: date, calendar: calendar)
        
        let minutes = dateComponent(.minute, date: date, calendar: calendar)
        let seconds = dateComponent(.second, date: date, calendar: calendar)
        dateString = "\(day)-\(month)-\(year) \(hour):\(minutes):\(seconds)"
        return dateString
    }
    
    class func dateComponent(_ component : Calendar.Component, date: Date, calendar: Calendar) -> String {
        return dateValue(String(calendar.component(component, from: date)))
    }
    
    class func dateValue(_ value : String) -> String {
        var val = value
        if val.characters.count == 1 {
            val.insert("0", at: val.startIndex)
        }
        return val
    }
    
}
