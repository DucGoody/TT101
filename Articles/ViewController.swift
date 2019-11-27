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
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var dateFilter: Date = Date()
    let disposeBag = DisposeBag()
    
    let articlesCell = "ArticlesCell"
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
        self.getDataLatest()
    }
    
    func configUI() {
        self.viewDate.layer.cornerRadius = 5
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        tableView.register(UINib.init(nibName: articlesCell, bundle: nil), forCellReuseIdentifier: articlesCell)
        self.updateDate()
        self.viewDate.layer.borderColor = UIColor.gray.cgColor
        self.viewDate.layer.borderWidth = 0.5
        self.indicator.startAnimating()
    }
    
    @IBAction func actionSelectDate(_ sender: Any) {
        let vc = PopupSelectDateVC.init(dateSelected: self.dateFilter, viewInput: self.viewDate)
        vc.modalPresentationStyle = .overCurrentContext
        vc.onSelectDate = { [unowned self] date in
            if self.checkDate(date: date) {
                self.dateFilter = date
                self.updateDate()
                self.indicator.isHidden = false
                self.getDataLatest()
            } else {
                return
            }
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func clickRightNavigation() {
        
    }
    
    func updateDate() {
        let strDate = self.dateFormatter.string(from: self.dateFilter)
        self.lbDate.text = strDate
    }
    
    func getDataLatest() {
        ServiceController().getLatestAriticles(date: dateFilter) { (datas) in
            self.indicator.isHidden = true
            guard let datas = datas else {
                print("Có lỗi xảy ra vui lòng thử lại")
                return
            }
            DispatchQueue.main.async {
                self.binData(datas: datas)
            }
        }
    }
    
    func binData(datas: [DocsEntity]) {
        Observable.just(datas).bind(to: self.tableView.rx.items(cellIdentifier: articlesCell, cellType: ArticlesCell.self)) { (row, item, cell) in
            cell.binData(docs: item)
        }.disposed(by: disposeBag)
        
        Observable
            .zip(self.tableView.rx.itemSelected, tableView.rx.modelSelected(DocsEntity.self))
        .bind { [unowned self] indexPath, model in
            self.showDetail(item: model)
        }
        .disposed(by: disposeBag)
    }
    
    func showDetail(item: DocsEntity) {
        let vc = ArticlesDetailVC()
        if let url = URL.init(string: item.webUrl) {
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func checkDate(date: Date) -> Bool {
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let currentMonthInt1 = (calendar?.component(NSCalendar.Unit.month, from: date)) ?? 11
        let currentYearInt1 = (calendar?.component(NSCalendar.Unit.year, from: date)) ?? 2019
        
        let currentMonthInt2 = (calendar?.component(NSCalendar.Unit.month, from: self.dateFilter)) ?? 11
        let currentYearInt2 = (calendar?.component(NSCalendar.Unit.year, from: self.dateFilter)) ?? 2019
        
        if currentMonthInt1 == currentMonthInt2 && currentYearInt1 == currentYearInt2 {
            return false
        }
        return true
    }
}



