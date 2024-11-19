//
//  AddNewCompanyVC.swift
//  cafm
//
//  Created by Savan Lakhani on 07/10/24.
//

import UIKit
import SCLAlertView

class AddNewCompanyVC: UIViewController {
    
    @IBOutlet weak var phoneXIB: TextFiledDataXib!
    @IBOutlet weak var companyNameXIB: TextFiledDataXib!
    @IBOutlet weak var emailXIB: TextFiledDataXib!
    
    @IBOutlet weak var actionBtnViewXIB: ActionBtnViewXIB!
    
    var companyDetail: CompanyDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add New Company"
        
        self.companyNameXIB.title = "Company Name"
        self.emailXIB.title = "Email"
        self.phoneXIB.title = "Phone"
        
        if let companyName = self.companyDetail?.companyName {
            self.companyNameXIB.tfData.text = companyName
        }
        
        if let email = self.companyDetail?.email {
            self.emailXIB.tfData.text = email
        }
        
        if let phone = self.companyDetail?.phone {
            self.phoneXIB.tfData.text = phone
        }
        
        self.phoneXIB.tfData.keyboardType = .numberPad
        
        self.actionBtnViewXIB.saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.actionBtnViewXIB.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
    }
    
    @objc func saveBtnTapped() {
        
        if self.companyNameXIB.tfData.text?.isEmpty ?? true {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Company Name is required")
            return
        }
        
        if self.emailXIB.tfData.text?.isEmpty ?? true {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Email is required")
            return
        }

        if !validateEmail(self.emailXIB.tfData.text ?? "") {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter a valid email address.")
            return
        }
        
        if self.phoneXIB.tfData.text?.isEmpty ?? true {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Phone is required")
            return
        }
        
        if self.phoneXIB.tfData.text?.count ?? 0 >= 11 {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false // if you dont want the close button use false
            )
            let scl = SCLAlertView(appearance: appearance)
            scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
            
            let model = CompanyDetails()
            model.companyName = self.companyNameXIB.tfData.text ?? ""
            model.email = self.emailXIB.tfData.text ?? ""
            model.phone = self.phoneXIB.tfData.text ?? ""
            
            let apiService = ApiService.manageCompanyAPI(model: model)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<Company>, Error>) in
                guard let self else { return }
                switch result {
                case .success(let mappableResult):
                    scl.hideView()
                    self.navigationController?.popViewController(animated: true)
                    break
                case .failure(let error):
                    scl.hideView()
                    break
                }
            }
        }else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Phone must be 11 digits")
        }

    }
    
    @objc func cancelBtnTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
