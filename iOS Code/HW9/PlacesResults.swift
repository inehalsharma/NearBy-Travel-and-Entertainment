//
//  PlacesResults.swift
//  HW9
//
//  Created by Cheng Ju Lin on 4/18/18.
//  Copyright © 2018 Cheng Ju Lin. All rights reserved.
//

import Foundation

class PlaceResults {
    var hasResult:Bool
    var nextPageToken:String = ""
    var tableData = [TableCellData]()
    init(hasResult:Bool) {
        self.hasResult = hasResult
    }
    
    func testcase(){
        hasResult = true
        nextPageToken = "nextPageToken_test"
        for i in 1...5{
            let d = TableCellData(iconUrl: "icon url test in", name: "test case Name \(i)", vicinity: "Test Address", placeId: "test place_id")
            tableData.append(d)
        }
        
    }
}

class TableCellData{
    
    var iconUrl:String
    var name:String
    var vicinity:String
    var placeId:String
    
    init(iconUrl:String, name:String, vicinity:String, placeId:String){
        self.iconUrl = iconUrl
        self.name = name
        self.vicinity = vicinity
        self.placeId = placeId
    }
}
