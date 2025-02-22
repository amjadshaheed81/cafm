//
//  TextViewVC.swift
//  cafm
//
//  Created by NS on 13/12/24.
//
//

import UIKit

class TextViewVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var attributedText: NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.textView.attributedText = attributedText
    }
    
    func configureNavigationBar() {
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}
