//
//  ResetPassWordVC.swift
//  cafm
//
//  Created by ShitaRam on 29/09/24.
//

import UIKit
import SCLAlertView

class ResetPassFromAdminVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    var userId: Int = 0
    var emailID: String = ""
    
    weak var delegate: AddAndUpdateUserDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfPassword.delegate = self
        
        
        self.tfEmail.keyboardType = .emailAddress
        self.tfPassword.isSecureTextEntry = true
        
        self.emailLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.passwordLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.signInButton.titleLabel?.font = UIFont(name: .MontserratMedium, size: 15)
        self.tfEmail.text = emailID

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: 13) as Any,
            .foregroundColor: UIColor(appColor: .GrayText)
        ]
        self.tfPassword.attributedPlaceholder = NSAttributedString(string: "6+ Characters, 1 Capital letter", attributes: attributes)
        self.tfEmail.attributedPlaceholder = NSAttributedString(string: "Enter your email", attributes: attributes)

        addCornerToView(self.tfEmail, value: 7)
        addCornerToView(self.tfPassword, value: 7)
        addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addCornerToView(self.signInButton, value: 7)
        

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail {
            addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .AppTint))
            addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .GrayStatusBG))
        }else if textField == self.tfPassword {
            addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .AppTint))
            addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .GrayStatusBG))
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = self.tfEmail.text, !email.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your email.")
            return
        }
        
        guard let password = self.tfPassword.text, !password.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your password.")
            return
        }
        
        // Validate email and password
        if !validateEmail(email) {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter a valid email address.")
            return
        }
        
        if !validatePassword(password) {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Password must be at least 6 characters long and contain at least one uppercase letter.")
            return
        }
        
        let requestModel = LoginRequestModel()
        requestModel.password = password
        requestModel.email = email
        
        let loginService = ApiService.resetPassWordFromHome(userId: userId, password: password)
                
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        APIClient.request(loginService) { (result: Result<APIClient.MappableResult<LoginUserDetail>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single(let loginDetail):
                        sclAlert.hideView()
                        self.delegate?.passwordResteSucessFully()
                    case .array(_):
                        break
                    }
                case .failure(let error):
                    sclAlert.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
