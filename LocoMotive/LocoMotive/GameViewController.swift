//
//  GameViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 01/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import SocketRocket
import CoreLocation
import MapKit
import SwiftyJSON
import SVProgressHUD

let prizeRadius : CLLocationDistance = 5.0

class GameViewController: UIViewController, SRWebSocketDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var webRocket : SRWebSocket!
    var port : Int = 8884
    var game : JSON!
    var prizes : [Int : Prize] = [:]
    var prizeCircles : [Int64 : MKCircle] = [:]
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var isFirst = true
    var isFirstAnimation = false
    var isFirstAnimationComplete = false
    var score : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "\(endpoint)\(port)"
        let urlRequest = URLRequest.init(url: URL.init(string: urlString)!)
        self.webRocket = SRWebSocket.init(urlRequest: urlRequest)
        self.webRocket.delegate = self
        self.webRocket.open()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            LocationManager.sharedInstance.manager.delegate = self
            LocationManager.sharedInstance.manager.desiredAccuracy = kCLLocationAccuracyBest
            LocationManager.sharedInstance.manager.requestAlwaysAuthorization()
            LocationManager.sharedInstance.manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.mapView.delegate = self
        }
        
    }
    
    @IBAction func btnCrossAction(_ sender: UIButton) {
        dismissAnimated()
    }
    
    func dismissAnimated() {
        LocationManager.sharedInstance.manager.delegate = nil
        self.webRocket.close()
        User.sharedInstance.currentGameId = nil
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func sendLocation(_ coordinate : CLLocationCoordinate2D) {
        let message = SocketMessage().position(latlon: ["latitude" : coordinate.latitude, "longitude" : coordinate.longitude]).dict //.action(action: "position")// .dict
        do {
            let jsonString = try Util.jsonStringWithJSONObject(jsonObject: message as AnyObject)
            self.webRocket.send(jsonString)
        } catch {
            print(error)
        }
    }
    
    
//MARK: MapView
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.last != nil && isFirstAnimationComplete else {
            return
        }
        
        let newLocation = locations.last!
        var oldLocation : CLLocation?
        if locations.count > 1 {
            oldLocation = locations[locations.count - 2]
        }
        /*
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = newLocation.coordinate;
        mapRegion.span.latitudeDelta = mapView.region.span.latitudeDelta
        mapRegion.span.longitudeDelta = mapView.region.span.longitudeDelta
        self.mapView.setRegion(mapRegion, animated: true)
        */
        //send new location to server
        sendLocation(newLocation.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if isFirst {
            isFirst = false
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = mapView.userLocation.coordinate;
            mapRegion.span.latitudeDelta = 0.0005
            mapRegion.span.longitudeDelta = 0.0005
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.mapView.setRegion(mapRegion, animated: true)
            }
            
            
            let userLocationView = mapView.view(for: userLocation)
            userLocationView?.canShowCallout = false
            isFirstAnimation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if isFirstAnimation {
            isFirstAnimation = false
            for prize in self.prizes {
                self.addPrize(id: prize.value.id,coordinate: CLLocationCoordinate2D(latitude: prize.value.latitude, longitude: prize.value.longitude))
            }
            isFirstAnimationComplete = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.blue
        circleView.lineWidth = 2
        circleView.fillColor = UIColor.blue.withAlphaComponent(0.4)
        return circleView
    }
    
    func addPrize(id: Int64,coordinate : CLLocationCoordinate2D) {
        let prize = MKCircle(center: coordinate, radius: prizeRadius)
        self.mapView.add(prize)
        self.prizeCircles[id] = prize
    }
    
// MARK: SRWebSocketDelegate functions
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let str = message as! String
        let dict = Util.convertToDictionary(text: str)
        if (dict != nil) {
            refreshPrizes(newDict: dict!["prizes"] as! [Any],dict: self.prizes)
        }
        
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
    
    func refreshPrizes(newDict : [Any], dict : [Int : Prize]) {
        var countClaimed = 0
        for prize in newDict {
            print(prize)
            if let json = prize as? [String : Any] {
                let id = json["id"] as! Int64
                let pPrize = dict[Int(id)]!
                let newClaimer = json["claimer"] as! Int64
                if newClaimer != pPrize.claimer {
                    pPrize.claimer = newClaimer
                    print("a prize has a new claimer")
                    let circle = self.prizeCircles[id]
                    self.mapView.remove(circle!)
                    let score = json["points"] as! Int
                    if newClaimer == User.sharedInstance.id {
                        updateScore(add: score)
                    }
                }
                if pPrize.claimer != -1 {
                    countClaimed += 1
                }
            }
        }
        if countClaimed == newDict.count {
            LocationManager.sharedInstance.manager.delegate = nil
            self.webRocket.close()
            SVProgressHUD.show(withStatus: "GOOD GAME! \n\n PLEASE WAIT FOR RESULTS...")
            NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/result", method: .post ,parameters: [
                "gameId": User.sharedInstance.currentGameId,
                "user" : [
                    "id" : User.sharedInstance.id,
                    "nickname" : User.sharedInstance.name
                ]
            ]) { [unowned self] success,json in
                if success {
                    if json.array != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                            self?.performSegue(withIdentifier: "resultsSegue", sender: json.array)
                        }
                    }
                }
            }
        }
    }
    
    func updateScore(add : Int) {
        score += add
        self.lblScore.text = ("Score: \(score)")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultsSegue" {
            if let dest = segue.destination as? ResultsViewController, sender != nil {
                dest.dataSource = sender! as! [JSON]
            }
        }
    }
    
    
}
