//
//  LoadMoreCell.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.indicator.startAnimating()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
