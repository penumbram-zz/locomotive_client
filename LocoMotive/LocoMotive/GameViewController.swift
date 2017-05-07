//
//  GameViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 01/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SocketRocket

class GameViewController: UIViewController, SRWebSocketDelegate {
    
    var webRocket : SRWebSocket!
    var port : Int = 8884

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "\(endpoint)\(port)"
        let urlRequest = URLRequest.init(url: URL.init(string: urlString)!)
        self.webRocket = SRWebSocket.init(urlRequest: urlRequest)
        self.webRocket.delegate = self
        self.webRocket.open()
    }
    
    @IBAction func btnCrossAction(_ sender: UIButton) {
        dismissAnimated()
    }
    
    func dismissAnimated() {
        self.webRocket.close()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDummyAction(_ sender: UIButton) {
        print("btn dummy action")
        let dict = ["id": User.sharedInstance.id, "name": User.sharedInstance.name, "action": ""] as [String : Any]
        do {
            let jsonString = try GameViewController.jsonStringWithJSONObject(jsonObject: dict as AnyObject)
            self.webRocket.send(jsonString)
        } catch {
            print(error)
        }
        
    }
    
    class func jsonStringWithJSONObject(jsonObject: AnyObject) throws -> String? {
        let data: Data? = try! JSONSerialization.data(withJSONObject: jsonObject, options:JSONSerialization.WritingOptions(rawValue: 0)) as Data?
        
        var jsonStr: String?
        if data != nil {
            jsonStr = String(data: data! as Data, encoding: String.Encoding.utf8)
        }
        
        return jsonStr
    }
    
// MARK: SRWebSocketDelegate functions
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let str = message as! String
        print(str)
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("webSocketDidOpen")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        print("didFailWithError")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("didCloseWithCode reason: \(reason)")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        print("didReceivePong")
    }
    
    // Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
    func webSocketShouldConvertTextFrame(toString webSocket: SRWebSocket!) -> Bool {
        return true
    }
    
}
