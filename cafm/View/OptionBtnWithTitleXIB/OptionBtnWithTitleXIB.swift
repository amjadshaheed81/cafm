//
//  OptionBtnWithTitleXIB.swift
//  cafm
//
//  Created by NS on 07/09/24.
//  
//

import UIKit

class OptionBtnWithTitleXIB: NibView {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var optionXIB: OptionBtnXib!
    
    @IBOutlet weak var optionXIBTrailingCons: NSLayoutConstraint!
    
    var title: String? {
        didSet {
            self.titleLbl.text = title
        }
    }
    
    var bgColor: UIColor? {
        didSet {
            self.optionXIB.dummyTF.backgroundColor = bgColor
        }
    }
    
    var text: String? {
        get {
            return self.optionXIB.lblText.text
        }
        set {
            self.optionXIB.lblText.text = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return self.optionXIB.imageView.image
        }
        set {
            self.optionXIB.imageView.image = newValue
        }
    }
    
    var placeholder: String? {
        get {
            return self.optionXIB.lblText.text
        }
        set {
            self.optionXIB.lblText.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
