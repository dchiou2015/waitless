//
//  OrderTableCell.swift
//  Waitless
//
//  Created by Cheng Xie on 3/27/15.
//
//

import UIKit

class OrderTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var item: MenuItem!
    
    @IBAction func increase() {
        item.count++
    }
    
    @IBAction func decrease() {
        item.count--
    }
}
