//
//  PlaceDetailVC_Photos_Model.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/21/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import GooglePlaces
import EasyToast

class PlaceDetailVC_Photos_Model {
    var vc:PlaceDetailVC_Photos
    init(vc:PlaceDetailVC_Photos) {
        self.vc = vc
    }
    
    func loadPhotoForPlace(to: UIImageView, placeID: String, index: Int) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let photo = photos?.results[index] {
                    self.loadImageForMetadata(photoMetadata: photo, imgView: to)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, imgView: UIImageView) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                imgView.image = photo;
            }
        })
    }
}
