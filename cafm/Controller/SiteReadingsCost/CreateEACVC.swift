//
//  CreateEACVC.swift
//  cafm
//
//  Created by ShitaRam on 20/10/24.
//

import UIKit
import SCLAlertView

class CreateEACVC: UIViewController {
    
    @IBOutlet weak var viewName: TextFiledDataXib!    
    @IBOutlet weak var cateView: OptionBtnXib!
    
    var selectedCategoryID = 0
    var category: [EnergyCostBudgetCategory] = []
    weak var homeVC: SiteReadingsCostVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if category.isEmpty {
            getCategory()
        }
        viewName.lblTFName.text = "Energy Meter Reference"
        cateView.lblText.text = "Budget Category"
        setCategoryXib()
    }
    
    func setCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Budget Category", state: selectedCategoryID == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectedCategoryID = 0
                self.cateView.lblText.text = "Budget Category"
                self.setCategoryXib()
            }
        }))
        for (key,item) in category.enumerated() {
            actions.append(UIAction(title: item.lovValue ?? "No Name", state: selectedCategoryID == item.id ?? 0 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedCategoryID = item.id ?? 0
                    self.cateView.lblText.text = item.lovValue
                    self.setCategoryXib()
                }
            }))
        }
        cateView.btnDownClick.menu = UIMenu(title: "", children: actions)
        cateView.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func getCategory() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.energyCostCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<EnergyCostBudgetCategory>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let response):
                        print("response category \(response)")
                        self.category = response
                        setCategoryXib()
                        break
                    default:
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                }
            }
        }
    }

    
    @IBAction func btnCreateSiteClick(_ sender: Any) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        guard let name = viewName.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            SCLAlertView().showError("Error", subTitle: "Please enter Energy Meter Reference")
            return
        }
        guard selectedCategoryID != 0, let budgetCategory = category.first(where: {$0.id == selectedCategoryID})?.lovValue  else {
            SCLAlertView().showError("Error", subTitle: "Please select Budget Category")
            return
        }
        let item = ReqEnrAndCostModel()
        item.siteId = siteID
        item.reference = name
        item.searchField = ""
        item.budgetCategory = budgetCategory
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.createNewEnrReading(item: item)
        APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<SiteEnergySurvey>, Error>) in
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
                }
            }
        }
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
