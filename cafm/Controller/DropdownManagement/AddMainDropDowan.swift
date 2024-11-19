//
//  AddMainDropDowan.swift
//  cafm
//
//  Created by ShitaRam on 20/10/24.
//

import UIKit
import SCLAlertView

class AddMainDropDowan: UIViewController {

    @IBOutlet weak var viewType: TextFiledDataXib!
    @IBOutlet weak var viewValue: TextFiledDataXib!
    @IBOutlet weak var viewDepends: TextFiledDataXib!
    @IBOutlet weak var viewAdditionalAtt: TextFiledDataXib!
    
    weak var homeVC: DropdownVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.viewType.lblTFName.text = "Type"
        self.viewValue.lblTFName.text = "Value"
        self.viewDepends.lblTFName.text = "Depends On"
        self.viewAdditionalAtt.lblTFName.text = "Additional Attribute"
    }
    
    
    @IBAction func btnSaveClick(_ sender: Any) {
        guard let type = self.viewType.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !type.isEmpty else {
            SCLAlertView().showError("Error", subTitle: "Please enter Type")
            return
        }
        guard let value = self.viewValue.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            SCLAlertView().showError("Error", subTitle: "Please enter Value")
            return
        }
        var item = DropDownSubCategory()
        item.lovType = type
        item.lovValue = value
        item.attribite1 = viewDepends.tfData.text
        item.attribite2 = viewAdditionalAtt.tfData.text
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.addNewDropDown(item: item)
        APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<DropDownSubCategory>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let user) = responseResult {
                        self.homeVC?.fetchMainCategory()
                        self.dismiss(animated: true)
                    }else {
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                case .failure(let error):
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
