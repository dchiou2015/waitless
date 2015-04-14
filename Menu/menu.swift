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
    
    var subMenus = [SubMenu]()
    private var idMap = [Int: MenuItem]()
    init() {}
    init(json: JSON) {
        for (_, obj) in json {
            let subMenu = SubMenu(json: obj)
            subMenu.parent = self
            subMenus.append(subMenu)
        }
        
        var id = 0
        for subMenu in subMenus {
            for section in subMenu.sections {
                for item in section.items {
                    item.id = id
                    idMap[id] = item
                    id++
                }
            }
        }
    }
    
    func itemById(id: Int) -> MenuItem? {
        return idMap[id]
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
    
    func eachItem(lam: MenuItem -> ()) {
        for subMenu in menu.subMenus {
            for section in subMenu.sections {
                for item in section.items {
                    lam(item)
                }
            }
        }
    }
    
    func eachSection(lam: MenuSection -> ()) {
        for subMenu in menu.subMenus {
            for section in subMenu.sections {
                lam(section)
            }
        }
    }
    
    func eachSubMenu(lam: SubMenu -> ()) {
        for subMenu in menu.subMenus {
            lam(subMenu)
        }
    }
}

class SubMenu {
    init() {}
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
    var name: String!
    var description: String?
    var sections = [MenuSection]()
}

class MenuSection {
    init() {}
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
    var name: String!
    var description: String?
    var items = [MenuItem]()
}

class MenuSection1 {
    init() {}
    let description: String? = nil
    var items = [MenuItem]()
}

class MenuItem {
    init(json: JSON) {
        name = json["name"].string!
        
        let priceString = json["price"].string! as NSString
        price = (priceString.substringFromIndex(1) as NSString).doubleValue
        
        description = json["description"].string
    }
    weak var parent: MenuSection!
    var id: Int!
    var index: Int!
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