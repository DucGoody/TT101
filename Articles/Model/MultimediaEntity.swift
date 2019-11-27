//
//  MultimediaEntity.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import ObjectMapper

class MultimediaEntity: Mappable {
    var rank: Int = 0
    var subtype: String = ""
    var caption: String = ""
    var credit: String = ""
    var type:String = ""
    var url: String = ""
    var height:Double = 0.0
    var width: Double = 0.0
    var legacy: Legacy!
    var subType: String = ""
    var cropName: String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    
    func mapping(map: Map) {
        cropName <- map["crop_name"]
        rank <- map["rank"]
        subtype <- map["subtype"]
        caption <- map["caption"]
        credit <- map["credit"]
        type <- map["type"]
        url <- map["url"]
        height <- map["height"]
        width <- map["width"]
        legacy <- map["legacy"]
        subType <- map["subType"]
        cropName <- map["crop_name"]
    }

}

class Legacy: Mappable {
    var xlarge: String = ""
    var xlargewidth:Double = 0.0
    var xlargeheight: Double = 0.0
    
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    
    func mapping(map: Map) {
        xlarge <- map["xlarge"]
        xlargewidth <- map["xlargewidth"]
        xlargeheight <- map["xlargeheight"]
    }
}
