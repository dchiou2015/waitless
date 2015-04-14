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

class MenuTableViewController: UITableViewController, UIActionSheetDelegate, UISearchBarDelegate {
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var orderCountBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var finishBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var finishArrowBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var clearBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var longCellPrototype: MenuTableLongCell! = {
        return self.tableView.dequeueReusableCellWithIdentifier("long") as! MenuTableLongCell
    }()
    
    lazy var shortCellPrototype: MenuTableShortCell! = {
        return self.tableView.dequeueReusableCellWithIdentifier("short") as! MenuTableShortCell
    }()

    var attribStringTemplate: NSAttributedString!
    
    var order = NSMutableSet()
    
    var currentMenu: Menu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribStringTemplate = templateLabel.attributedText
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemChanged:", name: MenuItemChangedNotification, object: nil)
        orderCountBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "GillSans", size: 12)!], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateOrderCount()
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        searchBar.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        searchBar.text = ""
        searchBar(searchBar, textDidChange: "")
        super.viewDidDisappear(animated)
    }
    
    @IBAction func search(sender: UIBarButtonItem) {
        tableView.scrollRectToVisible(searchBar.frame, animated: false)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.2) {
            self.tableView.contentOffset.y += searchBar.frame.size.height
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        menu.eachSection() {
            var index = 0
            for item in $0.items {
                item.parent = $0
                item.index = index++
            }
        }
        if searchText == "" {
            currentMenu = menu
            tableView.reloadData()
        } else {
            let pattern = searchBar.text.lowercaseString
            currentMenu = Menu()
            for subMenu in menu.subMenus {
                let newSubMenu = SubMenu()
                newSubMenu.name = subMenu.name
                newSubMenu.description = subMenu.description
                newSubMenu.parent = currentMenu
                var appendSubMenu = false
                for section in subMenu.sections {
                    let newSection = MenuSection()
                    newSection.name = section.name
                    newSection.description = section.description
                    newSection.parent = newSubMenu
                    var appendSection = false
                    var index = 0
                    for item in section.items {
                        if item.name.lowercaseString.rangeOfString(pattern) != nil {
                            item.parent = newSection
                            item.index = index++
                            appendSection = true
                            newSection.items.append(item)
                        }
                    }
                    if appendSection == true {
                        appendSubMenu = true
                        newSubMenu.sections.append(newSection)
                    }
                }
                if appendSubMenu == true {
                    currentMenu.subMenus.append(newSubMenu)
                }
            }
            tableView.reloadData()
        }
    }
    
    func itemChanged(notification: NSNotification) {
        let item = notification.object as! MenuItem
        let section = currentMenu.indexForSection(item.parent)
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
        let items = order.allObjects as! [MenuItem]
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
    
    
    @IBAction func finish(sender: UIBarButtonItem) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("Order") as! OrderViewController
        controller.order = order.allObjects as! [MenuItem]
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
        for item in order.allObjects as! [MenuItem] {
            item.count = 0
        }
        order.removeAllObjects()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return currentMenu.sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMenu.sectionByIndex(section)!.items.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = currentMenu.sectionByIndex(section)!
        return section.name.uppercaseString + " — " + section.parent.name.uppercaseString
    }
    
    func configureCell(cell: UITableViewCell, forItem item: MenuItem) {
        let result = attributedTitleForItem(item)
        if item.count == 0 {
            let scell = cell as! MenuTableShortCell
            scell.item = item
            scell.descLabel.attributedText = result
        } else {
            assert(item.count > 0)
            let lcell = cell as! MenuTableLongCell
            lcell.item = item
            lcell.descLabel.attributedText = result
            lcell.orderLabel.text = "Ordering \(item.count)"
        }
    }
    
    func attributedTitleForItem(item: MenuItem) -> NSAttributedString {
        let name = NSAttributedString(string: item.name + " ", attributes: attribStringTemplate.attributesAtIndex(0, effectiveRange: nil))
        let desc = NSAttributedString(string: item.description! + " ", attributes: attribStringTemplate.attributesAtIndex(1, effectiveRange: nil))
        let price = NSAttributedString(string: NSString(format: "%.2f", item.price) as String, attributes: attribStringTemplate.attributesAtIndex(2, effectiveRange: nil))
        let result = NSMutableAttributedString()
        result.appendAttributedString(name)
        result.appendAttributedString(desc)
        result.appendAttributedString(price)
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .ByWordWrapping
        result.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, result.length))
        return result
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let item = currentMenu.sectionByIndex(indexPath.section)!.items[indexPath.row]
        if item.count == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("short", forIndexPath: indexPath) as! UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("long", forIndexPath: indexPath) as! UITableViewCell
        }
        configureCell(cell, forItem: item)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = currentMenu.sectionByIndex(indexPath.section)!.items[indexPath.row]
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
}
