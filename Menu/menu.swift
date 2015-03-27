//
//  menu.swift
//  Waitless
//
//  Created by Cheng Xie on 3/25/15.
//
//

import Foundation

let MenuItemChangedNotification = "MenuItemChangedNotification"

class Menu {
    
    let subMenus = [SubMenu]()
    init(json: JSON) {
        for (_, obj) in json {
            let subMenu = SubMenu(json: obj)
            subMenu.parent = self
            subMenus.append(subMenu)
        }
    }
    
    var sectionCount: Int {
        var count = 0
        for subMenu in subMenus {
            count += subMenu.sections.count
        }
        return count
    }
    
    func sectionByIndex(index: Int) -> MenuSection? {
        var i = 0
        for subMenu in subMenus {
            for section in subMenu.sections {
                if i == index {
                    return section
                } else {
                    i++
                }
            }
        }
        return nil
    }
    
    func indexForSection(section: MenuSection) -> Int {
        var i = 0
        for subMenu in subMenus {
            for cur in subMenu.sections {
                if cur === section {
                    return i
                } else {
                    i++
                }
            }
        }
        assert(false)
        return -1
    }
}

class SubMenu {
    init(json: JSON) {
        name = json["menuName"].string!
        description = json["description"].string
        for (_, obj) in json["sections"] {
            let section = MenuSection(json: obj)
            section.parent = self
            sections.append(section)
        }
    }
    weak var parent: Menu!
    let name: String
    let description: String?
    let sections = [MenuSection]()
}

class MenuSection {
    init(json: JSON) {
        name = json["sectionName"].string!
        description = json["description"].string
        var index = 0
        for (_, obj) in json["items"] {
            let item = MenuItem(json: obj)
            item.parent = self
            item.index = index++
            items.append(item)
        }
    }
    weak var parent: SubMenu!
    let name: String
    let description: String?
    let items = [MenuItem]()
}

class MenuItem {
    init(json: JSON) {
        name = json["name"].string!
        
        let priceString = json["price"].string! as NSString
        price = (priceString.substringFromIndex(1) as NSString).doubleValue
        
        description = json["description"].string
    }
    weak var parent: MenuSection!
    var index = -1
    let name: String
    let price: Double
    let description: String?
    var count: Int = 0 {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(MenuItemChangedNotification, object: self)
        }
    }
}

func ==(lhs: MenuItem, rhs: MenuItem) -> Bool {
    return lhs === rhs
}