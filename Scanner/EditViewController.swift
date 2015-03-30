//
//  EditViewController.swift
//  Waitless
//
//  Created by Cheng Xie on 3/29/15.
//
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var doneHandler: (String -> ())!
    var text: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = text
        textView.becomeFirstResponder()
    }

    @IBAction func done(sender: UIBarButtonItem) {
        doneHandler?(textView.text)
        textView.resignFirstResponder()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
