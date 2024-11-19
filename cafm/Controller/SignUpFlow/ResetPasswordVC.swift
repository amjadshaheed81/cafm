//
//  ResetPasswordVC.swift
//  cafm
//
//  Created by Savan Lakhani on 18/08/24.
//

import UIKit
import SCLAlertView

class ResetPasswordVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBOutlet weak var tfOtp: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var tfOtpHeight: NSLayoutConstraint!
    @IBOutlet weak var descTopLbl: NSLayoutConstraint!
    @IBOutlet weak var descBottomLbl: NSLayoutConstraint!
    
    var userEmailAddess = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfEmail.delegate = self
        self.tfOtp.delegate = self
        self.initialViewSetup()
    }
    
    func initialViewSetup() {
        self.titleLbl.font = UIFont(name: .MontserratBold, size: 20)
        self.emailLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.descLbl.font = UIFont(name: .MontserratMedium, size: 17)
        self.resetBtn.titleLabel?.font = UIFont(name: .MontserratMedium, size: 16)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: 13) as Any,
            .foregroundColor: UIColor(appColor: .GrayText)
        ]
        
        self.tfOtpHeight.constant = 0.0
        
        self.tfOtp.keyboardType = .numberPad

        self.tfEmail.attributedPlaceholder = NSAttributedString(string: "Enter your email", attributes: attributes)
        self.tfOtp.attributedPlaceholder = NSAttributedString(string: "Enter OTP", attributes: attributes)
        addCornerToView(self.tfEmail, value: 7)
        addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addCornerToView(self.tfOtp, value: 7)
        addBorderToView(self.tfOtp, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addCornerToView(self.resetBtn, value: 7)
    }
    
    @IBAction func resetPasswordClick(_ sender: Any) {
        if userEmailAddess.isEmpty {
            self.getOTPForResetPassword()
        }else {
            self.resetThePassword()
        }
    }
    
    func getOTPForResetPassword() {
        guard let email = self.tfEmail.text, !email.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your email.")
            return
        }
        
        if !validateEmail(email) {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter a valid email address.")
            return
        }
        
        let model = ResetPasswordRequest()
        model.email = self.tfEmail.text
        model.otp = nil
        model.password = nil
        let apiService = ApiService.resetPasswordAPI(model: model)
        APIClient.requestWithCode(apiService) { [weak self] isSucess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if isSucess, code == 200 {
                    self.descLbl.isHidden = true
                    self.emailLbl.text = "Verify security code"
                    self.descTopLbl.constant = 0.0
                    self.descBottomLbl.constant = 10.0
                    self.userEmailAddess = self.tfEmail.text ?? ""
                    self.tfEmail.text = ""
                    self.tfEmail.placeholder = "Enter New Password"
                    self.tfOtpHeight.constant = 40.0
                    self.resetBtn.setTitle("Submit", for: .normal)
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    func resetThePassword() {
        guard let email = self.tfEmail.text, !email.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your password.")
            return
        }
        
        guard let otp = self.tfOtp.text, !otp.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your otp.")
            return
        }
        
        guard !userEmailAddess.isEmpty else { return }
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        let model = ResetPasswordRequest()
        model.email = self.userEmailAddess
        model.otp = self.tfOtp.text ?? ""
        model.password = self.tfEmail.text ?? ""
        let apiService = ApiService.resetPasswordAPI(model: model)
        APIClient.requestWithCode(apiService) { [weak self] isSucess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if isSucess, code == 200 {
                    scl.hideView()
                    let sclAlertView = SCLAlertView()
                    SCLAlertView.showSuccessAlert(title: "", message: "Password changed successfully", doneButtonTitle: "Done") { [weak self] in
                        guard let self else { return }
                        self.dismiss(animated: true)
                    }
                }else if code == 500 {
                    SCLAlertView().showError("Error", subTitle: "Incorrect security code")
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
