//
//  TextViewWithTitleXIB.swift
//  cafm
//
//  Created by NS on 28/09/24.
//  
//

import UIKit

class TextViewWithTitleXIB: NibView {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textView: DefaultTextView!
    
    var title: String? {
        didSet {
            self.titleLbl.text = title
        }
    }
    
    var bgColor: UIColor? {
        didSet {
            self.textView.backgroundColor = bgColor
        }
    }
    
    var text: String? {
        get {
            return self.textView.text
        }
        set {
            self.textView.text = newValue
        }
    }
    
    var placeholder: String? {
        get {
            return self.textView.placeholder
        }
        set {
            self.textView.placeholder = newValue ?? ""
        }
    }
    
}
