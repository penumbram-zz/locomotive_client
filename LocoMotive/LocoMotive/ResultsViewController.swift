//
//  ResultsViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 11/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataSource : [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/leave", method: .post ,parameters: [
            "gameId": User.sharedInstance.currentGameId,
            "user" : [
                "id" : User.sharedInstance.id,
                "nickname" : User.sharedInstance.name
            ]
        ]) { _,_ in}
        User.sharedInstance.currentGameId = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertViewManager.hideLoading()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resultTableViewCell") as? ResultsTableViewCell
        if (cell == nil)
        {
            cell = ResultsTableViewCell(style: .default, reuseIdentifier: "resultTableViewCell")
        }
        cell!.lblMain?.text = dataSource[indexPath.row]["user"]["nickname"].string
        cell!.lblSecond?.text = "\(dataSource[indexPath.row]["points"].int!)"
        
        return cell!
    }
    
    @IBAction func btnResultsAction(_ sender: UIButton) {
        let navController = self.navigationController
        if navController != nil {
            _ = navController?.popToRootViewController(animated: true)
        }
    }
    
//MARK : header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(section == 0) {
            let color = UIColor.init(red: 67.0/255.0, green: 65.0/255.0, blue: 67.0/255.0, alpha: 1.0)
            let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
            
            let label1 = UILabel()
            label1.text = "Player"
            label1.font = UIFont.init(name: "Futura-Bold", size: label1.font.pointSize)
            label1.textColor = color
            
            let label2   = UILabel()
            label2.text = "Score"
            label2.font = UIFont.init(name: "Futura-Bold", size: label2.font.pointSize)
            label2.textColor = color
            
            label1.translatesAutoresizingMaskIntoConstraints = false
            label2.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["label1": label1,"label2":label2,"view": view]
            view.addSubview(label1)
            view.addSubview(label2)
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label1]-60-[label2]-120-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            let verticalLayoutContraint = NSLayoutConstraint(item: label1, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            return view
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
