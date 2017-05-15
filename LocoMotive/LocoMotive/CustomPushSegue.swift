//
//  CustomPushSegue.swift
//  LocoMotive
//
//  Created by Tolga Caner on 12/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Foundation

class CustomPushSegue: UIStoryboardSegue {
    
    override func perform() {
        let transition = CATransition.init()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromTop
        
        self.source.view.window?.layer.add(transition, forKey: kCATransition)
        _ = self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
    
}
