//
//  SearchResultsTCell.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/19/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit
import EasyToast

class SearchResultsTCell: UITableViewCell {
    
    @IBOutlet weak var iconImg: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var vicinity: UILabel!
    @IBOutlet weak var favorite: UIButton!
    
    let filledHeart = UIImage(named: "favorite-filled")
    let emptyHeart = UIImage(named: "favorite-empty")
    
    var cellData:TableCellData? = nil
    
    @IBAction func switchFavorite(_ sender: UIButton) {
        let id = (cellData?.placeId)!
        if FAVORITE_LIST.object(forKey: (cellData?.placeId)!) == nil {
            favorite.setImage(filledHeart, for: UIControlState.normal)
            let url = (cellData?.iconUrl)!
            let n = (cellData?.name)!
            let v = (cellData?.vicinity)!
            FAVORITE_LIST.set([url, n, v, id], forKey: id)
            showToast("\((cellData?.name)!) was added to favorites", position: .bottom, popTime: 2, dismissOnTap: false)
        }else{
            favorite.setImage(emptyHeart, for: UIControlState.normal)
            FAVORITE_LIST.removeObject(forKey: id)
            showToast("\((cellData?.name)!) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: false)
        }
    }
    
    
    
}
