//
//  Timer.swift
//  LocoMotive
//
//  Created by Tolga Caner on 15/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation

class Timer {
    static let sharedInstance = Timer()
    
    init() {
        let queue = DispatchQueue(label: "com.caner.tolga.LocoMotive.timer", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(5), leeway: .seconds(1))
    }
    
    var timer: DispatchSourceTimer!
    
}
