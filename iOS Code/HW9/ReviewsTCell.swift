//
//  ReviewsTCell.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/22/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import EasyToast

class ReviewsTCell: UITableViewCell {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var ratingStar: CosmosView!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var content: UITextView!
    
}
