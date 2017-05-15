//
//  CustomNavigationController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 12/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit

class CustomNavigationControll: UINavigationController {
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if animated {
            let transition = CATransition.init()
            transition.duration = 0.5
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromBottom
            self.view.layer.add(transition, forKey: kCATransition)
        }
        return super.popViewController(animated: false)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            let transition = CATransition.init()
            transition.duration = 0.5
            transition.type = kCATransitionFade
            self.view.layer.add(transition, forKey: kCATransition)
        }
        return super.popToRootViewController(animated: false)
    }
    
}
