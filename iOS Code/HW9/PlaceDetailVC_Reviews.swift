//
//  PlaceDetailVC_Reviews.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/21/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import EasyToast

class PlaceDetailVC_Reviews: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var googleReviews = [Review]()
    var yelpReviews = [Review]()
    var reviewsOnView = [Review]()
    
    var show = ""
    var sortby = ""
    var order = ""
    
    @IBOutlet weak var segGoogleYelp: UISegmentedControl!
    @IBOutlet weak var sortMode: UISegmentedControl!
    @IBOutlet weak var segOrder: UISegmentedControl!
    
    @IBOutlet weak var noReviewV: UIView!
    
    @IBOutlet weak var reviewTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init setting
        show = "google"
        sortby = "default"
        order = "descending"
        reviewsOnView = googleReviews
        if reviewsOnView.count == 0 { noReviewV.isHidden = false }
        else { noReviewV.isHidden = true }
        
        reviewTV.dataSource = self
        reviewTV.delegate = self
    }
    @IBAction func changeReviews(_ sender: UISegmentedControl) {
        if segGoogleYelp.selectedSegmentIndex == 0 {
            //select Google
            show = "google"
        }else if segGoogleYelp.selectedSegmentIndex == 1 {
            //select Yelp
            show = "yelp"
        }
        updateTableView()
    }
    @IBAction func changeSort(_ sender: UISegmentedControl) {
        if sortMode.selectedSegmentIndex == 0 {
            // default
            sortby = "default"
        }else if sortMode.selectedSegmentIndex == 1 {
            // rating
            sortby = "rating"
        }else if sortMode.selectedSegmentIndex == 2 {
            // date
            sortby = "date"
        }
        updateTableView()
    }
    
    @IBAction func changeOrder(_ sender: UISegmentedControl) {
        if segOrder.selectedSegmentIndex == 0 {
            // ascending
            order = "ascending"
        }else if segOrder.selectedSegmentIndex == 1 {
            // descending
            order = "descending"
        }
        updateTableView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return reviewsOnView.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        if let reviewCell = cell as? ReviewsTCell {
            let reviewData = reviewsOnView[indexPath.row]
            if reviewData.profilePhotoUrl != "" { reviewCell.profilePhoto.load(url: URL(string: reviewData.profilePhotoUrl)!) }
            reviewCell.name.text = reviewData.authorName
            reviewCell.ratingStar.rating = reviewData.rating
            reviewCell.date.text = reviewData.time
            reviewCell.content.text = reviewData.text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex:Int = indexPath.row
        //print("Go to webPage, didSelectRowAt \(selectedIndex)")
        if let url = URL(string: reviewsOnView[selectedIndex].authorUrl) {
            UIApplication.shared.open(url, options: [:])
        }else{ print("Fail to open review web page!") }
    }
    
    func updateTableView(){
        //print("updateTableView()")
        //print("[\(show), \(sortby), \(order)]")
        
        if show == "google" { reviewsOnView = googleReviews }
        else if show == "yelp" { reviewsOnView = yelpReviews }
        if reviewsOnView.count == 0 { noReviewV.isHidden = false }
        else { noReviewV.isHidden = true }
        
        if sortby != "default" && reviewsOnView.count != 0 {
            if sortby == "rating" {
                if order == "ascending"{
                    reviewsOnView.sort(by: { $0.rating < $1.rating })
                }else if order == "descending"{
                    reviewsOnView.sort(by: { $0.rating > $1.rating })
                }
            }else if sortby == "date" {
                if order == "ascending"{
                    reviewsOnView.sort(by: { $0.time < $1.time })
                }else if order == "descending"{
                    reviewsOnView.sort(by: { $0.time > $1.time })
                }
            }
        }
        
        reviewTV.reloadData()
    }
}
