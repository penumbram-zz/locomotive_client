//
//  SocketMessage.swift
//  LocoMotive
//
//  Created by Tolga Caner on 07/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation

class SocketMessage {
    
    var dict : [String : Any]
    
    init() {
        self.dict = ["id": User.sharedInstance.id, "name": User.sharedInstance.name,]
    }
    
    /*
    func baseM() -> [String: Any] {
        return
    }
    */
    
    func position(latlon : [String : Double]) -> SocketMessage {
        self.dict["position"] = latlon
        return self
    }
    
    func action(action : String) -> SocketMessage {
        self.dict["action"] = action
        return self
    }
    
    
}
