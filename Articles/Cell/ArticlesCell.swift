//
//  ArticlesCell.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ArticlesCell: UITableViewCell {
    @IBOutlet weak var viewParent: UIView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivArticle: UIImageView!
    @IBOutlet weak var viewLoad: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let dis = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.indicator.startAnimating()
        self.viewParent.layer.borderColor = UIColor.gray.cgColor
        self.viewParent.layer.borderWidth = 0.5
    }
    
    func binData(docs: DocsEntity) {
        self.lbName.text = docs.headline.main
        self.lbDate.text = self.convertDateToString(date: docs.pubDate)
        self.lbDescription.text = docs.snippet
        //loadimage
        if docs.multimedia.count > 0 {
            var urlString = docs.multimedia[0].url
            urlString = "https://www.nytimes.com/\(urlString)"
            let url = URL.init(string: urlString)
            if let url = url {
                let urlRequest = URLRequest.init(url: url)
                URLSession.shared.rx
                    .response(request: urlRequest)
                    .subscribeOn(MainScheduler.instance)
                    .subscribe(onNext: { (data) in
                        DispatchQueue.main.async {
                            self.ivArticle.image = UIImage.init(data: data.data)
                        }
                    }, onError: { (error) in
                        self.hiddenViewLoad()
                        print(error)
                    }, onCompleted: {
                        self.hiddenViewLoad()
                    }, onDisposed: nil).disposed(by: dis)
            }
        }
    }
    
    func hiddenViewLoad() {
        DispatchQueue.main.async {
            self.viewLoad.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
