//
//  GameLobbyViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 06/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SwiftyJSON

class GameLobbyViewController: UIViewController {
    
    var gameData : JSON!
    var tableViewController : GameLobbyTableViewController!
    
    @IBOutlet weak var vNonHosts: UIView!
    @IBOutlet weak var btnStartGame: UIButton!
    
    private func startTimer() {
        Timer.sharedInstance.timer.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            print(Date())
            if User.sharedInstance.currentGameId != nil {
                NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/status", method: .post ,parameters: [
                    "gameId": User.sharedInstance.currentGameId!,
                    "user" : [
                        "id" : User.sharedInstance.id,
                        "nickname" : User.sharedInstance.name
                    ]
                ]) { [weak self] success,json in
                    var isSuccess = false
                    if success {
                        if let code = json["code"].int, let message = json["message"].string {
                            if code == 200 && message == "Status Update" {
                                isSuccess = true
                            }
                        }
                    }
                    
                    if isSuccess {
                        let started = json["game"]["started"].bool
                        let portValue = json["game"]["port"]
                        if started! {
                            Timer.sharedInstance.timer.suspend()
                            AlertViewManager.hideLoading()
                            self?.performSegue(withIdentifier: "gameViewControllerSegue", sender: portValue.int!)
                        }
                        
                    }
                }
            }
            
            
        }
        
        Timer.sharedInstance.timer.resume()
    }
    
    private func stopTimer() {
        Timer.sharedInstance.timer.suspend()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewController = self.childViewControllers[0] as! GameLobbyTableViewController
        if gameData["host_id"].int64 == User.sharedInstance.id {
            self.btnStartGame.isHidden = false
            self.vNonHosts.isHidden = true
            self.tableViewController.isHost = true
        } else {
            self.btnStartGame.isHidden = true
            self.vNonHosts.isHidden = false
        }
        self.tableViewController.dataSource = gameData["players"].array!
        self.startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AlertViewManager.hideLoading()
        }
    }
    
    
    @IBAction func btnStartGameAction(_ sender: UIButton) {
        AlertViewManager.showLoading()
        let startString = Util.secondsFromNow(30)
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/start", method: .post ,parameters: [
            "gameId": User.sharedInstance.currentGameId!,
            "user" : [
                "id" : User.sharedInstance.id,
                "nickname" : User.sharedInstance.name
            ],
            "startDate" : startString
        ]) { success,json in
            var isSuccess = false
            if success {
                if let code = json["code"].int, let message = json["message"].string {
                    if code == 200 && message.contains("Game ") {
                        isSuccess = true
                    }
                }
            }
            
            if isSuccess {
                print("start game was success")
            }
        }
    }
    
    
    @IBAction func btnCrossAction(_ sender: UIButton) {
        AlertViewManager.showLoading()
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/leave", method: .post ,parameters: [
            "gameId": gameData["id"].int64!,
            "user" : [
                "id" : User.sharedInstance.id,
                "nickname" : User.sharedInstance.name
            ]
        ]) { [unowned self] success,json in
            var isSuccess = false
            if success {
                if let code = json["status"].int, let message = json["message"].string {
                    if code == 200 && message == "Left game successfully" {
                        isSuccess = true
                    }
                }
            }
            AlertViewManager.hideLoading()
            if isSuccess {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameViewControllerSegue", let gameViewController = segue.destination as? GameViewController {
            gameViewController.port = sender as! Int
            gameViewController.game = gameData
            for prize in gameData["prizes"].array! {
                let id = prize["id"].int64!
                let prizeObject = Prize(id: id, latitude: prize["latitude"].double!, longitude: prize["longitude"].double!, color: prize["color"].string!, points: prize["points"].int!, claimer: prize["claimer"].int64!)
                gameViewController.prizes[Int(id)] = prizeObject
            }
            
        }
    }
    
    deinit {
    }
}
