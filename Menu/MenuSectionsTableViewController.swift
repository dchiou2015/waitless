//
//  MenuSectionsTableViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/26/15.
//
//

import UIKit

var menu: Menu = {
    let path = NSBundle.mainBundle().pathForResource("menu", ofType: "json")
    let data = NSData(contentsOfFile: path!)
    let json = JSON(data:data!)
    return Menu(json: json)
    }()

class MenuSectionsTableViewController: UITableViewController {
    var menuTableViewController: MenuTableViewController!
    
    @IBAction func showInfo() {
        storyboard!.instantiateViewControllerWithIdentifier("Info").presentSoftModalInViewController(view.window!.rootViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableViewController = storyboard!.instantiateViewControllerWithIdentifier("Menu") as! MenuTableViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.toolbarHidden = true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu.subMenus.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.subMenus[section].sections.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu.subMenus[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = menu.subMenus[indexPath.section].sections[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        v.textLabel.font = UIFont(name: "GillSans", size: 13)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var sectionIndex = 0
        for i in 0..<indexPath.section {
            sectionIndex += menu.subMenus[i].sections.count
        }
        sectionIndex += indexPath.row
        menuTableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionIndex), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        navigationController!.pushViewController(menuTableViewController, animated: true)
    }
}
