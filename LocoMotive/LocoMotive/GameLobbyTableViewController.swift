//
//  GameLobbyTableViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 06/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SwiftyJSON

class GameLobbyTableViewController: UITableViewController {
    
    var dataSource : [JSON] = []
    var isHost = false
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + ((isHost) ? 0 : 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "gameLobbyTableViewCell")
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "gameLobbyTableViewCell")
        }
        if indexPath.row == dataSource.count && !isHost {
            cell!.textLabel?.text = User.sharedInstance.name
        } else {
            let item = self.dataSource[indexPath.row]
            cell!.textLabel?.text = item["nickname"].string!
        }

        return cell!
    }
    
}
