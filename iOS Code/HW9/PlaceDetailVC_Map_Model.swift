//
//  PlaceDetailVC_Map_Model.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/22/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import CoreLocation
import EasyToast
import Alamofire
import AlamofireSwiftyJSON
import EasyToast

class PlaceDetailVC_Map_Model{
    var vc:PlaceDetailVC_Map
    init(vc:PlaceDetailVC_Map) {
        self.vc = vc
        
    }
    
    func requestDirections(from:String, toLat:Double, toLng:Double, mode:String){
        let f = from.replacingOccurrences(of: " ", with: "+")
        var reqUrl:String = "https://maps.googleapis.com/maps/api/directions/json?"
        let data:String = "origin=\(f)&destination=\(String(toLat)),\(String(toLng))&mode=\(mode)&key=AIzaSyCOUwUIo0akVrwtQfKg4U1JHOp0-pEcN2s"
        reqUrl += data
        print(reqUrl)
        let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedUrl!).responseSwiftyJSON{ response in
            //debugPrint(response)
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            //print("json: \(String(describing: json))")
            if (isSuccess && (json != nil)) {
                if(json!["status"] == "OK"){
                    let routes = json!["routes"].array
                    let r = routes![0] //always get first route
                    let NE = LatLng(lat: r["bounds"]["northeast"]["lat"].doubleValue, lng: r["bounds"]["northeast"]["lng"].doubleValue)
                    let SW = LatLng(lat: r["bounds"]["southwest"]["lat"].doubleValue, lng: r["bounds"]["southwest"]["lng"].doubleValue)
                    let cLat = (NE.lat + SW.lat) / 2
                    let cLng = (NE.lng + SW.lng) / 2
                    let dData = Directions(camera: LatLng(lat:cLat, lng:cLng))
                    dData.bestZ = self.getBestZ(ne: NE, sw: SW)
                    let legs = r["legs"].array
                    let leg = legs![0]
                    dData.fromLat = leg["start_location"]["lat"].doubleValue
                    dData.fromLng = leg["start_location"]["lng"].doubleValue
                    dData.toLat = leg["end_location"]["lat"].doubleValue
                    dData.toLng = leg["end_location"]["lng"].doubleValue
                    let stepsArray = leg["steps"].array
                    for ele in stepsArray! {
                        let pointsPath = ele["polyline"]["points"].string!
                        dData.encodedPaths.append(pointsPath)
                    }
                    self.vc.directionsData = dData
                    self.vc.passDirectionDataToMap()
                    self.vc.drawDirections()
                }else{
                    //ZERO_RESULTS
                    self.vc.view.showToast("No Directions can be shown!", position: .bottom, popTime: 2, dismissOnTap: false)
                }
                
            }else{
                print("Fail to get Directions JSON QQ")
            }
        }
    }
    
    func getBestZ(ne: LatLng, sw:LatLng) -> Float {
        // Santa Monica ro USC
        let sAngularDis:Float = 621
        let sDis = 0.2078
        let sZoom:Float = 11
        
        let fH = self.vc.mapVC.view.frame.height
        let fW = self.vc.mapVC.view.frame.width
        let a = (fW*fW + fH*fH).squareRoot()
        let aDis = Float(a)
        let rateFrame = aDis/sAngularDis
        
        let dx = ne.lng - sw.lng
        let dy = ne.lat - sw.lat
        let dis = (dx*dx + dy*dy).squareRoot()
        let rateLength = dis/sDis
        
        //print("- rate frame: \(Float(log(rateFrame) / log(2)))")
        //print("- rate length: \(Float(log(rateLength) / log(2)))")
        //print("Besy Zoom: \(sZoom - Float(log(rateFrame) / log(2)) - Float(log(rateLength) / log(2)))")
        return sZoom + Float(log(rateFrame) / log(2)) - Float(log(rateLength) / log(2))
    }
    
    var currentLocation: CLLocation!
    func getCurrentLatLng() -> String {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = LOCAL_MANAGER.location
            self.vc.curLat = currentLocation.coordinate.latitude
            self.vc.curLng = currentLocation.coordinate.longitude
            return String(self.vc.curLat) + "," + String(self.vc.curLng)
        }else{
            self.vc.view.showToast("Need Location Authorization!", position: .bottom, popTime: 5, dismissOnTap: false)
            return ""
        }
    }
    
}

class Directions{
    var camera:LatLng
    var encodedPaths = [String]()
    var fromLat:Double = -1
    var fromLng:Double = -1
    var toLat:Double = -1
    var toLng:Double = -1
    var bestZ:Float = 1
    init(camera: LatLng) {
        self.camera = camera
    }
}

class LatLng{
    let lat:Double
    let lng:Double
    init(lat:Double, lng:Double) {
        self.lat = lat
        self.lng = lng
    }
}
