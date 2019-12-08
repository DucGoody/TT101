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
    
    // lấy tất cả Article
    func getLatestArticles(date: Date, completion: @escaping (_ docs: ResponseArticleLatest?) -> Void) {
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
                    guard let data = response.data,
                        let json = try? JSON(data: data).object,
                        let jsonItem = json as? [String : Any]
                        else {
                            completion(nil)
                            return
                    }
                    completion(Mapper<ResponseArticleLatest>().map(JSON: jsonItem))
                }
                completion(nil)
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
    
    // tìm kiếm Article
    func searchArticles(keyword: String, page: Int, completion: @escaping (_ docs: ResponseArticleLatest?) -> Void) {
        let keywordFormat = keyword.trimmingCharacters(in: CharacterSet.whitespaces).folding(options: .diacriticInsensitive, locale: .current)
        
        let urlString = "\(domain)search/v2/articlesearch.json?q=\(keywordFormat)&api-key=\(key)&page=1"
        let url = URL.init(string: urlString)
        
        guard let url2 = url else { completion(nil)
            return
        }
        
        Alamofire.request(url2).responseJSON { (response) in
            switch response.result {
            case .success:
                if response.response?.statusCode == 200 {
                    guard let data = response.data,
                        let json = try? JSON(data: data).object,
                        let jsonItem = json as? [String : Any]
                        else {
                            completion(nil)
                            return
                    }
                    let object = Mapper<ResponseArticleLatest>().map(JSON: jsonItem)
                    completion(object)
                }
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
}
