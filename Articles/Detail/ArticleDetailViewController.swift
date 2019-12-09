//
//  ArticleDetailViewController.swift
//  Articles
//
//  Created by HoangVanDuc on 12/9/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ArticleDetailViewController: UIViewController {
    var url: URL!
    private var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

}
