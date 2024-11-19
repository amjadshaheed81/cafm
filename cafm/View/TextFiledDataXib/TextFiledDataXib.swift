//
//  TextFiledDataXib.swift
//  cafm
//
//  Created by ShitaRam on 25/08/24.
//

import UIKit

class TextFiledDataXib: NibView {
    
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var lblTFName: UILabel!
    @IBOutlet weak var tfData: UITextField!
    @IBOutlet weak var lblTFNameHeight: NSLayoutConstraint!
    
    var title: String? {
        didSet {
            self.lblTFName.text = title
        }
    }
    
    var bgColor: UIColor? {
        didSet {
            self.tfData.backgroundColor = bgColor
        }
    }
    
    var text: String? {
        get {
            return self.tfData.text
        }
        set {
            self.tfData.text = newValue
        }
    }
    
    var placeholder: String? {
        get {
            return self.tfData.placeholder
        }
        set {
            self.tfData.placeholder = newValue
        }
    }
    
    override func awakeFromNib() {
    }
    
    @IBAction func menuBtnAction(_ sender: Any) {
    }
    
}
