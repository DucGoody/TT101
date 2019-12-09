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

class ViewController: UIViewController {
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var dateFilter: Date = Date()
    private let disposeBag = DisposeBag()
    private let articlesCell = "ArticlesCell"
    private var viewModel: ArticlesViewModel!
    
    lazy var dateFormatter: DateFormatter = { [unowned self] in
          let formatter = DateFormatter()
          formatter.dateFormat = "MMMM yyyy"
          return formatter
      }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.updateDate()
        self.viewModel = ArticlesViewModel()
        self.viewModel.getArticles()
        self.getDataLatest()
    }
    
    //config UI
    func configUI() {
        self.navigationItem.title = "NewYorkTimes"
        let imageSearch = UIImage.init(named: "ic_search")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: imageSearch, style: .plain, target: self, action:#selector(clickRightNavigation))
        
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        self.tableView.register(UINib.init(nibName: articlesCell, bundle: nil), forCellReuseIdentifier: articlesCell)
        
        self.viewDate.layer.cornerRadius = 5
        self.viewDate.layer.borderColor = UIColor.gray.cgColor
        self.viewDate.layer.borderWidth = 0.5
        
        self.indicator.startAnimating()
    }
    
    // action chọn date
    @IBAction func actionSelectDate(_ sender: Any) {
        let vc = PopupSelectDateViewController.init(dateSelected: self.dateFilter, viewInput: self.viewDate)
        vc.modalPresentationStyle = .overCurrentContext
        vc.onSelectDate = { [unowned self] date in
            if self.checkDate(date: date) {
                self.dateFilter = date
                self.updateDate()
                self.indicator.isHidden = false
                Observable.of(self.dateFilter).bind(to: self.viewModel.paramGetAll).disposed(by: self.disposeBag)
            }
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    //chuyển sang màn hình tìm kiếm
    @objc func clickRightNavigation() {
        let vc = SearchViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //update view sau khi chọn time
    func updateDate() {
        let strDate = self.dateFormatter.string(from: self.dateFilter)
        self.lbDate.text = strDate
    }
    
    //get data
    func getDataLatest() {
        Observable.of(dateFilter).bind(to: viewModel.paramGetAll).disposed(by: disposeBag)
        viewModel.getArticlesResult.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: articlesCell, cellType: ArticlesCell.self)) { index, entity, cell in
            cell.binData(docs: entity)
            self.indicator.isHidden = true
        }.disposed(by: disposeBag)
        
        selectItem()
    }
    
    //select item
    func selectItem() {
        Observable
            .zip(self.tableView.rx.itemSelected, tableView.rx.modelSelected(DocsEntity.self))
        .bind { [unowned self] indexPath, model in
            self.showDetail(item: model)
        }
        .disposed(by: disposeBag)
    }
    
    //chuyển sang màn hình chi tiết
    func showDetail(item: DocsEntity) {
        let vc = ArticleDetailViewController()
        if let url = URL.init(string: item.webUrl) {
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //check trùng tháng và trùng năm
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



