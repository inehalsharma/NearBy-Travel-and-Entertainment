//
//  PlaceDetailTabbarC.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/21/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import EasyToast

class PlaceDetailTabbarC : UITabBarController{
    
    var tweetBtn:UIBarButtonItem? = nil
    var favoriteBtn:UIBarButtonItem? = nil
    
    var placeDetail = PlaceDetail()
    
    var infoView = PlaceDetailVC_Info()
    var photosView = PlaceDetailVC_Photos()
    var mapView = PlaceDetailVC_Map()
    var reviewView = PlaceDetailVC_Reviews()
    
    override func viewDidLoad() {
        //print("placeDetail.name:  \(placeDetail.name)")
        infoView = self.childViewControllers[0] as! PlaceDetailVC_Info
        photosView = self.childViewControllers[1] as! PlaceDetailVC_Photos
        mapView = self.childViewControllers[2] as! PlaceDetailVC_Map
        reviewView = self.childViewControllers[3] as! PlaceDetailVC_Reviews
        
        // set navgation bar
        navigationItem.title = placeDetail.name
        tweetBtn = UIBarButtonItem(image: UIImage(named: "forward-arrow"), style: .plain, target: self, action: #selector(tweet))
        if FAVORITE_LIST.array(forKey: placeDetail.placeId) == nil{
            favoriteBtn = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(switchFavorite))
        }else{
            favoriteBtn = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(switchFavorite))
        }
        navigationItem.rightBarButtonItems = [favoriteBtn, tweetBtn] as? [UIBarButtonItem]
        
        setUpInfo()
        setUpPhotos()
        setUpMap()
        setUpReviews()
    }
    
    @objc func tweet() {
        print("tweet()")
        var urlString = "https://twitter.com/intent/tweet?"
        let data = "text=Check out \(placeDetail.name) located at \(placeDetail.info.address)\nWebsite: \(placeDetail.info.website)"
        urlString += data
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: encodedUrl!) {
            UIApplication.shared.open(url, options: [:])
        }else{ print("Fail to open review web page!") }
    }
    
    @objc func switchFavorite() {
        if FAVORITE_LIST.array(forKey: placeDetail.placeId) == nil{
            favoriteBtn?.image = UIImage(named: "favorite-filled")
            let url = placeDetail.iconUrl
            let n = placeDetail.name
            let v = placeDetail.vicinity
            let id = placeDetail.placeId
            FAVORITE_LIST.set([url, n, v, id], forKey: id)
            changePrevVCTableView()
            self.view.showToast("\(placeDetail.name) was added to favorites", position: .bottom, popTime: 2, dismissOnTap: false)
        }else{
            favoriteBtn?.image = UIImage(named: "favorite-empty")
            FAVORITE_LIST.removeObject(forKey: placeDetail.placeId)
            changePrevVCTableView()
            self.view.showToast("\(placeDetail.name) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: false)
        }
    }
    
    func changePrevVCTableView() {
        let prevVC = self.navigationController?.previousViewController()
        if let placeSearchVC = prevVC as? PlacesSearchViewController {
            placeSearchVC.favoriteIdList = placeSearchVC.getFavoriteList()
            placeSearchVC.favoriteTV.reloadData()
        }
        if let searchReultsVC = prevVC as? SearchResultsVC {
            searchReultsVC.placeProfileTV.reloadData()
        }
    }
    
    func setUpInfo() {
        infoView.address_in = placeDetail.info.address
        infoView.phoneNumber_in = placeDetail.info.phoneNumber
        infoView.priceLevel_in = placeDetail.info.priceLevel
        infoView.ratingStar_in = placeDetail.info.rating
        infoView.website_in = placeDetail.info.website
        infoView.googlePage_in = placeDetail.info.googlePage
    }
    
    func setUpPhotos() {
        photosView.placeId = placeDetail.placeId
        photosView.photos = placeDetail.photos
    }
    
    func setUpMap() {
        mapView.lat = placeDetail.map.lat
        mapView.lng = placeDetail.map.lng
    }
    func setUpReviews() {
        reviewView.googleReviews = placeDetail.reviews.googleReviews
        reviewView.yelpReviews = placeDetail.reviews.yelpReviews
    }
    
    
}
