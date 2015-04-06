//
//  MenuSectionsTableViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/26/15.
//
//

import UIKit

class MenuSectionsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var handler: (NSIndexPath -> ())!
    var menu: Menu!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu.subMenus.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.subMenus[section].sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu.subMenus[section].name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = menu.subMenus[indexPath.section].sections[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as UITableViewHeaderFooterView
        v.textLabel.font = UIFont(name: "GillSans", size: 13)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        handler?(indexPath)
        dismissSoftModal()
    }

}
