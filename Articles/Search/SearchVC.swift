//
//  SearchVC.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SearchVC: UIViewController {
    @IBOutlet weak var cstHeightStatusView: NSLayoutConstraint!
    @IBOutlet weak var viewContentSearch: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btnInput: UIButton!
    @IBOutlet weak var viewLoad: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    let articlesCell: String = "ArticlesCell"
    let loadMoreCell: String = "LoadMoreCell"
    var datas: [DocsEntity] = []
    let refreshControl = UIRefreshControl()
    var isShowLoadding: Bool = true
    var timer: Timer?
    var viewModel: ArticlesViewModel!
    var paramSearch = ParamSearchArticles()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ArticlesViewModel()
        self.viewModel.searchArticles()
        self.initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let heightTopArea = self.view.safeAreaInsets.top
        self.cstHeightStatusView.constant = heightTopArea
    }
    
    //init UI
    func initUI() {
        self.viewSearch.layer.cornerRadius = 5
        self.viewSearch.layer.borderColor = UIColor.gray.cgColor
        self.viewSearch.layer.borderWidth = 0.5
        
        //
        self.viewLoad.layer.cornerRadius = 10
        self.addShadow(view: viewLoad)
        self.viewLoad.isHidden = true
        self.indicator.startAnimating()
        
        //action cancel
        self.btnCancel.rx.tap.asDriver()
            .throttle(.milliseconds(2000))
            .drive(onNext: { (_) in
                self.dismiss(animated: false, completion: nil)
            }).disposed(by: disposeBag)
        
        //action show keybroad
        self.btnInput.rx.tap.asDriver()
        .throttle(.milliseconds(2000))
        .drive(onNext: { (_) in
            self.tfInput.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        self.initTableView()
        self.initTextFeild()
        self.binData()
        self.selectItem()
    }
    
    //init tableView
    func initTableView() {
        self.tableView.register(UINib.init(nibName: articlesCell, bundle: nil), forCellReuseIdentifier: articlesCell)
        self.tableView.register(UINib.init(nibName: loadMoreCell, bundle: nil), forCellReuseIdentifier: loadMoreCell)
        self.tableView.separatorColor = .clear
        self.tableView.isScrollEnabled = true
        self.tableView.contentInset = UIEdgeInsets.init(top: 16, left: 0, bottom: 8, right: 0)
        self.tableView.delegate = self
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl.tintColor = UIColor.lightGray
    }
    
    // init TextField
    func initTextFeild() {
        self.tfInput.becomeFirstResponder()
        
        self.tfInput.rx.controlEvent([.editingChanged])
            .asObservable().subscribe(onNext: { (_) in
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getDataByKeyword), userInfo: nil, repeats: false)
            }).disposed(by: disposeBag)
        
        self.tfInput.rx.controlEvent([.editingDidEndOnExit]).asObservable().subscribe(onNext: { (_) in
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    // action pulltorefresh
    @objc private func refreshData() {
        self.isShowLoadding = false
        self.getDataByKeyword()
    }
    
    // action get data by keyword
    @objc func getDataByKeyword(_ isLoadMore: Bool = false) {
        let text = self.tfInput.text?.trimmingCharacters(in: .whitespaces)
        guard let keyword = text, !keyword.isEmpty else { return }
        if !isLoadMore { self.paramSearch.pageIndex = 0 }
        self.paramSearch.keyword = keyword
        
        self.viewLoad.isHidden = !isShowLoadding
        
        Observable.of(self.paramSearch).bind(to: self.viewModel.paramSearch).disposed(by: self.disposeBag)
    }
    
    // bin data to tableview
    func binData() {
        self.viewModel.searchResult2.asObservable().bind(to: self.tableView.rx.items(dataSource: self.dataSource())).disposed(by: disposeBag)
        self.viewModel.onLoadSucces = {
            self.refreshControl.endRefreshing()
            self.isShowLoadding = true
            self.viewLoad.isHidden = true
        }
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
    
    //get cell load more
    func getLoadMoreCell() -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: loadMoreCell) as? LoadMoreCell {
            cell.indicator.startAnimating()
            return cell
        }
        return UITableViewCell()
    }
    
    // get cell article
    func getArticlesCell(item: DocsEntity) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: articlesCell) as? ArticlesCell {
            cell.binData(docs: item)
            return cell
        }
        return UITableViewCell()
    }
    
    // go to Detail Article
    func showDetail(item: DocsEntity) {
        let vc = ArticlesDetailVC()
        if let url = URL.init(string: item.webUrl) {
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
}

extension SearchVC : UITableViewDelegate {
    // action load more
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let arrCellName = NSStringFromClass(cell.classForCoder).components(separatedBy: ".")
        if loadMoreCell.elementsEqual(arrCellName.last ?? "") {
            self.paramSearch.pageIndex += 1
            self.isShowLoadding = false
            self.getDataByKeyword(true)
        }
    }
}

extension SearchVC {
    //init data source
    func dataSource() -> RxTableViewSectionedReloadDataSource<DocsSection> {
        return RxTableViewSectionedReloadDataSource<DocsSection>(
            configureCell: { dataSource, table, indexPath, item in
                if let item = item as? DocsEntity {
                    return self.getArticlesCell(item: item)
                } else {
                    return self.getLoadMoreCell()
                }
        })
    }
}

struct DocsSection {
    var items: [Any]
}

extension DocsSection: SectionModelType {
    typealias Item = Any
    init(original: DocsSection, items: [Item]) {
        self = original
        self.items = items
    }
}
