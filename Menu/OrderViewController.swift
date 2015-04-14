//
//  OrderViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/27/15.
//
//

import UIKit

class OrderViewController: UITableViewController {
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var order: [MenuItem]!
    
    func generateQRCode(string: String) -> UIImage {
        func resizeImage(image: UIImage, withQuality quality: CGInterpolationQuality, #rate: CGFloat) -> UIImage {
            let width = image.size.width * rate
            let height = image.size.height * rate
            UIGraphicsBeginImageContext(CGSizeMake(width, height))
            let context = UIGraphicsGetCurrentContext()
            CGContextSetInterpolationQuality(context, quality)
            image.drawInRect(CGRectMake(0, 0, width, height))
            let resized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resized
        }
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter.setDefaults()
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        let outputImage = filter.outputImage
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage, fromRect: outputImage.extent())
        let image = UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Up)
        let resized = resizeImage(image!, withQuality: kCGInterpolationNone, rate: CGFloat(10.0))
        return resized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemChanged:", name: MenuItemChangedNotification, object: nil)
        
        updateTotalPrice()
        updateQRCode()
    }
    
    func itemChanged(notification: NSNotification) {
        let item = notification.object as! MenuItem
        var index = -1
        for (i, v) in enumerate(order) {
            if v === item {
                index = i
                break
            }
        }
        assert(index != -1)
        if item.count == 0 {
            order.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
        }
        
        updateTotalPrice()
        updateQRCode()
    }
    
    func updateQRCode() {
        var orderString = ""
        for i in order {
            orderString += "\(i.count) \(i.id)\n"
        }
        qrImageView.image = generateQRCode(orderString)
    }
    
    func updateTotalPrice() {
        var total = 0.0
        for item in order {
            total += Double(item.count) * item.price
        }
        totalPriceLabel.text = NSString(format: "$%.2f total", total) as String
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = order[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! OrderTableCell
        cell.item = item
        cell.nameLabel.text = item.name
        cell.priceLabel.text = NSString(format: "%.2f×%d", item.price, item.count) as String
        return cell
    }
    
    override func updateFrameWithSoftModalBounds(bounds: CGRect) {
        let inset: CGFloat = 30
        let topInset: CGFloat = inset + 40
        self.view.frame = CGRectMake(inset, topInset, bounds.size.width - inset * 2, bounds.size.height - topInset + 10)
    }
}
