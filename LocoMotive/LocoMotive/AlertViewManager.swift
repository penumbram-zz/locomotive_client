//
//  AlertViewManager.swift
//  LocoMotive
//
//  Created by Tolga Caner on 03/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SVProgressHUD

class AlertViewManager {
    
    var mAlertController : UIAlertController
    
    
    init(title : String, message : String, okActionTitle: String) {
        mAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        /*
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
         // ...
         }
         
         alertController.addAction(cancelAction)
         */
        let OKAction = UIAlertAction(title: okActionTitle, style: .default) { action in
            // ...
        }
        mAlertController.addAction(OKAction)
    }
    
    func showOnViewController(_ viewController : UIViewController)  {
        
        viewController.present(mAlertController, animated: true) {
            // ...
        }
    }
    
    class func showLoading() {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
    }
    
    class func hideLoading() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
}
