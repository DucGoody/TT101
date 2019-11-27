//
//  ResponseGetArticleLatest.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import ObjectMapper

class ResponseArticleLatest: Mappable {
    var copyright: String = ""
    var response: ResponseDetailArticleLatest!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        copyright <- map["copyright"]
        response <- map["response"]
    }
}


class ResponseDetailArticleLatest: Mappable {
    var meta: Meta!
    var docs:[DocsEntity] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        meta <- map["meta"]
        docs <- map["docs"]
    }
}

class Meta: Mappable {
    var hits: Int = 0
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        hits <- map["hits"]
    }
}
