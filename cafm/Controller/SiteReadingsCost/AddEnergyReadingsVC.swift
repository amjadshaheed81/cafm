//
//  AddEnergyReadingsVC.swift
//  cafm
//
//  Created by ShitaRam on 21/10/24.
//

import UIKit
import SCLAlertView

class AddEnergyReadingsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewMeter: TextFiledDataXib!
    @IBOutlet weak var viewUsage: TextFiledDataXib!
    @IBOutlet weak var viewBudget: TextFiledDataXib!
    @IBOutlet weak var viewReadingDate: TextFiledDataXib!
    @IBOutlet weak var viewReading: TextFiledDataXib!
    
    @IBOutlet weak var unitValue: OptionBtnXib!
    
    enum ReadingUnit: String {
        case readingUnit = "Reading Unit"
        case Kwh = "Kwh"
        case M3 = "M³"
        case ltrs = "ltrs"
    }
    let unitArry: [ReadingUnit] = [.readingUnit,.Kwh,.M3,.ltrs]
    
    var selectedUnit = 0
    
    let issueDatePicker = UIDatePicker()
    
    var item: Energy?
    var homeVC: EnergyReadingVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else {
            return
        }
        self.isModalInPresentation = true
        self.viewMeter.lblTFName.text = "Meter Reference"
        self.viewMeter.tfData.text = item.reference
        self.viewMeter.tfData.backgroundColor = UIColor(.separator)
        self.viewMeter.tfData.isUserInteractionEnabled = false
        
        self.viewUsage.lblTFName.text = "Usage"
        self.viewUsage.tfData.text = "0"
        self.viewUsage.tfData.backgroundColor = UIColor(.separator)
        self.viewUsage.tfData.isUserInteractionEnabled = false
        
        self.viewBudget.lblTFName.text = "Budget Category"
        self.viewBudget.tfData.text = item.budgetCategory
        self.viewBudget.tfData.backgroundColor = UIColor(.separator)
        self.viewBudget.tfData.isUserInteractionEnabled = false
        
        
        self.viewReadingDate.lblTFName.text = "Reading Date"
        self.viewReadingDate.tfData.delegate = self
        issueDatePicker.datePickerMode = .date
        issueDatePicker.preferredDatePickerStyle = .wheels // Optional: Choose the picker style
        issueDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        self.viewReadingDate.tfData.inputView = issueDatePicker
        self.viewReadingDate.tfData.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonIssueDateClicked))
        
        self.viewReading.lblTFName.text = "Reading"
        self.viewReading.tfData.delegate = self
        self.viewReading.tfData.keyboardType = .numberPad
        
        unitValue.lblText.text = "Reading Unit"
        setUpTypeIOEXib()
    }
    
    func setUpTypeIOEXib() {
        var actions = [UIAction]()
        let array = unitArry
        for (key,item) in array.enumerated() {
            actions.append(UIAction(title: item.rawValue, state: key == selectedUnit ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedUnit = key
                    self.unitValue.lblText.text = item.rawValue
                    self.setUpTypeIOEXib()
                }
            }))
        }
        unitValue.btnDownClick.menu = UIMenu(title: "", children: actions)
        unitValue.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.viewReading.tfData {
            // Get the updated text after the change
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
            print("rk : \(updatedText)")
            if let value = Double(updatedText){
                self.viewUsage.tfData.text = calculateValue(value: value)
            }
        }

        return true
    }

    
    @objc func doneButtonIssueDateClicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = self.issueDatePicker.date
        self.viewReadingDate.tfData.text = formatter.string(from: self.issueDatePicker.date)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = sender.date
        if sender == issueDatePicker {
            viewReadingDate.tfData.text = formatter.string(from: sender.date)
        }
    }
    
    func calculateValue(value: Double) -> String {
        guard let calculete = item?.readingList?.last?.readingValue else {
            return "0"
        }
        return "\(String(format: "%.2f", value - calculete))"
    }

    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func brnSaveClick(_ sender: Any) {
        guard let value = Double(self.viewReading.tfData.text ?? "") else {
            showAlert(message: "Please enter Reading")
            return
        }
        if self.selectedUnit == 0  {
            showAlert(message: "Please enter Reading Unit")
            return
        }
        let newItem = ReqEnergyReading()
        newItem.energyId = self.item?.energyId
        if let issueDate = viewReadingDate.tfData.text, !issueDate.isEmpty {
            newItem.readingDate = (convertDateStringToNewString(from: "dd/MM/yy", originalDateString: issueDate, to: "yyyy-MM-dd") ?? "")+"T05:30:00.000Z"
        }
        let array = ["Kwh", "M3", "ltrs"]
        newItem.readingUnit = array[self.selectedUnit-1]
        newItem.readingValue = ("\(Int(value))")
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
        let api = ApiService.addRedingInreading(item: newItem)
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
        
}
