//
//  MenuTableViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/21/15.
//
//

import UIKit

extension MenuItem: Hashable {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

class MenuTableViewController: UITableViewController {
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var orderCountBarButtonItem: UIBarButtonItem!
    
    lazy var longCellPrototype: MenuTableLongCell! = {
        return self.tableView.dequeueReusableCellWithIdentifier("long") as MenuTableLongCell
    }()
    
    lazy var shortCellPrototype: MenuTableShortCell! = {
        return self.tableView.dequeueReusableCellWithIdentifier("short") as MenuTableShortCell
    }()

    var attribStringTemplate: NSAttributedString!
    
    var menu: Menu = {
        let path = NSBundle.mainBundle().pathForResource("menu", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = JSON(data:data!)
        return Menu(json: json)
    }()
    
    var order = [MenuItem: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribStringTemplate = templateLabel.attributedText
        updateOrderCount()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemChanged:", name: MenuItemChangedNotification, object: nil)
    }
    
    func itemChanged(notification: NSNotification) {
        let item = notification.object as MenuItem
        let section = menu.indexForSection(item.parent)
        let row = item.index
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: section)], withRowAnimation: UITableViewRowAnimation.Automatic)
        updateOrder(item)
    }
    
    func updateOrder(item: MenuItem) {
        if item.count == 0 {
            order[item] = nil
        } else {
            order[item] = item.count
        }
        updateOrderCount()
    }
    
    func updateOrderCount() {
        var total = 0
        total = order.values.array.reduce(total) { $1 + $0 }
        orderCountBarButtonItem.title = "\(total) items in order".uppercaseString
    }
    
    @IBAction func showMenu(sender: UIBarButtonItem) {

    }
    
    @IBAction func showInfo(sender: UIButton) {
        storyboard!.instantiateViewControllerWithIdentifier("Info").presentSoftModalInViewController(view.window!.rootViewController)
    }
    
    @IBAction func finish(sender: UIBarButtonItem) {

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu.sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.sectionByIndex(section)!.items.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = menu.sectionByIndex(section)!
        return section.name.uppercaseString + " — " + section.parent.name.uppercaseString
    }
    
    func configureCell(cell: UITableViewCell, forItem item: MenuItem) {
        let name = NSAttributedString(string: item.name + " ", attributes: attribStringTemplate.attributesAtIndex(0, effectiveRange: nil))
        let desc = NSAttributedString(string: item.description! + " ", attributes: attribStringTemplate.attributesAtIndex(1, effectiveRange: nil))
        let price = NSAttributedString(string: NSString(format: "%.2f", item.price), attributes: attribStringTemplate.attributesAtIndex(2, effectiveRange: nil))
        let result = NSMutableAttributedString()
        result.appendAttributedString(name)
        result.appendAttributedString(desc)
        result.appendAttributedString(price)
        
        if item.count == 0 {
            let scell = cell as MenuTableShortCell
            scell.item = item
            scell.descLabel.attributedText = result
        } else {
            assert(item.count > 0)
            let lcell = cell as MenuTableLongCell
            lcell.item = item
            lcell.descLabel.attributedText = result
            lcell.orderLabel.text = "Ordering \(item.count)"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let item = menu.sectionByIndex(indexPath.section)!.items[indexPath.row]
        if item.count == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("short", forIndexPath: indexPath) as UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("long", forIndexPath: indexPath) as UITableViewCell
        }
        configureCell(cell, forItem: item)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = menu.sectionByIndex(indexPath.section)!.items[indexPath.row]
        var cell: UITableViewCell
        if item.count == 0 {
            cell = shortCellPrototype
        } else {
            cell = longCellPrototype
        }
        configureCell(cell, forItem: item)
        cell.layoutIfNeeded()
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height+1
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = menu.sectionByIndex(indexPath.section)!.items[indexPath.row]
        if item.count == 0 {
            return 58
        } else {
            return 96
        }
    }
}
