//
//  PlaceDetailVC_Map.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/21/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps
import EasyToast

class PlaceDetailVC_Map: UIViewController, CLLocationManagerDelegate{
    var model:PlaceDetailVC_Map_Model? = nil
    
    var lat:Double = -1
    var lng:Double = -1
    
    var curLat:Double = 0
    var curLng:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        model = PlaceDetailVC_Map_Model(vc:self)
        
    }
    
    @IBOutlet weak var fromTf: UITextField!
    @IBAction func autoComplete(_ sender: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    var curLatLng = ""
    @IBAction func yourLoc(_ sender: UIButton) {
        if fromTf.text! == "Your location" {
            fromTf.text = ""
            mapVC.mapReset()
        } else {
            fromTf.text = "Your location"
            curLatLng = (model?.getCurrentLatLng())!
            model?.requestDirections(from: curLatLng, toLat: lat, toLng: lng, mode: travelMode)
        }
    }
    
    
    var travelMode = "driving"
    var directionsData = Directions(camera: LatLng(lat: -1, lng: -1))
    @IBOutlet weak var segMode: UISegmentedControl!
    @IBAction func modeChange(_ sender: UISegmentedControl) {
        if segMode.selectedSegmentIndex == 0 { // driving
            travelMode = "driving"
        }else if segMode.selectedSegmentIndex == 1{ // bicycling
            travelMode = "bicycling"
        }else if segMode.selectedSegmentIndex == 2{ // transit
            travelMode = "transit"
        }else if segMode.selectedSegmentIndex == 3{ // walking
            travelMode = "walking"
        }
        if fromTf.text! == "Your location" {
            curLatLng = (model?.getCurrentLatLng())!
            model?.requestDirections(from: curLatLng, toLat: lat, toLng: lng, mode: travelMode)
        }else if fromTf.text! != ""{
            model?.requestDirections(from: fromTf.text!, toLat: lat, toLng: lng, mode: travelMode)
        }
        
    }
    
    var mapVC = googleMapView()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapView"{
            print("prepare for segue")
            let mapView = segue.destination as! googleMapView
            mapView.lat = self.lat
            mapView.lng = self.lng
            mapVC = mapView
        }
    }
    func passDirectionDataToMap() {
        print("passDirectionDataToMap()")
        mapVC.directions = directionsData
    }
    func drawDirections() {
        mapVC.drawDirections()
    }
    
}


class googleMapView: UIViewController{
    var lat:Double = -1
    var lng:Double = -1
    let defaultZ:Float = 16
    
    var directions = Directions(camera: LatLng(lat: -1, lng: -1))
    
    var mapView:GMSMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMap()
    }
    
    func loadMap(){
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom:defaultZ )
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        marker.map = mapView
        self.view = mapView
    }
    
    func mapReset() {
        // clear all
        mapView?.clear()
        // set marker
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        marker.map = mapView
        // move camera animation
        let newLatLng = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let cameraUpdate = GMSCameraUpdate.setTarget(newLatLng, zoom: defaultZ)
        mapView?.animate(with: cameraUpdate)
    }
    func drawDirections() {
        //print("drawDirections() in GoogleMapView")
        
        // clear all
        mapView?.clear()
        
        // set start-end mark
        let fromMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: directions.fromLat, longitude: directions.fromLng))
        fromMarker.map = mapView
        let toMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: directions.toLat, longitude: directions.toLng))
        toMarker.map = mapView
        
        // draw pathes
        for path in directions.encodedPaths{
            let polyline = GMSPolyline()
            polyline.path = GMSPath(fromEncodedPath: path)
            polyline.strokeWidth = 3
            polyline.map = mapView
        }
        
        // move camera animation
        let newLatLng = CLLocationCoordinate2D(latitude: directions.camera.lat, longitude: directions.camera.lng)
        let cameraUpdate = GMSCameraUpdate.setTarget(newLatLng, zoom: directions.bestZ)
        mapView?.animate(with: cameraUpdate)
        
    }
}


extension PlaceDetailVC_Map: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromTf.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
        
        //request from Lat Lng
        //print("getFromLatLng(_ sender: UITextField)")
        model?.requestDirections(from: fromTf.text!, toLat: lat, toLng: lng, mode: travelMode)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        fromTf.text = ""
        dismiss(animated: true, completion: nil)
        
        //reset map view
        self.mapVC.mapReset()
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
