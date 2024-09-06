//
//  CustomTextField.swift
//  cafm
//
//  Created by NS on 27/08/24.
//  
//

import UIKit

class CustomTextField: NibView {
    
    @IBOutlet weak var textField: UITextField!

    weak var delegate: CustomTextFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.font = getAppPrimaryFont(from: self.textField.font)
    }
    
    @IBAction func textFieldTextDidChange(_ sender: UITextField) {
        self.delegate?.customTextFieldTextDidChange(view: self, textField: sender)
    }
    
}

protocol CustomTextFieldDelegate: AnyObject {
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField)
    
}

