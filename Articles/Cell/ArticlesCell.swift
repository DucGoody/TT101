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
import Kingfisher

class ArticlesCell: UITableViewCell {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    private let dis = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.parentView.layer.borderColor = UIColor.gray.cgColor
        self.parentView.layer.borderWidth = 0.5
    }
    
    func binData(docs: DocsEntity) {
        self.nameLabel.text = docs.headline.main
        self.nameLabel.text = self.convertDateToString(date: docs.pubDate)
        self.descriptionLabel.text = docs.snippet
        
        //load image
        if docs.multimedia.count > 0 {
            var urlString = docs.multimedia[0].url
            urlString = "https://www.nytimes.com/\(urlString)"
            self.articleImageView.setImage(urlString)
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

extension UIImageView {
    
    func setImage(_ urlString: String) {
        if let url = URL(string: urlString){
            let placeholder = UIImage(named: "ic_default_article")
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url,placeholder: placeholder)
        }
    }
}
