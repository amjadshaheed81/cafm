//
//  AlertViewHelper.swift
//  cafm
//
//  Created by NS on 24/08/24.
//  
//

import SCLAlertView

let loadingSCLAppearance: SCLAlertView.SCLAppearance = SCLAlertView.SCLAppearance(
    kTitleTop: 40,
    kTitleFont: UIFont(name: .MontserratMedium, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium),
    showCloseButton: false,
    titleColor: UIColor(appColor: .PrimaryText)
)

let errorSCLAppearance: SCLAlertView.SCLAppearance = SCLAlertView.SCLAppearance(
    kTitleFont: UIFont(name: .MontserratMedium, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium),
    kTextFont: UIFont(name: .MontserratRegular, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
    kButtonFont: UIFont(name: .MontserratBold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold),
    contentViewColor: UIColor(appColor: .RedStatusBG),
    titleColor: UIColor(appColor: .RedRiskScore),
    textColor: UIColor(appColor: .PrimaryText)
)

extension SCLAlertView {
    
    func showLoading() {
        if !self.isShowing() {
            self.showWait("Loading...", subTitle: "", colorStyle: 0x384BD3)
        }
    }
    
    class func showLoading(title: String, message: String, cancelButtonTitle: String) {
        SCLAlertView(appearance: errorSCLAppearance).showError(title, subTitle: message, closeButtonTitle: cancelButtonTitle, colorStyle: 0xE03C3C)
    }
    
}
