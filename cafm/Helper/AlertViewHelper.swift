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

let successSCLAppearance: SCLAlertView.SCLAppearance = SCLAlertView.SCLAppearance(
    kTitleFont: UIFont(name: .MontserratMedium, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium),
    kTextFont: UIFont(name: .MontserratRegular, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
    kButtonFont: UIFont(name: .MontserratBold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold),
    showCloseButton: false,
    contentViewColor: UIColor(appColor: .GreenStatusBG),
    titleColor: UIColor(appColor: .GreenRiskScore),
    textColor: UIColor(appColor: .PrimaryText)
)

extension SCLAlertView {
    
    func showLoading(title: String = "Loading...", subTitle: String = "") {
        if !self.isShowing() {
            self.showWait(title, subTitle: subTitle, colorStyle: 0x384BD3)
        }
    }
    
    class func showErrorAlert(title: String, message: String, cancelButtonTitle: String) {
        SCLAlertView().showError(title, subTitle: message, closeButtonTitle: cancelButtonTitle)
    }
    
    class func showSuccessAlert(title: String, message: String, doneButtonTitle: String, doneButtonaction: @escaping () -> Void) {
        let sclAlert = SCLAlertView(appearance: SCLAppearance(showCloseButton: false))
        sclAlert.addButton(doneButtonTitle, action: doneButtonaction)
        sclAlert.showSuccess(title, subTitle: message)
    }
    
}
