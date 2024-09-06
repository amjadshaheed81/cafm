//
//  CommonViews.swift
//  cafm
//
//  Created by NS on 17/08/24.
//
//

import UIKit

class PrimaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addCorner()
        self.tintColor = UIColor.white
        self.backgroundColor = UIColor(appColor: .AppTint)
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = UIColor(appColor: .AppTint)
            }else {
                self.backgroundColor = UIColor.lightGray
            }
        }
    }
}

class SecondaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white //UIColor.clear
        self.addCorner()
        self.addBorder()
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
    }
}

class DefaultFontLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = getAppPrimaryFont(from: self.font)
    }
}
