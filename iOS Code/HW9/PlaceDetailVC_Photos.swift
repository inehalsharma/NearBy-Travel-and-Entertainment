//
//  PlaceDetailVC_Photos.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/21/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation
import UIKit


class PlaceDetailVC_Photos: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var model:PlaceDetailVC_Photos_Model? = nil
    
    var placeId = ""
    var photos = [Photo]()
    
    @IBOutlet weak var photosTV: UITableView!
    
    @IBOutlet weak var noPhotoV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = PlaceDetailVC_Photos_Model(vc:self)
        if photos.count == 0 { noPhotoV.isHidden = false }
        else { noPhotoV.isHidden = true }
        photosTV.delegate = self
        photosTV.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return photos.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
        if let imageCell = cell as? ImageTCell{
            let at = indexPath.row
            model?.loadPhotoForPlace(to: imageCell.photoView, placeID: placeId, index: at)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let at = indexPath.row
        //print("photos[at].height: \(photos[at].height) , photos[at].width:  \(photos[at].width)")
        let H:Float = Float(photos[at].height)
        let W:Float = Float(photos[at].width)
        let ret = CGFloat(H/W)*tableView.frame.width
        return ret
    }
    
}

class ImageTCell: UITableViewCell{
    @IBOutlet weak var photoView: UIImageView!
}
