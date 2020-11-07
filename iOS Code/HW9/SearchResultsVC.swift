//
//  SearchResultsVC.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/20/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import EasyToast

class SearchResultsVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var noResultV: UIView!
    
    @IBOutlet weak var placeProfileTV: UITableView!
    
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    private var model:SearchResultsModel? = nil
    
    var pagesData = [PlaceResults]()
    var curPage = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        model = SearchResultsModel(vc:self)
        
        if pagesData[curPage].hasResult {
            noResultV.isHidden = true
        }else{
            noResultV.isHidden = false
        }
        
        //table view
        placeProfileTV.delegate = self
        placeProfileTV.dataSource = self
        
        //prev next Btn
        prevBtn.isEnabled = !(curPage == 0)
        nextBtn.isEnabled = !(pagesData[curPage].nextPageToken == "")
        
        
    }
    
    @IBAction func goPrev(_ sender: UIButton) {
        //print("goPrev")
        curPage = curPage - 1
        //update whole view
        placeProfileTV.reloadData()
        self.viewDidLoad()
    }
    @IBAction func goNext(_ sender: UIButton) {
        //print("goNext")
        curPage = curPage + 1
        if curPage == pagesData.count {
            //request new page data
            model?.requestNextPage(token: pagesData[curPage - 1].nextPageToken)
        } else {
            //use data in our array
            //update whole view
            placeProfileTV.reloadData()
            self.viewDidLoad()
        }
    }
    
    
    
    // ---- Table View Controller
    func numberOfSections(in tableView: UITableView) -> Int { return 1; }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pagesData[curPage].tableData.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeProfileCell", for: indexPath)
        if let placeProfileCell = cell as? SearchResultsTCell{
            let cellData = pagesData[curPage].tableData[indexPath.row]
            //UI
            placeProfileCell.iconImg.load(url: URL(string: cellData.iconUrl)!)
            placeProfileCell.name.text = cellData.name
            placeProfileCell.vicinity.text = cellData.vicinity
            if FAVORITE_LIST.array(forKey: cellData.placeId) == nil {
                placeProfileCell.favorite.setImage(placeProfileCell.emptyHeart, for: UIControlState.normal)
            }else{
                placeProfileCell.favorite.setImage(placeProfileCell.filledHeart, for: UIControlState.normal)
            }
            //Data
            placeProfileCell.cellData = cellData
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex:Int = indexPath.row
        let place_id = pagesData[curPage].tableData[selectedIndex].placeId
        model?.requestPlaceDetail(placeId: place_id)
    }
    
    var pdData:PlaceDetail = PlaceDetail()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if let destination = segue.destination as? PlaceDetailTabbarC {
            destination.placeDetail = pdData
        }
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}






