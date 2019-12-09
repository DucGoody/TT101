//
//  SearchViewController.swift
//  Articles
//
//  Created by HoangVanDuc on 12/8/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SearchViewController: UIViewController {
    
    @IBOutlet weak var cstHeightStatusView: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let articlesCell: String = "ArticlesCell"
    private let loadMoreCell: String = "LoadMoreCell"
    private var datas: [DocsEntity] = []
    private let refreshControl = UIRefreshControl()
    private var isShowLoadding: Bool = true
    private var timer: Timer?
    private var viewModel: ArticlesViewModel!
    private var paramSearch = ParamSearchArticles()
    
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
        self.searchView.layer.cornerRadius = 5
        self.searchView.layer.borderColor = UIColor.gray.cgColor
        self.searchView.layer.borderWidth = 0.5
        
        //
        self.loadingView.layer.cornerRadius = 10
        self.addShadow(view: loadingView)
        self.loadingView.isHidden = true
        self.indicator.startAnimating()
        
        //action cancel
        self.cancelButton.rx.tap.asDriver()
            .throttle(.milliseconds(2000))
            .drive(onNext: { (_) in
                self.navigationController?.popViewController(animated: false)
            }).disposed(by: disposeBag)
        
        //action show keybroad
        self.searchButton.rx.tap.asDriver()
            .throttle(.milliseconds(2000))
            .drive(onNext: { (_) in
                self.searchTextField.becomeFirstResponder()
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
        self.searchTextField.becomeFirstResponder()
        
        self.searchTextField.rx.controlEvent([.editingChanged])
            .asObservable().subscribe(onNext: { (_) in
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getDataByKeyword), userInfo: nil, repeats: false)
            }).disposed(by: disposeBag)
        
        self.searchTextField.rx.controlEvent([.editingDidEndOnExit]).asObservable().subscribe(onNext: { (_) in
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
        let text = self.searchTextField.text?.trimmingCharacters(in: .whitespaces)
        guard let keyword = text, !keyword.isEmpty else { return }
        if !isLoadMore { self.paramSearch.pageIndex = 0 }
        self.paramSearch.keyword = keyword
        
        self.loadingView.isHidden = !isShowLoadding
        
        Observable.of(self.paramSearch).bind(to: self.viewModel.paramSearch).disposed(by: self.disposeBag)
    }
    
    // bin data to tableview
    func binData() {
        self.viewModel.searchArticleResult.asObservable().bind(to: self.tableView.rx.items(dataSource: self.dataSource())).disposed(by: disposeBag)
        self.viewModel.onLoadSucces = {
            self.refreshControl.endRefreshing()
            self.isShowLoadding = true
            self.loadingView.isHidden = true
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
        let vc = ArticleDetailViewController()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension SearchViewController : UITableViewDelegate {
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

extension SearchViewController {
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
