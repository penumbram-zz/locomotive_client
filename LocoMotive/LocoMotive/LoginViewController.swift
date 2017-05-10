//
//  LoginViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 01/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var lblUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedText = self.lblUsername.attributedText?.mutableCopy() as! NSMutableAttributedString
        attributedText.addAttribute(NSKernAttributeName, value: -0.7, range: NSRange(location: 0,length: attributedText.length))
        self.lblUsername.attributedText = attributedText
    }

    @IBAction func btnPlayAction(_ sender: UIButton) {
        
        guard self.tfNickname.text != nil && self.tfNickname.text != "" else {
            AlertViewManager.init(title: "Error!", message: "Please provide a nickname.", okActionTitle: "OK").showOnViewController(self)
            return
        }
        let nickName = self.tfNickname.text!
        
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/user/add", method: .post, parameters: [
            "nickname": nickName
        ]) {[unowned self] success,json in
            if success {
                if let code = json["code"].int, let message = json["message"].string {
                    if code == 200 && message == "User added successfully" {
                        if json["user"] != JSON.null {
                            if let id = json["user"]["id"].int64, let nick = json["user"]["nickname"].string {
                                User.sharedInstance.id = id
                                User.sharedInstance.name = nick
                                self.performSegue(withIdentifier: "showLobbyListViewCOntroller", sender: self)
                            }
                        }
                    }
                }
            }
        }
        
    }

}

