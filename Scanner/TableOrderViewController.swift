//
//  TableOrderViewController.swift
//  Scanner
//
//  Created by Cheng Xie on 3/21/15.
//
//

import UIKit

class TableOrder {
    init(_ tableNumber: Int) {
        self.tableNumber = tableNumber
    }
    var tableNumber: Int
    var date = NSDate()
    var orders = [String]()
}

class TableOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var orders: [TableOrder] = [TableOrder]() {
        didSet {

        }
    }
    
    lazy var prototypeCell: TableOrderCell = {
        return self.tableView.dequeueReusableCellWithIdentifier("cell") as TableOrderCell
    }()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return orders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders[section].orders.count
    }
    
    func configureCell(cell: TableOrderCell, indexPath: NSIndexPath) {
        cell.label.text = orders[indexPath.section].orders[indexPath.row]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as TableOrderCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let order = orders[section]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let title = dateFormatter.stringFromDate(order.date) + " at table \(order.tableNumber)"
        return title.uppercaseString
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        configureCell(prototypeCell, indexPath: indexPath)
        prototypeCell.layoutIfNeeded()
        return prototypeCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height+1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("Edit") as UINavigationController
        let editController = controller.visibleViewController as EditViewController
        editController.text = orders[indexPath.section].orders[indexPath.row]
        editController.doneHandler = {
            orderString in
            self.orders[indexPath.section].orders[indexPath.row] = orderString
            self.tableView.reloadData()
        }
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as CameraViewController
        controller.orderHandler = {
            tableNumber, orderString in
            let order = self.orders.filter() { $0.tableNumber == tableNumber }
            if order.count == 0 {
                let newOrder = TableOrder(tableNumber)
                newOrder.orders.append(orderString)
                self.orders.insert(newOrder, atIndex: 0)
            } else {
                let theOrder = order.first!
                theOrder.orders.append(orderString)
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func clear(sender: UIBarButtonItem) {
        UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Clear").showFromBarButtonItem(sender, animated: true)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            orders.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
}

