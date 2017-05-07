//
//  NetworkManager.swift
//  LocoMotive
//
//  Created by Tolga Caner on 01/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    var afManager : SessionManager!
    init() {
        let configuration = URLSessionConfiguration.default
        var headers : [AnyHashable : Any] = Alamofire.SessionManager.defaultHTTPHeaders
        headers.updateValue("application/json, application/x-www-form-urlencoded, */*", forKey: "Accept")
        headers.updateValue("application/json", forKey: "Content-Type")
        configuration.httpAdditionalHeaders = headers
        afManager = Alamofire.SessionManager(configuration: configuration)
        //Alamofire.Manager.sharedInstance.session.configuration
        //    .HTTPAdditionalHeaders?.updateValue("application/json",
        //                                        forKey: "Accept")
    }
    
    typealias Completion = (_ succeeded: Bool, _ json: JSON) -> Void
    
    func request(urlString: String, method : HTTPMethod, parameters: Parameters?, completion : @escaping Completion) {
        afManager.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization

            if let resJson = response.result.value {
                var jsonObject : JSON
                print("JSON: \(resJson)")
                if resJson is Array<Any> {
                    jsonObject = JSON(array: resJson)
                } else {
                    jsonObject = JSON(dictionary: resJson)
                }
                
                completion(true, jsonObject)
            }
        }
    }
    
    
}
