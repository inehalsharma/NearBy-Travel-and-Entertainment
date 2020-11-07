//
//  PlacesSearchViewModel.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/14/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import AlamofireSwiftyJSON
import SwiftSpinner

let FAVORITE_LIST = UserDefaults.standard
func IS_PLACE_ID(id:String) -> Bool {
    let prefix = id.prefix(4)
    return prefix == "ChIJ"
}

class PlacesSearchModel{
    var keyword = ""
    var category = "defaults"
    var distance:Double = 10
    var from = ""
    var lat:Double = -1
    var lng:Double = -1
    var vc:PlacesSearchViewController
    var deformatter:DateFormatter
    
    init(vc:PlacesSearchViewController){
        self.vc = vc
        deformatter = DateFormatter()
        deformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
    }
    
    func saveValidateForm(key:String, cat:String, dis:String, f:String) -> String {
        keyword = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyword == "" {
            return "keyword"
        }
        category = cat
        let dis_string = dis.trimmingCharacters(in: .whitespacesAndNewlines)
        var dis_int: Double? = nil
        if dis_string == ""{
            distance = 10;
        }else{
            dis_int = Double(dis_string)
            if dis_int == nil || dis_int! < 0 {
                return "distance"
            }
            distance = dis_int!
        }
        from = f;
        return ""
    }
    
    
    var currentLocation: CLLocation!
    
    func submitForm(){
        // get lat lng from json from server request
        if from == "Your location" {
            if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                currentLocation = LOCAL_MANAGER.location
                lat = currentLocation.coordinate.latitude
                lng = currentLocation.coordinate.longitude
                searchPlaces()
            }else{
                self.vc.view.showToast("Need Location Authorization!", position: .bottom, popTime: 5, dismissOnTap: false)
                return
            }
        }else{
            var reqUrl:String = "http://cs571webhw8-env.us-west-1.elasticbeanstalk.com/specifiedLatlng?"
            let data:String = "data={\"location\":\"\(from)\"}"
            reqUrl += data
            print(reqUrl)
            let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            Alamofire.request(encodedUrl!).responseSwiftyJSON{ response in
                //debugPrint(response)
                let json = response.result.value
                let isSuccess = response.result.isSuccess
                //print("json: \(String(describing: json))")
                if (isSuccess && (json != nil)) {
                    self.lat = json!["lat"].doubleValue
                    self.lng = json!["lng"].doubleValue
                    self.searchPlaces()
                }else{
                    self.vc.view.showToast("Fail to get lat lng JSON, Lat Lng of specified location are not assigned!", position: .bottom, popTime: 5, dismissOnTap: false)
                    return
                }
            }
        }
    }
    
    func searchPlaces() {
        SwiftSpinner.show("Searching...")
        var reqUrl:String = "http://cs571webhw8-env.us-west-1.elasticbeanstalk.com/nearbySearch?"
        let data:String = "data={\"keyword\":\"\(keyword)\",\"category\":\"\(category)\",\"distance\":\"\(distance)\",\"fromLat\":\"\(lat)\",\"fromLng\":\"\(lng)\"}"
        reqUrl += data
        print(reqUrl)
        let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var placeResults = PlaceResults(hasResult: false)
        Alamofire.request(encodedUrl!).responseSwiftyJSON{ response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //print("Success and got JSON")
                let status = json!["status"].string
                if status == "OK"{
                    // store page data to var placeResults
                    placeResults = PlaceResults(hasResult: true);
                    let next_page_token = json!["next_page_token"].exists() ? json!["next_page_token"].string : ""
                    placeResults.nextPageToken = next_page_token!
                    let results = json!["results"].array
                    for element in results! {
                        let resultData = TableCellData(iconUrl: element["icon"].string!, name: element["name"].string!, vicinity: element["vicinity"].string!, placeId: element["place_id"].string!)
                        placeResults.tableData.append(resultData)
                    }
                }else{
                    // status == "ZERO_RESULTS"
                    // self.placeResults.tableData.count = 0
                }
                self.vc.placeResultData = placeResults
                self.vc.performSegue(withIdentifier: "showSearchResults", sender: self.vc)
            }else{
                self.vc.view.showToast("Fail to get JSON, no results.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
            
            SwiftSpinner.hide()
        }
        
    }
    
    
    func requestPlaceDetail(placeId:String) {
        //print("requestPlaceDetail(placeId:String)")
        SwiftSpinner.show("Loading place details...")
        var reqUrl:String = "http://cs571webhw8-env.us-west-1.elasticbeanstalk.com/placeDetail?"
        let data:String = "data={\"place_id\":\"\(placeId)\"}"
        reqUrl += data
        print(reqUrl)
        
        let placeDetailData = PlaceDetail()
        
        let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedUrl!).responseSwiftyJSON{ response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //print("Success and got JSON")
                let status = json!["status"].string
                if status == "OK"{
                    let result = json!["result"]
                    placeDetailData.name = result["name"].exists() ? result["name"].string! : ""
                    placeDetailData.placeId = result["place_id"].exists() ? result["place_id"].string! : ""
                    placeDetailData.vicinity = result["vicinity"].exists() ? result["vicinity"].string! : ""
                    placeDetailData.iconUrl = result["icon"].exists() ? result["icon"].string! : ""
                    
                    //Info:
                    placeDetailData.info.address = result["formatted_address"].exists() ? result["formatted_address"].string! : ""
                    placeDetailData.info.phoneNumber = result["international_phone_number"].exists() ? result["international_phone_number"].string! : ""
                    placeDetailData.info.priceLevel = result["price_level"].exists() ? result["price_level"].intValue : 0
                    placeDetailData.info.rating = result["rating"].exists() ? result["rating"].doubleValue : 0
                    placeDetailData.info.website = result["website"].exists() ? result["website"].string! : ""
                    placeDetailData.info.googlePage = result["url"].exists() ? result["url"].string! : ""
                    
                    //Photos:
                    let photos = result["photos"].exists() ? result["photos"].array : []
                    for ele in photos! {
                        let p = Photo()
                        p.photoRef = ele["photo_reference"].exists() ? ele["photo_reference"].string! : ""
                        p.height = ele["height"].exists() ? ele["height"].intValue: 1
                        p.width = ele["width"].exists() ? ele["width"].intValue: 1
                        placeDetailData.photos.append(p)
                    }
                    
                    //Map
                    placeDetailData.map.lat = result["geometry"]["location"]["lat"].doubleValue
                    placeDetailData.map.lng = result["geometry"]["location"]["lng"].doubleValue
                    
                    //Reviews
                    //Google
                    let gReview = result["reviews"].exists() ? result["reviews"].array : []
                    for ele in gReview! {
                        let r = Review()
                        r.authorName = ele["author_name"].exists() ? ele["author_name"].string! : ""
                        r.authorUrl = ele["author_url"].exists() ? ele["author_url"].string! : ""
                        r.profilePhotoUrl = ele["profile_photo_url"].exists() ? ele["profile_photo_url"].string! : ""
                        r.rating = ele["rating"].exists() ? ele["rating"].doubleValue : 0
                        let t = ele["time"].exists() ? ele["time"].intValue : 0
                        let d = Date(timeIntervalSince1970: TimeInterval(t))
                        r.time = self.deformatter.string(from: d)
                        r.text = ele["text"].exists() ? ele["text"].string! : ""
                        placeDetailData.reviews.googleReviews.append(r)
                    }
                    self.requestYelpBest(pd: placeDetailData)
                }else{
                    // status == "??"
                    // it seems not possible
                }
            }else{
                self.vc.view.showToast("Fail to get JSON, no place details.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
            //SwiftSpinner.hide()
        }
    }
    
    func getAddress(addr:String, at:Int) -> String {
        var ret = addr.components(separatedBy: ", ")
        return ret[at]
    }
    
    func getCity(vic:String) -> String {
        var ret = vic.components(separatedBy: ", ")
        return ret[ret.count - 1]
    }
    
    func getState(addr:String) -> String {
        var ret = addr.components(separatedBy: ", ")
        ret = ret[ret.count - 2].components(separatedBy: " ")
        return ret[0]
    }
    
    func requestYelpBest(pd: PlaceDetail) {
        //print("requestYelpBest(pd: PlaceDetail")
        let name = pd.name
        let add1 = getAddress(addr: pd.info.address, at: 0)
        let add2 = getAddress(addr: pd.info.address, at: 1)
        let city = getCity(vic: pd.vicinity)
        let state = getState(addr: pd.info.address)
        var reqUrl:String = "http://cs571webhw8-env.us-west-1.elasticbeanstalk.com/yelpBMatch?"
        let data:String = "data={\"name\":\"\(name)\",\"address1\":\"\(add1)\",\"address2\":\"\(add2)\",\"city\":\"\(city)\",\"state\":\"\(state)\"}"
        reqUrl += data
        print(reqUrl)
        let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedUrl!).responseString{ response in
            let isSuccess = response.result.isSuccess
            if isSuccess {
                let yelpId:String = response.result.value!
                //print("yelpId: \(yelpId)")
                if yelpId != "-0" {
                    self.requestYelpReviews(pd: pd, yelpId: yelpId)
                }else{
                    //Data save DONE!
                    self.vc.pdData = pd
                    self.vc.performSegue(withIdentifier: "showFavoriteDetail", sender: self.vc)
                    SwiftSpinner.hide() //get place detail finished
                }
            }else{
                print("Fail to get yelp id")
                SwiftSpinner.hide() //get place detail finished
            }
        }
    }
    
    func requestYelpReviews(pd: PlaceDetail, yelpId:String) {
        //("requestYelpReviews(pd: PlaceDetail, yelpId:String)")
        var reqUrl:String = "http://cs571webhw8-env.us-west-1.elasticbeanstalk.com/yelpBReview?"
        let data:String = "data={\"id\":\"\(yelpId)\"}"
        reqUrl += data
        print(reqUrl)
        let encodedUrl = reqUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedUrl!).responseSwiftyJSON{ response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)){
                let reviews = json!["reviews"].exists() ? json!["reviews"].array : []
                for ele in reviews!{
                    let r = Review()
                    r.authorName = ele["user"].exists() ? ele["user"]["name"].exists() ? ele["user"]["name"].string! : "" : ""
                    r.profilePhotoUrl = ele["user"].exists() ? ele["user"]["image_url"].exists() ? ele["user"]["image_url"].string! : "" : ""
                    r.authorUrl = ele["url"].exists() ? ele["url"].string! : ""
                    r.rating = ele["rating"].exists() ? ele["rating"].doubleValue : 0
                    r.time = ele["time_created"].exists() ? ele["time_created"].string! : ""
                    r.text = ele["text"].exists() ? ele["text"].string! : ""
                    pd.reviews.yelpReviews.append(r)
                    
                }
                // Data save DONE!
                self.vc.pdData = pd
                self.vc.performSegue(withIdentifier: "showFavoriteDetail", sender: self.vc)
                
            }else{
                print("Fail to get JSON, Yelp reviews are not assigned!")
            }
            SwiftSpinner.hide()
        }
        
    }
    
    
}
