//
//  LobbyListViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 02/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class LobbyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellReuseIdentifier = "lobbyListTableViewCellReuseId"
    var dataSource : [JSON] = []
    var enterGame : Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadTableView()
        
        Timer.sharedInstance.timer2.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            self?.reloadTableViewWithoutLoading()
            
        }
        
        Timer.sharedInstance.timer2.resume()
        
    }
    
    private func reloadTableViewWithoutLoading() {
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game", method: .get ,parameters: nil) { [unowned self] success,json in
            if success {
                self.dataSource.removeAll()
                if json.array != nil {
                    self.dataSource = json.array!.reversed()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Timer.sharedInstance.timer2.suspend()
    }
    
    public func reloadTableView(_ completion: (()->())? = nil) {
        AlertViewManager.showLoading()
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game", method: .get ,parameters: nil) { [unowned self] success,json in
            if success {
                self.dataSource.removeAll()
                if json.array != nil {
                    self.dataSource = json.array!.reversed()
                    self.tableView.reloadData() {
                        if completion != nil {
                            completion!()
                        }
                    }
                }
            }
            AlertViewManager.hideLoading()
        }
    }
    
    @IBAction func btnCreateGameAction(_ sender: UIButton) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? LobbyListTableViewCell
        if (cell == nil)
        {
            cell = LobbyListTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        }
        let item = self.dataSource[indexPath.row]
        cell!.lblMain.text = item["name"].string!
        cell!.lblDesc.text = self.playerNames(item["players"].array)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.dataSource[indexPath.row]
        if item["host_id"].int64 == User.sharedInstance.id {
            AlertViewManager.init(title: "Can't join game!", message: "You are the host of this game", okActionTitle: "OK").showOnViewController(self)
            return
        }
        self.joinGame(item)
        
    }
    
    func joinGame(_ item : JSON) {
        AlertViewManager.showLoading()
        if item["host_id"].int64 == User.sharedInstance.id {
            pushGameLobby(item)
            //   self.performSegue(withIdentifier: "gameLobbySegue", sender: item)
            AlertViewManager.hideLoading()
        } else {
            NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/join", method: .post ,parameters: [
                "gameId": item["id"].int64!,
                "user" : [
                    "id" : User.sharedInstance.id,
                    "nickname" : User.sharedInstance.name
                ]
            ]) { [unowned self] success,json in
                var isSuccess = false
                if success {
                    if let code = json["status"].int, let message = json["message"].string {
                        if code == 200 && message == "Joined game successfully" {
                            isSuccess = true
                            User.sharedInstance.currentGameId = item["id"].int64!
                        }
                    }
                }
                
                if isSuccess {
                    self.pushGameLobby(item)
                }
                AlertViewManager.hideLoading()
            }
        }
        
    }
    
    func pushGameLobby(_ item : Any) {
        /*
        let transition = CATransition.init()
        transition.duration = 0.3;
        transition.type = kCATransitionFromBottom;
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        */
        self.performSegue(withIdentifier: "gameLobbySegue", sender: item)
    }
    
    func playerNames(_ players : [JSON]?) -> String {
        var result = ""
        if players != nil {
            for player in players! {
                result.append("\(player["nickname"].string!), ")
            }
            if result.characters.count >= 2 {
                result = result.substring(to: result.index(result.endIndex, offsetBy: -2))
            }
        }
        return result
    }
    
    //MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameLobbySegue" {
            if let gameLobbyViewController = segue.destination as? GameLobbyViewController {
                let json = sender as! JSON!
                gameLobbyViewController.gameData = json
                
                //TODO: game data gameLobbyViewController.
            }
        }
    }
    
}
