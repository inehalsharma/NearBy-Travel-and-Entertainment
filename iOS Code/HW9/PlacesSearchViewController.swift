//
//  PlacesSearchViewController.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/12/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import UIKit
import McPicker
import GooglePlaces
import EasyToast

let LOCAL_MANAGER = CLLocationManager()
class PlacesSearchViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate{
    
    private var model:PlacesSearchModel? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        model = PlacesSearchModel(vc:self)
        
        // Search View
        let categoryData:[[String]] = [["default", "airport", "amusement park", "aquarium", "art gallery", "bakery", "bar", "beauty salon", "bowling alley", "bus station", "cafe", "campground", "car rental", "casino", "lodging", "movie theater", "museum", "night club", "park", "parking", "restaurant", "shopping mall", "stadium", "subway station", "taxi stand", "train station", "transit station", "travel agency", "zoo"]]
        let mcInputView = McPicker(data: categoryData)
        categoryTf.inputViewMcPicker = mcInputView
        categoryTf.doneHandler = { [weak categoryTf](selections) in categoryTf?.text = selections[0]!
        }
        LOCAL_MANAGER.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            LOCAL_MANAGER.delegate = self
            LOCAL_MANAGER.desiredAccuracy = kCLLocationAccuracyBest
            LOCAL_MANAGER.startUpdatingLocation()
        }
        
        // Favorite View
        favoriteTV.delegate = self
        favoriteTV.dataSource = self
        favoriteIdList = getFavoriteList()
        if favoriteIdList.count == 0 {
            favoriteTV.isHidden = true
            noResultV.isHidden = false
        }else{
            noResultV.isHidden = true
            favoriteTV.isHidden = false
        }
        
        
        
    }
    
    @IBOutlet weak var seg: UISegmentedControl!
    @IBOutlet weak var searchV: UIView!
    @IBOutlet weak var favoriteV: UIView!
    @IBAction func changeSeg(_ sender: UISegmentedControl) {
        if seg.selectedSegmentIndex == 0{// go search
            favoriteV.isHidden = true
            searchV.isHidden = false
        } else if seg.selectedSegmentIndex == 1 {// go favorite
            favoriteIdList = getFavoriteList()
            favoriteTV.reloadData()
            if favoriteIdList.count == 0 {
                favoriteTV.isHidden = true
                noResultV.isHidden = false
            }else{
                noResultV.isHidden = true
                favoriteTV.isHidden = false
            }
            searchV.isHidden = true
            favoriteV.isHidden = false
        }
    }
    
    // ---------- Favorite Table View -----------
    
    @IBOutlet weak var favoriteTV: UITableView!
    @IBOutlet weak var noResultV: UIView!
    
    var favoriteIdList = [String]()
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return favoriteIdList.count }
    func getFavoriteList() -> [String] {
        var ret = [String]()
        for (key, _) in FAVORITE_LIST.dictionaryRepresentation(){
            if IS_PLACE_ID(id: key){ ret.append(key) }
        }
        return ret
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        if let favoriteCell = cell as? FavoriteTCell{
            let cellData = FAVORITE_LIST.array(forKey: favoriteIdList[indexPath.row])
            //UI
            favoriteCell.iconImg.load(url: URL(string: cellData![0] as! String)!)
            favoriteCell.name.text = cellData?[1] as? String
            favoriteCell.vicinity.text = cellData?[2] as? String
            //Data
            favoriteCell.placeId = cellData?[3] as! String
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = favoriteIdList[indexPath.row]
            let cellData = FAVORITE_LIST.array(forKey: id)
            favoriteIdList.remove(at: indexPath.row)
            FAVORITE_LIST.removeObject(forKey: id)
            self.view.showToast("\((cellData?[1] as? String)!) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if favoriteIdList.count == 0 { noResultV.isHidden = false }
            else { noResultV.isHidden = true }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model?.requestPlaceDetail(placeId: favoriteIdList[indexPath.row])
    }
    
    var pdData = PlaceDetail()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if let destination = segue.destination as? PlaceDetailTabbarC {
            destination.placeDetail = pdData
        } else if let searchResultsVC = segue.destination as? SearchResultsVC {
            searchResultsVC.curPage = 0;
            searchResultsVC.pagesData = [placeResultData]
        }
    }
    
    
    // ---------- Search View -------------------
    var placeResultData = PlaceResults(hasResult: false)
    
    @IBOutlet weak var keywordTf: UITextField!
    @IBOutlet weak var categoryTf: McTextField!
    @IBOutlet weak var distanceTf: UITextField!
    @IBOutlet weak var fromTf: UITextField!
    
    @IBAction func goSearch(_ sender: UIButton) {
        let validateMsg = model?.saveValidateForm(key: keywordTf.text!, cat: categoryTf.text!, dis: distanceTf.text!, f: fromTf.text!)
        if validateMsg != "" {
            self.view.showToast("\(validateMsg ?? "-") is invalid", position: .bottom, popTime: 2, dismissOnTap: false)
            return
        }else{
            model?.submitForm()
        }
    }
    
    let de_keyword = ""
    let de_category = "defaults"
    let de_distance = ""
    let de_from = "Your location"
    @IBAction func resetForm(_ sender: UIButton) {
        keywordTf.text = de_keyword;
        categoryTf.text = de_category;
        distanceTf.text = de_distance;
        fromTf.text = de_from;
    }
    
    @IBAction func autoComplete(_ sender: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension PlacesSearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromTf.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        fromTf.text = de_from;
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension UINavigationController {
    ///Get previous view controller of the navigation stack
    func previousViewController() -> UIViewController?{
        let lenght = self.viewControllers.count
        let previousViewController: UIViewController? = lenght >= 2 ? self.viewControllers[lenght-2] : nil
        return previousViewController
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
