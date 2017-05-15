//
//  CreateGameViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 03/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD
import SwiftyJSON

protocol PlayerCountSelectedDelegate: class {
    func playerCountSelected(count : Int)
}

class CreateGameViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,PlayerCountSelectedDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tfGameName: UITextField!
    
    @IBOutlet weak var btnNumberOfPlayers: UIButton!
    
    var isFirst = true
    var isFirstAnimation = false
    var mkPointAnnotation : MKPointAnnotation?
    var radiusCircle : MKCircle!
    @IBOutlet weak var radiusSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CLLocationManager.locationServicesEnabled())
        {
            LocationManager.sharedInstance.manager.delegate = self
            LocationManager.sharedInstance.manager.desiredAccuracy = kCLLocationAccuracyBest
            LocationManager.sharedInstance.manager.requestAlwaysAuthorization()
            LocationManager.sharedInstance.manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.mapView.delegate = self
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CreateGameViewController.handleMapPress(_:)))
            longPressGestureRecognizer.minimumPressDuration = 2.0; //user needs to press for 2 seconds
            self.mapView.addGestureRecognizer(longPressGestureRecognizer)
        }
        self.tfGameName.placeholder = "\(User.sharedInstance.name!)'s Game"
        self.radiusSlider.setThumbImage(UIImage(named: "rectangle2"), for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if isFirst {
            isFirst = false
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = mapView.userLocation.coordinate;
            mapRegion.span.latitudeDelta = 0.005
            mapRegion.span.longitudeDelta = 0.005
            self.mapView.setRegion(mapRegion, animated: true)
            let userLocationView = mapView.view(for: userLocation)
            userLocationView?.canShowCallout = false
            isFirstAnimation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if isFirstAnimation {
            isFirstAnimation = false
            self.addCircle(touchPoint:CGPoint(x: mapView.frame.size.width/2.0, y:mapView.frame.size.height/2.0))
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.red
        circleView.lineWidth = 5
        circleView.fillColor = UIColor.red.withAlphaComponent(0.4)
        return circleView
    }
    
    
    @IBAction func btnCrossAction(_ sender: UIButton) {
        dismissAnimated()
    }
    
    private func dismissAnimated(_ completion : (() -> Swift.Void)? = nil) {
        LocationManager.sharedInstance.manager.delegate = nil
        self.dismiss(animated: true, completion: completion)
    }
    
    @IBAction func btnCreateAction(_ sender: UIButton) {
        guard self.checkForm() else {
           return
        }
        AlertViewManager.showLoading()
        var gameName : String
        if self.tfGameName.text != nil && self.tfGameName.text != "" {
            gameName = self.tfGameName.text!
        } else {
            gameName = self.tfGameName.placeholder!
        }
        
        let numberOfPlayers = self.btnNumberOfPlayers.title(for: .normal)!
        let lat = self.radiusCircle.coordinate.latitude
        let lon = self.radiusCircle.coordinate.longitude
        let radius = self.radiusCircle.radius
        print("\(gameName) #players: \(numberOfPlayers) lat: \(lat) lon: \(lon) radius: \(radius)")
        
        NetworkManager.sharedInstance.request(urlString: "\(httpEndpoint)/game/create", method: .post ,parameters: [
            "name": gameName,
            "host_id" : User.sharedInstance.id,
            "numberOfPlayers" : numberOfPlayers,
            "latitude" : lat,
            "longitude" : lon,
            "radius" : radius,
            "players" : [["id" : User.sharedInstance.id, "nickname" : User.sharedInstance.name]]
        ]) { [unowned self] success,json in
            var isSuccess = false
            if success {
                if let code = json["code"].int, let message = json["message"].string {
                    if code == 200 && message == "Created game succesfully" {
                        isSuccess = true
                    }
                }
            }
            
            if isSuccess {
                User.sharedInstance.currentGameId = json["game"]["id"].int64!
                if let nvc = self.presentingViewController as? UINavigationController {
                    self.dismissAnimated({
                        if let vc = nvc.topViewController as? LobbyListViewController {
                            vc.reloadTableView() {
                                vc.joinGame(json["game"])
                            }
                        }
                    })
                }
            } else {
                AlertViewManager.init(title: "Error!", message: "There has been a problem while creating the game.", okActionTitle: "OK").showOnViewController(self)
                AlertViewManager.hideLoading()
            }
        }
    }
    
    
    
    func sliderValueChanged(_ sender : UISlider) {
        print("slider value = %f", sender.value)
        let radius = sender.value * 400
        self.mapView.remove(radiusCircle)
        radiusCircle = MKCircle(center: radiusCircle.coordinate, radius: CLLocationDistance(radius))
        self.mapView.add(radiusCircle)
    }
    
    
    func checkForm() -> Bool {
        var isFormOk = true
        if radiusCircle == nil {
            AlertViewManager.init(title: "Error", message: "Please select an origin for the game", okActionTitle: "OK").showOnViewController(self)
            isFormOk = false
        }
        
        return isFormOk
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerNumberSelectorViewControllerSegue" {
            if let playerNumberSelectorViewController = segue.destination as? PlayerNumberSelectorViewController {
                playerNumberSelectorViewController.selectedRow = Int(self.btnNumberOfPlayers.title(for: .normal)!)! - 1
                playerNumberSelectorViewController.playerCountDelegate = self
            }
        }
    }
    
    //MARK: Gesture Recognizers
    
    func handleMapPress(_ gestureRecognizer : UIGestureRecognizer)
    {
        if gestureRecognizer.state != .began {
            return;
        }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        self.addCircle(touchPoint: touchPoint)
    }
    
    func addCircle(touchPoint : CGPoint) {
        let touchMapCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        if radiusCircle != nil {
            self.mapView.remove(radiusCircle)
        }
        radiusCircle = MKCircle(center: touchMapCoordinate, radius: 200)
        self.mapView.add(radiusCircle)
        self.radiusSlider.value = 0.5
        
        if mkPointAnnotation != nil {
            self.mapView.removeAnnotation(mkPointAnnotation!)
        } else {
            self.radiusSlider.addTarget(self, action:#selector(CreateGameViewController.sliderValueChanged(_:)), for: .valueChanged)
            self.radiusSlider.isUserInteractionEnabled = true
            self.radiusSlider.isEnabled = true
        }
        mkPointAnnotation = MKPointAnnotation()
        mkPointAnnotation!.coordinate = touchMapCoordinate
        self.mapView.addAnnotation(mkPointAnnotation!)
    }
    
    //MARK: Player Count Selected Delegate
    
    func playerCountSelected(count : Int) {
        self.btnNumberOfPlayers.setTitle(String(count), for: .normal)
    }
    
}
