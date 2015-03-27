//
//  MenuTableLongCell.swift
//  Waitless
//
//  Created by Cheng Xie on 3/26/15.
//
//

import UIKit

class MenuTableLongCell: UITableViewCell {
    var item: MenuItem!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        self.descLabel.preferredMaxLayoutWidth = self.descLabel.frame.size.width
    }
    
    @IBAction func increase() {
        assert(item.count != 0)
        item.count += 1
    }
    
    @IBAction func decrease() {
        assert(item.count != 0)
        item.count -= 1
    }
    
}
