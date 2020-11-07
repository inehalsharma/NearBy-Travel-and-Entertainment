//
//  PlaceDetail.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/20/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation

class PlaceDetail{
    var name = ""
    var placeId = ""
    var vicinity = ""
    var iconUrl = ""
    
    var info:Info
    var photos = [Photo]()
    var map:Map
    var reviews:Reviews
    
    init(){
        info = Info()
        photos = [Photo]()
        map = Map()
        reviews = Reviews()
    }
}

class Info{
    var address = ""
    var phoneNumber = ""
    var priceLevel:Int = -1
    var rating:Double = -1
    var website = ""
    var googlePage = ""
}

class Photo{
    var photoRef = ""
    var height = -1
    var width = -1
}

class Map{
    var lat:Double = -1
    var lng:Double = -1
}

class Reviews{
    var googleReviews = [Review]()
    var yelpReviews = [Review]()
}

class Review{
    var authorName = ""
    var profilePhotoUrl = ""
    
    var authorUrl = "" // for Tap
    
    var rating:Double = -1
    var time = ""
    var text = ""
}

