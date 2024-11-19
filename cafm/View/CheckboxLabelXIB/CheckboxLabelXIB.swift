//
//  CheckboxLabelXIB.swift
//  cafm
//
//  Created by NS on 07/09/24.
//  
//

import UIKit

class CheckboxLabelXIB: NibView {
    
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var mianView: UIView!
    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var checkBoxHeight: NSLayoutConstraint!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    weak var delegate: CheckboxLabelXIBDelgate?
    var actionHandler: ((Bool) -> Void)?
    
    var title: String? {
        didSet {
            self.mainLbl.text = title
        }
    }
    
    var isOn: Bool = false {
        didSet {
            self.checkmarkImageView.isHidden = !isOn
        }
    }
    
    var isDisabled: Bool = false {
        didSet {
            self.checkBtn.isUserInteractionEnabled = !isDisabled
            self.actionBtn.isUserInteractionEnabled = !isDisabled
            if isDisabled {
                self.squareImageView.alpha = 0.5
                self.checkmarkImageView.alpha = 0.5
            }else {
                self.squareImageView.alpha = 1.0
                self.checkmarkImageView.alpha = 1.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func checkBtnClicked(_ sender: UIButton) {
        if !self.isDisabled, let actionHandler {
            self.isOn.toggle()
            actionHandler(self.isOn)
        }
        self.delegate?.checkboxLabelXIBCheckBtnClicked(view: self, sender: sender)
    }
    
}

protocol CheckboxLabelXIBDelgate: AnyObject {
    func checkboxLabelXIBCheckBtnClicked(view: CheckboxLabelXIB, sender: UIButton)
}
