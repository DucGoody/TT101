//
//  ServiceController.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

class ServiceController {
    let domain = "https://api.nytimes.com/svc/"
    let key = "pH4PGY4gblvAcFIMKV8x7MixeFUrf1AR"
    
    func getLatestAriticles(date: Date, completion: @escaping (_ docs: [DocsEntity]?) -> Void) {
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let currentMonthInt = (calendar?.component(NSCalendar.Unit.month, from: Date())) ?? 11
        let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date())) ?? 2019
        let urlString = "\(domain)archive/v1/\(currentYearInt)/\(currentMonthInt).json?api-key=\(key)"
        let url = URL.init(string: urlString)
        
        guard let url2 = url else {
            completion(nil)
            return
        }
        
        Alamofire.request(url2).responseJSON { (response) in
            switch response.result {
            case .success:
                if response.response?.statusCode == 200 {
                    if let data = response.data, let json = try? JSON(data: data).object {
                        if let jsonItem = json as? [String : Any] {
                            if let item = Mapper<ResponseArticleLatest>().map(JSON: jsonItem)//ResponseArticleLatest.init(JSON: jsonItem, context: nil)
                            {
                                let doc = item.response.docs
                                completion(doc)
                                return;
                            }
                        }
                    }
                }
                completion(nil)
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
    
    func searchAriticles(keyword: String, page: Int, completion: @escaping (_ docs: [DocsEntity]?) -> Void) {
        let keywordFormat = keyword.trimmingCharacters(in: CharacterSet.whitespaces).folding(options: .diacriticInsensitive, locale: .current)
        
        let urlString = "\(domain)search/v2/articlesearch.json?q=\(keywordFormat)&api-key=\(key)&page=1"
        let url = URL.init(string: urlString)
        
        guard let url2 = url else {
            completion(nil)
            return
        }
        
        Alamofire.request(url2).responseJSON { (response) in
            switch response.result {
            case .success:
                if response.response?.statusCode == 200 {
                    if let data = response.data, let json = try? JSON(data: data).object {
                        if let jsonItem = json as? [String : Any] {
                            if let item = Mapper<ResponseArticleLatest>().map(JSON: jsonItem)//ResponseArticleLatest.init(JSON: jsonItem, context: nil)
                            {
                                let doc = item.response.docs
                                completion(doc)
                                return;
                            }
                        }
                    }
                }
                completion(nil)
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
}
