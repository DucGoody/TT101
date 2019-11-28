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
    var pageIndex: Int = 0
    var datas: [DocsEntity] = []
    let refreshControl = UIRefreshControl()
    var timer: Timer?
    var isRefresh: Bool = false
    
    var dataSource = RxTableViewSectionedReloadDataSource<SectionTableViewCell>(
        configureCell: { (_,_,_,_) in
            fatalError()
    })
    
    @IBOutlet weak var cstPaddingLeftViewSearch: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        self.viewSearch.layer.cornerRadius = 5
        self.viewSearch.layer.borderColor = UIColor.gray.cgColor
        self.viewSearch.layer.borderWidth = 0.5
        self.viewLoad.layer.cornerRadius = 10
        self.indicator.startAnimating()
        self.addShadow(view: viewLoad)
        self.viewLoad.isHidden = true
        
        self.btnCancel.rx.tap.bind { [unowned self] in
            self.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)
        
        self.btnInput.rx.tap.bind { [unowned self] in
            self.tfInput.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        self.initTableView()
        self.initTextFeild()
    }
    
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
        self.refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        self.refreshControl.tintColor = UIColor.lightGray
    }
    
    func initTextFeild() {
        self.tfInput.becomeFirstResponder()
        self.tfInput.rx.controlEvent([.editingChanged])
            .asObservable().subscribe(onNext: { (_) in
                self.timer?.invalidate()
                let text = self.tfInput.text?.trimmingCharacters(in: .whitespaces)
                if let keyword = text, !keyword.isEmpty {
                    self.viewLoad.isHidden = false
                }
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getDataByKeyword), userInfo: nil, repeats: false)
            }).disposed(by: disposeBag)
        
        self.tfInput.rx.controlEvent([.editingDidEndOnExit]).asObservable().subscribe(onNext: { (_) in
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    @objc private func updateData() {
        self.pageIndex = 0
        self.isRefresh = true
        self.getDataByKeyword()
    }
    
    @objc func getDataByKeyword() {
        let text = self.tfInput.text?.trimmingCharacters(in: .whitespaces)
        guard let keyword = text, !keyword.isEmpty else { return }
        
        ServiceController().searchAriticles(keyword: keyword, page: self.pageIndex) { (datas) in
            guard let datas = datas else {
                print("Có lỗi xảy ra vui lòng thử lại")
                return
            }
            if datas.count > 0 && self.isRefresh {
                self.datas.removeAll()
            }
            self.viewLoad.isHidden = true
            self.refreshControl.endRefreshing()
            
            self.binData(datasNew: datas)
        }
    }
    
    //chuyển sang rxDataSource
    func binData(datasNew: [DocsEntity]) {
        self.tableView.dataSource = nil
        if self.datas.count > 0, let lastEntity = self.datas.last {
            if lastEntity.id.elementsEqual("loadmore@cell") {
                self.datas.removeLast()
            }
        }
        self.datas.append(contentsOf: datasNew)
        
        if datasNew.count == 10 {
            let entityLoadMore = DocsEntity()
            entityLoadMore.id = "loadmore@cell"
            self.datas.append(entityLoadMore)
        }
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionTableViewCell>(configureCell: { (dataSource, tableview, indexPath, entity) -> UITableViewCell in
            if entity.id.elementsEqual("loadmore@cell") {
                return self.getLoadMoreCell()
            } else {
                return self.getArticlesCell(item: entity)
            }
        })
        
        let section = [SectionTableViewCell(items: self.datas)]
        Observable.just(section)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(self.tableView.rx.itemSelected, tableView.rx.modelSelected(DocsEntity.self))
            .bind { [unowned self] indexPath, model in
                self.showDetail(item: model)
        }
        .disposed(by: disposeBag)
    }
    
    func getLoadMoreCell() -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: loadMoreCell) as? LoadMoreCell {
            cell.indicator.startAnimating()
            return cell
        }
        return UITableViewCell()
    }
    
    func getArticlesCell(item: DocsEntity) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: articlesCell) as? ArticlesCell {
            cell.indicator.startAnimating()
            cell.binData(docs: item)
            return cell
        }
        return UITableViewCell()
    }
    
    func showDetail(item: DocsEntity) {
        let vc = ArticlesDetailVC()
        if let url = URL.init(string: item.webUrl) {
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let heightTopArea = self.view.safeAreaInsets.top
        self.cstHeightStatusView.constant = heightTopArea
    }
    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
}

extension SearchVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let _ = tableView.dequeueReusableCell(withIdentifier: loadMoreCell) as? LoadMoreCell {
            self.pageIndex += 1
            self.getDataByKeyword()
        }
    }
}

struct SectionTableViewCell {
    var items: [Item]
}

extension SectionTableViewCell: SectionModelType {
    typealias Item = DocsEntity
    
    init(original: SectionTableViewCell, items: [Item]) {
        self = original
        self.items = items
    }
}

