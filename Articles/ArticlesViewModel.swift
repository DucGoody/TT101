//
//  ArticlesViewModel.swift
//  Articles
//
//  Created by HoangVanDuc on 12/3/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ArticlesViewModel: NSObject {
    var paramSearch = BehaviorRelay<ParamSearchArticles>(value: ParamSearchArticles())
    var paramGetAll = BehaviorRelay<Date>.init(value: Date())
    
    var getArticlesResult = BehaviorRelay<[DocsEntity]>(value: [])
    var searchArticleResult = BehaviorRelay<[DocsSection]>(value: [])
    
    private var listData: [Any] = []
    private let dis = DisposeBag()
    var onLoadSucces: (() -> Void)?
    var onLoadError: (() -> Void)?
    
    private let group = DispatchGroup()
    private let queue = DispatchQueue.global(qos: .background)
    
    override init() {
        super.init()
    }
    
    func searchArticles() {
        self.paramSearch.asObservable().subscribe(onNext: { (param) in
            if param.keyword.count <= 0 || param.keyword.isEmpty {return}
            ServiceController().searchArticles(keyword: param.keyword, page: param.pageIndex) { (data) in
                if let data = data {
                    self.onLoadSucces?()
                    self.getData(data: data, pageIndex: param.pageIndex)
                } else {
                    self.onLoadError?()
                }
            }
        }).disposed(by: dis)
    }
    
    func getData(data: ResponseArticleLatest, pageIndex: Int) {
        self.queue.sync {
            self.group.enter()
            
            if pageIndex == 0 { self.listData.removeAll() }
            
            let itemLoadMore: String = "loadmore"
            if let item = self.listData.last as? String, item.elementsEqual(itemLoadMore) {
                self.listData.removeLast()
            }
            
            self.listData.append(contentsOf: data.response.docs)
            
            if data.response.docs.count >= 10 {
                self.listData.append(itemLoadMore)
            }
            self.group.leave()
        }
        
        self.group.notify(queue: .main) {
            let oneSection = DocsSection(items: self.listData)
            self.searchArticleResult.accept([oneSection])
        }
    }
    
    func getArticles() {
        self.paramGetAll.subscribe(onNext: { (date) in
            ServiceController().getLatestArticles(date: date) { (response) in
                if let data = response {
                    self.getArticlesResult.accept(data.response.docs)
                    self.onLoadSucces?()
                } else {
                    self.onLoadError?()
                }
            }
        }).disposed(by: dis)
    }
}

class ParamSearchArticles: NSObject {
    var keyword: String = ""
    var pageIndex: Int = 0
}
