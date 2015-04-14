//
//  InfoViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/30/15.
//
//

import UIKit

class InfoViewController: UIViewController {
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://waitless.strikingly.com/")!)
    }
}
