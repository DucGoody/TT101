//
//  ViewController.swift
//  Articles
//
//  Created by HoangVanDuc on 11/26/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Youk Times"
        let imageSearch = UIImage.init(named: "ic_search")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: imageSearch, style: .plain, target: self, action:#selector(clickRightNavigation))
    }
    
    @objc func clickRightNavigation() {
        
    }
}

