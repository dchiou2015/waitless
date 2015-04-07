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

class MenuTableViewController: UITableViewController, UIActionSheetDelegate {
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var orderCountBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var finishBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var finishArrowBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var clearBarButtonItem: UIBarButtonItem!
    
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
    
    var order = NSMutableSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribStringTemplate = templateLabel.attributedText
        updateOrderCount()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemChanged:", name: MenuItemChangedNotification, object: nil)
        orderCountBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "GillSans", size: 12)!], forState: UIControlState.Normal)
    }
    
    func itemChanged(notification: NSNotification) {
        let item = notification.object as MenuItem
        let section = menu.indexForSection(item.parent)
        let row = item.index
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        
        // only animate if the cell's height is changing:
        var shouldAnimate = false
        if let oldCell = tableView.cellForRowAtIndexPath(indexPath) {
            var oldCellIsLong = (oldCell as? MenuTableLongCell) != nil
            var newCellIsLong = item.count > 0
            shouldAnimate = oldCellIsLong != newCellIsLong
        }
        let animation = shouldAnimate ? UITableViewRowAnimation.Automatic : UITableViewRowAnimation.None
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
        updateOrder(item)
    }
    
    func updateOrder(item: MenuItem) {
        if item.count == 0 {
            order.removeObject(item)
        } else {
            order.addObject(item)
        }
        updateOrderCount()
    }
    
    func updateOrderCount() {
        var total = 0
        let items = order.allObjects as [MenuItem]
        for item in items {
            total += item.count
        }
        orderCountBarButtonItem.title = "\(total) items in order".uppercaseString
        orderCountBarButtonItem.tintColor = UIColor.blackColor()
        orderCountBarButtonItem.enabled = true
        clearBarButtonItem.tintColor = UIColor.blackColor()
        clearBarButtonItem.enabled = true
        finishBarButtonItem.enabled = true
        finishArrowBarButtonItem.enabled = true
        
        navigationController!.setToolbarHidden(total == 0, animated: true)
    }
    
    @IBAction func showMenu(sender: UIBarButtonItem) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("Sections") as MenuSectionsTableViewController
        controller.menu = menu
        controller.handler = {
            indexPath in
            var sectionIndex = 0
            for i in 0..<indexPath.section {
                sectionIndex += self.menu.subMenus[i].sections.count
            }
            sectionIndex += indexPath.row
            
            let afterDismiss = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(afterDismiss, dispatch_get_main_queue()) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionIndex), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
        controller.presentSoftModalInViewController(view.window!.rootViewController)
    }
    
    @IBAction func showInfo(sender: UIButton) {
        storyboard!.instantiateViewControllerWithIdentifier("Info").presentSoftModalInViewController(view.window!.rootViewController)
    }
    
    @IBAction func finish(sender: UIBarButtonItem) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("Order") as OrderViewController
        controller.order = order.allObjects as [MenuItem]
        controller.presentSoftModalInViewController(view.window!.rootViewController)
    }
    
    @IBAction func clear(sender: UIBarButtonItem) {
        UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Clear Order").showFromBarButtonItem(sender, animated: true)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            clearOrder()
        }
    }
    
    func clearOrder() {
        for item in order.allObjects as [MenuItem] {
            item.count = 0
        }
        order.removeAllObjects()
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
        let result = attributedTitleForItem(item)
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
    
    func attributedTitleForItem(item: MenuItem) -> NSAttributedString {
        let name = NSAttributedString(string: item.name + " ", attributes: attribStringTemplate.attributesAtIndex(0, effectiveRange: nil))
        let desc = NSAttributedString(string: item.description! + " ", attributes: attribStringTemplate.attributesAtIndex(1, effectiveRange: nil))
        let price = NSAttributedString(string: NSString(format: "%.2f", item.price), attributes: attribStringTemplate.attributesAtIndex(2, effectiveRange: nil))
        let result = NSMutableAttributedString()
        result.appendAttributedString(name)
        result.appendAttributedString(desc)
        result.appendAttributedString(price)
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .ByWordWrapping
        result.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, result.length))
        return result
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
        // how much larger is the cell than the text it contains?
        let shortCellTextInsets = CGSizeMake(320 - 256, 58 - 38)
        let longCellTextInsets = CGSizeMake(320 - 256, 96 - 38)
        let insets = item.count > 0 ? longCellTextInsets : shortCellTextInsets
        
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        let textHeight = attributedTitleForItem(item).boundingRectWithSize(CGSizeMake(tableView.bounds.size.width - insets.width, 9999), options: options, context: nil).size.height
        return ceil(textHeight + insets.height)
    }
    
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let item = menu.sectionByIndex(indexPath.section)!.items[indexPath.row]
//        var cell: UITableViewCell
//        if item.count == 0 {
//            cell = shortCellPrototype
//        } else {
//            cell = longCellPrototype
//        }
//        configureCell(cell, forItem: item)
//        cell.layoutIfNeeded()
//        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height+1
//    }
}
