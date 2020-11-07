//
//  FavoriteTCell.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/20/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit

class FavoriteTCell: UITableViewCell {
    
    @IBOutlet weak var iconImg: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var vicinity: UILabel!
    
    var placeId:String = ""
    
}
