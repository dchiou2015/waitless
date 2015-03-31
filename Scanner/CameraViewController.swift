//
//  CameraViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/29/15.
//
//

import UIKit

let menu: Menu = {
    let path = NSBundle.mainBundle().pathForResource("menu", ofType: "json")
    let data = NSData(contentsOfFile: path!)
    let json = JSON(data:data!)
    return Menu(json: json)
}()

class CameraViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var tableNumberField: UITextField!
    @IBOutlet weak var tableNumberForm: UIVisualEffectView!
    
    @IBOutlet weak var scanningLabel: UILabel!
    @IBOutlet weak var scannedLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var scanContainer: UIVisualEffectView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var noteButton: UIButton!
    
    var orderHandler: ((Int, String) -> ())!
    
    var tableNumber = -1
    
    @IBOutlet weak var orderCountBarButton: UIBarButtonItem!
    
    var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNumberForm.layer.cornerRadius = 22.5
        tableNumberForm.clipsToBounds = true
        scanContainer.layer.cornerRadius = 12
        scanContainer.clipsToBounds = true
        
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, view.frame.width, 50))
        toolBar.barStyle = UIBarStyle.Default
        doneBarButtonItem = UIBarButtonItem(title: "DONE", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithTableNumber")
        doneBarButtonItem.enabled = false
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                         doneBarButtonItem]
        toolBar.sizeToFit()
        tableNumberField.inputAccessoryView = toolBar
        
        tableNumberField.becomeFirstResponder()
        orderCountBarButton.title = "0"
    }
    
    func doneWithTableNumber() {
        tableNumberField.resignFirstResponder()
        tableNumber = tableNumberField.text.toInt()!
        assert(tableNumber >= 0)
        
        if !showScanned {
            resetScan()
        }
    }
    
    func resetScan() {
        showScanned = false
        
        let scanner = MTBBarcodeScanner(metadataObjectTypes: [AVMetadataObjectTypeQRCode], previewView: cameraView)
        MTBBarcodeScanner.requestCameraPermissionWithSuccess() {
            success in
            if success {
                scanner.startScanningWithResultBlock() {
                    let codes = $0 as [AVMetadataMachineReadableCodeObject]
                    let code = codes.first!
                    self.orderScanned(code.stringValue)
                    scanner.stopScanning()
                }
            } else {
                println("Can't access to camera!")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue()) {
                    let order = "1 0\n" +
                    "1 2\n" +
                    "2 34\n" +
                    "3 5"
                    self.orderScanned(order)
                }
            }
        }
        

    }
    
    var showScanned: Bool = false {
        didSet {
            view.setNeedsLayout()
            if self.showScanned == false {
                orderLabel.text = nil
            }
            UIView.animateWithDuration(0.1) {
                for v in [self.scannedLabel, self.okButton, self.cancelButton, self.noteButton, self.orderLabel] as [UIView] {
                    v.alpha = self.showScanned ? 1 : 0
                }
                self.scanningLabel.alpha = self.showScanned ? 0 : 1
                self.view.layoutIfNeeded()
            }
        }
    }

    @IBAction func tableNumberChanged(sender: UITextField) {
        let number = sender.text.toInt()
        if number == nil {
            doneBarButtonItem.enabled = false
        } else {
            doneBarButtonItem.enabled = true
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func orderScanned(orderText: String) {
        var result = ""
        let lines = split(orderText) { $0 == "\n" }
        for (i, line) in enumerate(lines) {
            let parts = split(line) { $0 == " " }
            assert(parts.count == 2)
            let item = menu.itemById(parts[1].toInt()!)!
            let newLine = parts[0] + " " + item.name + (i == lines.count-1 ? "" : "\n")
            result += newLine
        }
        orderLabel.text = result
        showScanned = true
    }

    @IBAction func ok() {
        assert(tableNumber >= 0)
        orderHandler?(tableNumber, self.orderLabel.text!)
        orderCountBarButton.title = "\((orderCountBarButton.title!.toInt()! + 1))"
        resetScan()
    }
    
    @IBAction func cancel() {
        resetScan()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        if showScanned == true {
            ok()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let naviController = segue.destinationViewController as UINavigationController
        let controller = naviController.visibleViewController as EditViewController
        controller.text = orderLabel.text
        controller.doneHandler = {
            orderString in
            self.orderLabel.text = orderString
        }
    }
}
