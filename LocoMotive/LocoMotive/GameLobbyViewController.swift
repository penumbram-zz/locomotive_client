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
    
    var timer: DispatchSourceTimer?
    
    private func startTimer() {
        let queue = DispatchQueue(label: "com.caner.tolga.LocoMotive.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(5), leeway: .seconds(1))
        
        timer?.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            print(Date())
            
            NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/status", method: .post ,parameters: [
                "gameId": User.sharedInstance.currentGameId,
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
                    let startTime = json["game"]["startTime"]
                    let portValue = json["game"]["port"]
                    if startTime != JSON.null && startTime != "" && portValue != JSON.null {
                        print(startTime)
                        let dateString = startTime.string!
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        
                        let date = dateFormatter.date(from: dateString)?.addingTimeInterval(3 * 60 * 60)
                        print(date!)
                        self?.stopTimer()
                        let dif = date!.timeIntervalSince(Date())
                        
                        /*
                        if dif > 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + dif - 5) { [weak self] in
                                self?.performSegue(withIdentifier: "gameViewControllerSegue", sender: portValue.int!)
                            }
                        } else {
                            self?.performSegue(withIdentifier: "gameViewControllerSegue", sender: portValue.int!)
                        }
                        */
                        self?.performSegue(withIdentifier: "gameViewControllerSegue", sender: portValue.int!)
                        
                    }

                } else {
                
                }
            }
            
        }
        
        timer?.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
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
    
    
    @IBAction func btnStartGameAction(_ sender: UIButton) {
        let startString = Util.secondsFromNow(30)
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/start", method: .post ,parameters: [
            "gameId": User.sharedInstance.currentGameId,
            "user" : [
                "id" : User.sharedInstance.id,
                "nickname" : User.sharedInstance.name
            ],
            "startDate" : startString
        ]) { [weak self] success,json in
            var isSuccess = false
            if success {
                if let code = json["code"].int, let message = json["message"].string {
                    if code == 200 && message == "Game Starting" {
                        isSuccess = true
                    }
                }
            }
            
            if isSuccess {
            } else {
                
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
            
            if isSuccess {
                self.dismiss(animated: true, completion: nil)
            }
            AlertViewManager.hideLoading()
        }
    
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameViewControllerSegue", let gameViewController = segue.destination as? GameViewController {
            gameViewController.port = sender as! Int;
        }
    }
}
