//
//  AddEnergyCostVC.swift
//  cafm
//
//  Created by ShitaRam on 20/10/24.
//

import UIKit
import SCLAlertView

class AddEnergyCostVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewMeter: TextFiledDataXib!
    @IBOutlet weak var viewBudget: TextFiledDataXib!
    @IBOutlet weak var viewFromDate: TextFiledDataXib!
    @IBOutlet weak var viewToDate: TextFiledDataXib!
    @IBOutlet weak var viewCost: TextFiledDataXib!
    
    let issueDatePicker = UIDatePicker()
    let expireDatePicker = UIDatePicker()
    
    var item: Energy?
    weak var homeVC: EnergyCostVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        guard let item else {return}
        self.viewMeter.lblTFName.text = "Meter Reference"
        self.viewMeter.tfData.text = item.reference
        self.viewMeter.tfData.backgroundColor = UIColor(.separator)
        self.viewMeter.tfData.isUserInteractionEnabled = false
        
        self.viewBudget.lblTFName.text = "Budget Category"
        self.viewBudget.tfData.text = item.budgetCategory
        self.viewBudget.tfData.backgroundColor = UIColor(.separator)
        self.viewBudget.tfData.isUserInteractionEnabled = false

        self.viewFromDate.lblTFName.text = "From Date"
        self.viewFromDate.tfData.delegate = self
        issueDatePicker.datePickerMode = .date
        issueDatePicker.preferredDatePickerStyle = .wheels // Optional: Choose the picker style
        issueDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Set the input view of the text field to the date picker
        self.viewFromDate.tfData.inputView = issueDatePicker
        
        self.viewFromDate.tfData.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonIssueDateClicked))

        
        self.viewToDate.lblTFName.text = "To Date"
        self.viewToDate.tfData.delegate = self
        
        
        expireDatePicker.datePickerMode = .date
        expireDatePicker.preferredDatePickerStyle = .wheels // Optional: Choose the picker style
        expireDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        self.viewToDate.tfData.inputView = expireDatePicker
        
        self.viewToDate.tfData.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonExpireDateClicked))
        
        self.viewCost.lblTFName.text = "Cost (GBP)"
        self.viewCost.tfData.keyboardType = .numberPad
        
    }
    
    @objc func doneButtonIssueDateClicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = self.issueDatePicker.date
        self.viewFromDate.tfData.text = formatter.string(from: self.issueDatePicker.date)
    }

    @objc func doneButtonExpireDateClicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = self.expireDatePicker.date
        self.viewToDate.tfData.text = formatter.string(from: self.expireDatePicker.date)
    }
    
    // Function called when the date picker value changes
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = sender.date
        
        if sender == issueDatePicker {
            viewFromDate.tfData.text = formatter.string(from: sender.date)
        }else {
            viewToDate.tfData.text = formatter.string(from: sender.date)
        }
    }

    
    @IBAction func btnSaveClick(_ sender: Any) {
        
        guard let cost = self.viewCost.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !cost.isEmpty else {
            showAlert(message: "Please enter cost")
            return
        }
        let newItem = EnergyUsage()
        newItem.cost = cost
        newItem.budgetCategory = item?.budgetCategory
        newItem.energyId = item?.energyId
        if let issueDate = viewFromDate.tfData.text, !issueDate.isEmpty {
            newItem.fromDate = (convertDateStringToNewString(from: "dd/MM/yy", originalDateString: issueDate, to: "yyyy-MM-dd") ?? "")+"T05:30:00.000Z"
        }
        if let toDate = viewToDate.tfData.text, !toDate.isEmpty {
            newItem.toDate = (convertDateStringToNewString(from: "dd/MM/yy", originalDateString: toDate, to: "yyyy-MM-dd") ?? "")+"T05:30:00.000Z"
        }
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        newItem.siteId = siteID
        newItem.submittedUserId = UserConstants.shared.currentUserID
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.addNewCostInreading(item: newItem)
        APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<Cost>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let user) = responseResult {
                        self.dismiss(animated: true)
                        self.homeVC?.handleFetchData()
                    }else {
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                case .failure(let error):
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
