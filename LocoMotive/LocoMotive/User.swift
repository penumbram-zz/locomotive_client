//
//  User.swift
//  LocoMotive
//
//  Created by Tolga Caner on 02/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation

class User {
    
    static let sharedInstance = User()
    
    var id : Int64!
    var name : String!
    
    var currentGameId : Int64!
    
}
