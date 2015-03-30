//
//  TableOrderCell.swift
//  Waitless
//
//  Created by Cheng Xie on 3/29/15.
//
//

import UIKit

class TableOrderCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        self.label.preferredMaxLayoutWidth = self.label.frame.size.width
    }
}
