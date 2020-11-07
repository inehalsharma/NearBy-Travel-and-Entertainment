//
//  PlaceDetailVC.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/20/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import EasyToast

class PlaceDetailVC_Info: UIViewController{
    
    var address_in = ""
    var phoneNumber_in = ""
    var priceLevel_in:Int = -1
    var ratingStar_in:Double = -1
    var website_in = ""
    var googlePage_in = ""
    
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phoneNumber: UITextView!
    
    @IBOutlet weak var priceLevel: UILabel!
    
    @IBOutlet weak var ratingStar: CosmosView!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var googlePage: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        address.text = address_in
        phoneNumber.text = phoneNumber_in
        priceLevel.text = getPriceSymbol(no: priceLevel_in)
        ratingStar.rating = ratingStar_in
        website.text = website_in
        googlePage.text = googlePage_in
    }
    
    func getPriceSymbol(no:Int) -> String {
        var ret = ""
        for _ in 0...no{ ret+="$" }
        return ret
    }
    
}
