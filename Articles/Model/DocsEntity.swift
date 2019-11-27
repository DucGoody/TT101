//
//  DocsEntity.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import ObjectMapper

class DocsEntity: Mappable {
    var abstract: String = ""
    var webUrl: String = ""
    var snippet: String = ""
    var leadParagraph:String = ""
    var source: String = ""
    var multimedia: [MultimediaEntity] = []
    var headline: Headline!
    var keywords: [ItemKeywords] = []
    var pubDate: Date = Date()
    var documentType: String = ""
    var newsDesk:String = ""
    var sectionName:String = ""
    var subsectionName:String = ""
    var byline: Byline!
    var typeOfMaterial:String = ""
    var id:String = ""
    var wordCount:Int = 0
    var uri:String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        abstract <- map["abstract"]
        webUrl <- map["web_url"]
        snippet <- map["snippet"]
        leadParagraph <- map["lead_paragraph"]
        source <- map["source"]
        multimedia <- map["multimedia"]
        headline <- map["headline"]
        keywords <- map["keywords"]
        pubDate <- (map["pub_date"],DateTransform())
        documentType <- map["document_type"]
        newsDesk <- map["news_desk"]
        sectionName <- map["section_name"]
        subsectionName <- map["subsection_name"]
        byline <- map["byline"]
        typeOfMaterial <- map["type_of_material"]
        id <- map["_id"]
        wordCount <- map["word_count"]
        uri <- map["uri"]
    }
    
}

class ItemKeywords: Mappable {
    var name: String = ""
    var value: String = ""
    var rank: Int = 0
    var major: String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        value <- map["value"]
        rank <- map["rank"]
        major <- map["major"]
        name <- map["name"]
    }
}


class Headline: Mappable {
    var main: String = ""
    var kicker: String = ""
    var contentKicker: String = ""
    var printHeadline: String = ""
    var name: String = ""
    var seo: String = ""
    var sub: String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        main <- map["main"]
        kicker <- map["kicker"]
        contentKicker <- map["content_kicker"]
        printHeadline <- map["print_headline"]
        name <- map["name"]
        seo <- map["seo"]
        sub <- map["sub"]
    }
}

class Byline: Mappable {
    var original: String = ""
    var person: [Person] = []
    var organization: String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        original <- map["main"]
        person <- map["kicker"]
        organization <- map["content_kicker"]
    }
}

class Person: Mappable {
    var firstname: String = ""
    var middlename: String = ""
    var lastname: String = ""
    var qualifier: String = ""
    var title: String = ""
    var role: String = ""
    var organization: String = ""
    var rank: Int = 0
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        firstname <- map["firstname"]
        middlename <- map["middlename"]
        lastname <- map["lastname"]
        
        qualifier <- map["qualifier"]
        title <- map["title"]
        role <- map["role"]
        
        organization <- map["organization"]
        rank <- map["rank"]
    }
}
