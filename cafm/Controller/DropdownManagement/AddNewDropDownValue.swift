//
//  AddNewDropDownValue.swift
//  cafm
//
//  Created by ShitaRam on 20/10/24.
//

import UIKit
import SCLAlertView

class AddNewDropDownValue: UIViewController {
    
    @IBOutlet weak var valueTF: TextFiledDataXib!
    @IBOutlet weak var descriptionTF: TextFiledDataXib!
    @IBOutlet weak var dependsTF: TextFiledDataXib!
    @IBOutlet weak var additionalTF: TextFiledDataXib!
    @IBOutlet weak var sortTF: TextFiledDataXib!
    
    var lovType = ""
    var id: Int?
    var data: DropDownModel?
    weak var homeVC: DropdownVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.valueTF.lblTFName.text = "Value"
        self.descriptionTF.lblTFName.text = "Description"
        self.dependsTF.lblTFName.text = "Depends On"
        self.additionalTF.lblTFName.text = "Additional Attribute"
        self.sortTF.lblTFName.text = "Sort Order"
        self.isModalInPresentation = true
        if let data = self.data {
            self.valueTF.tfData.text = data.lovValue
            self.descriptionTF.tfData.text = data.lovDesc
            self.dependsTF.tfData.text = data.attribite1
            self.additionalTF.tfData.text = data.attribite2
            self.sortTF.tfData.text = data.attribite3
        }
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        guard let valueText = self.valueTF.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            SCLAlertView().showError("Error", subTitle: "Please enter Value")
            return
        }
        guard let dependsText = self.dependsTF.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            SCLAlertView().showError("Error", subTitle: "Please enter Description")
            return
        }
        var item = DropDownSubCategory()
        item.lovType = self.lovType
        item.lovValue = valueText
        item.lovDesc = dependsText
        item.attribite1 = dependsTF.tfData.text ?? ""
        item.attribite2 = additionalTF.tfData.text ?? ""
        item.attribite3 = sortTF.tfData.text ?? ""
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        if let id = self.id {
            item.edit = true
            item.id = id
            let api = ApiService.editValueDropDown(id: id, item: item)
            APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<DropDownSubCategory>, Error>) in
                DispatchQueue.main.async { [weak self] in
                    scl.hideView()
                    guard let self else {return}
                    switch result {
                    case .success(let responseResult):
                        if case .single(let user) = responseResult {
                            self.homeVC?.fetchData()
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
        }else {
            item.add = true
            let api = ApiService.addnewValueDropDown(item: item)
            APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<DropDownSubCategory>, Error>) in
                DispatchQueue.main.async { [weak self] in
                    scl.hideView()
                    guard let self else {return}
                    switch result {
                    case .success(let responseResult):
                        if case .single(let user) = responseResult {
                            self.homeVC?.fetchData()
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

    }
    
    @IBAction func clickOnClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
