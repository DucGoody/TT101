//
//  ArticlesDetailVC.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WebKit
import SnapKit

class ArticlesDetailVC: UIViewController {
    var url: URL!
    var webview: WKWebView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        
        webview = WKWebView()
        self.view.addSubview(webview)
        
        webview.snp.makeConstraints { (web) in
            web.top.equalTo(self.view).inset(0)
            web.left.equalTo(self.view).inset(0)
            web.right.equalTo(self.view).inset(0)
            web.bottom.equalTo(self.view).inset(0)
        }
        
        
        let request = URLRequest.init(url: url)
        webview.load(request)
        
        webview.rx.deallocating.debug("decidePolicyNavigationResponse").subscribe(onNext: { (_) in
            
        }).disposed(by: disposeBag)
    }
}
