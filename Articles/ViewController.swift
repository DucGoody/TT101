//
//  ViewController.swift
//  Articles
//
//  Created by HoangVanDuc on 11/26/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var dateFilter: Date = Date()
    
    lazy var dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateFormat = "MMMM yyyy"
          return formatter
      }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Youk Times"
        let imageSearch = UIImage.init(named: "ic_search")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: imageSearch, style: .plain, target: self, action:#selector(clickRightNavigation))
        
        self.configUI()
    }
    
    func configUI() {
        self.viewDate.layer.cornerRadius = 5
    }
    
    @IBAction func actionSelectDate(_ sender: Any) {
        let vc = PopupSelectDateVC.init(dateSelected: self.dateFilter, viewInput: self.viewDate)
        vc.modalPresentationStyle = .overCurrentContext
        vc.onSelectDate = { [unowned self] date in
            self.dateFilter = date
            let strDate = self.dateFormatter.string(from: self.dateFilter)
            self.lbDate.text = strDate
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func clickRightNavigation() {
        
    }
}

