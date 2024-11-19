//
//  SiteContractsVC.swift
//  cafm
//
//  Created by Savan Lakhani on 14/09/24.
//

import UIKit
import SpreadsheetView

class SiteContractsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txField1: UITextField!

    @IBOutlet weak var viewSubCategoryXIB: OptionBtnXib!
    @IBOutlet weak var viewCategoryXIB: OptionBtnXib!
    @IBOutlet weak var viewStatusXIB: OptionBtnXib!
    
    @IBOutlet weak var viewSubCategoryWidth: NSLayoutConstraint!
    @IBOutlet weak var viewSubCategoryLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var createNewContractHeight: NSLayoutConstraint!
    @IBOutlet weak var switchViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var createNewView: UIControl!
    @IBOutlet weak var exportView: UIControl!

    @IBOutlet weak var createNewLbl: UILabel!
    @IBOutlet weak var exportLbl: UILabel!
    
    @IBOutlet weak var selectedSiteLbl: UILabel!
    @IBOutlet weak var allLbl: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var switchMainView: UIView!
    
    
    @IBOutlet weak var spreedSheetView: SpreadsheetView!
    
    var siteContractsCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var siteContractsSubCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var siteContractsDetailArray: [ProjectContract] = []
    var siteContractsDetailArrayList: [ProjectContract] = []
    
    var headerRowArray = ["SUMMARY", "CATAGORY", "SUBCATAGORY", "COMPANY", "START DAATE", "END DATE", "COST", "STATUS", "ACTION"]
    
    var searchCategotyInd = 0 {
        didSet {
            if searchCategotyInd != 0 {
                self.viewSubCategoryWidth.constant = self.createNewView.frame.width
                self.viewSubCategoryLeadingCons.constant = 10.0
                self.searchSubCategotyInd = 0
                self.viewSubCategoryXIB.lblText.text = "Sub Category"
                self.setSubContractsCategoryXib()
            }else {
                self.viewSubCategoryWidth.constant = 0.0
                self.viewSubCategoryLeadingCons.constant = 0.0
                self.searchSubCategotyInd = 0
                self.viewSubCategoryXIB.lblText.text = "Sub Category"
                self.setSubContractsCategoryXib()
            }
        }
    }
    
    var searchSubCategotyInd = 0
    var searchStatusInd = 0
    
    enum Status: String {
        case status = "Status"
        case active = "Active"
        case expired = "Expired"
        case terminated = "Terminated"
    }
    
    var loadingStatus: LoadingStatus = .loading

    var isDataNotReceive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var searchStatus: Status = .status

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
    }
    
    func initialSetUp() {
        self.title = "Site Contracts"
        
        self.createNewLbl.font = UIFont(name: .MontserratMedium, size: textFontSize)
        self.exportLbl.font = UIFont(name: .MontserratMedium, size: textFontSize)
        
        self.viewCategoryXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewSubCategoryXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewStatusXIB.addBorder(color: .gray.withAlphaComponent(0.3))

        self.txField1.addCorner()
        self.txField1.addBorder(color: .gray.withAlphaComponent(0.3))
        self.txField1.addCorner()
        self.viewSubCategoryXIB.addCorner()
        self.viewCategoryXIB.addCorner()
        self.viewStatusXIB.addCorner()
        self.exportView.addCorner()
        self.createNewView.addCorner()
        
        self.txField1.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewSubCategoryXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewCategoryXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewStatusXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.allLbl.font = UIFont(name: .MontserratMedium, size: 17)
        self.selectedSiteLbl.font = UIFont(name: .MontserratMedium, size: 17)
        
        self.txField1.placeholder = "Search"
        self.txField1.text = ""
        self.viewCategoryXIB.lblText.text = "Category"
        self.viewSubCategoryXIB.lblText.text = "Sub Category"
        self.viewStatusXIB.lblText.text = "Status"
        
        self.txField1.delegate = self

        self.viewSubCategoryWidth.constant = 0.0
        self.viewSubCategoryLeadingCons.constant = 0.0
        
        self.setStatusXib()
        
        //api calling
        self.loadCategoryDetail()
        self.loadSubCategoryDetail()
        self.getSiteContractsDetails()
        self.loadContracterContractDetail()
        
        self.setUpSpreedSheetView()
        
        self.switch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    func setStatusXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: Status.status.rawValue, state: searchStatus == .status ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .status
                self.viewStatusXIB.lblText.text = Status.status.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.active.rawValue, state: searchStatus == .active ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .active
                self.viewStatusXIB.lblText.text = Status.active.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.expired.rawValue, state: searchStatus == .expired ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .expired
                self.viewStatusXIB.lblText.text = Status.expired.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.terminated.rawValue, state: searchStatus == .terminated ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .terminated
                self.viewStatusXIB.lblText.text = Status.terminated.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))

        self.viewStatusXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewStatusXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Category", state: searchCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewCategoryXIB.lblText.text = "Category"
                self.searchCategotyInd = 0
                self.setContractsCategoryXib()
                self.searchFilter(searchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()

        for (key,item) in self.siteContractsCategoryResponseArray.enumerated() {
            let area = item.lovValue ?? "No Category"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.viewCategoryXIB.lblText.text = item.lovValue
                    self.searchCategotyInd = key + 1
                    self.setContractsCategoryXib()
                    self.searchFilter(searchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        self.viewCategoryXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewCategoryXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setSubContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Sub Category", state: searchSubCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewSubCategoryXIB.lblText.text = "Sub Category"
                self.searchSubCategotyInd = 0
                self.setSubContractsCategoryXib()
                self.searchFilter(searchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seensubCategory = Set<String?>()
        
        for (key,item) in self.siteContractsSubCategoryResponseArray.enumerated() {
            if self.viewCategoryXIB.lblText.text?.lowercased() == item.lovDesc?.lowercased() {
                let subCategory = item.lovValue ?? "No Sub Category"
                
                if seensubCategory.contains(subCategory) {
                    continue
                }
                
                seensubCategory.insert(subCategory)
                
                actions.append(UIAction(title: subCategory, state: searchSubCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchSubCategotyInd = key + 1
                        self.viewSubCategoryXIB.lblText.text = item.lovValue
                        self.setSubContractsCategoryXib()
                        self.searchFilter(searchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    }
                }))
            }
        }
        self.viewSubCategoryXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewSubCategoryXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.searchFilter(searchText: updatedText)
        return true
    }
    
    func searchFilter(searchText: String) {
        if self.siteContractsDetailArray.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if searchText == "" {
                self.siteContractsDetailArrayList = self.siteContractsDetailArray
            }else {
                self.siteContractsDetailArrayList = siteContractsDetailArray.filter({ user in
                    user.summary?.lowercased().contains(searchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.summary?.lowercased() ?? ""
                    let name2 = user2.summary?.lowercased() ?? ""
                    
                    // Check if either name starts with the search text
                    let startsWith1 = name1.hasPrefix(searchText.lowercased())
                    let startsWith2 = name2.hasPrefix(searchText.lowercased())
                    
                    // Sort by whether the name starts with the search text
                    if startsWith1 && !startsWith2 {
                        return true
                    } else if !startsWith1 && startsWith2 {
                        return false
                    } else {
                        // If both or neither start with the search text, preserve original order or sort alphabetically
                        return name1 < name2
                    }
                }
            }
            
            if self.viewCategoryXIB.lblText.text != "Category" {
                self.siteContractsDetailArrayList = self.siteContractsDetailArrayList.filter({ user in
                    (user.category?.lowercased() ?? "") == self.viewCategoryXIB.lblText.text?.lowercased()
                })
            }
            
            if self.viewSubCategoryXIB.lblText.text != "Sub Category" {
                self.siteContractsDetailArrayList = self.siteContractsDetailArrayList.filter({ user in
                    (user.subCategory?.lowercased() ?? "") == self.viewSubCategoryXIB.lblText.text?.lowercased()
                })
            }
                        
            if searchStatus != .status {
                self.siteContractsDetailArrayList = self.siteContractsDetailArrayList.filter({ user in
                    (user.status?.lowercased() ?? "") == self.searchStatus.rawValue.lowercased()
                })
            }
            if siteContractsDetailArrayList.isEmpty {
                self.loadingStatus = .noResponse
            }else {
                self.loadingStatus = .default
            }
            self.spreedSheetView.reloadData()
        }
    }
    
    func setUpSpreedSheetView() {
        self.spreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        self.spreedSheetView.register(UINib(nibName: String(describing: StatusXIb.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StatusXIb.self))
        self.spreedSheetView.register(UINib(nibName: String(describing: ViewActionBtnXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ViewActionBtnXIB.self))
        self.spreedSheetView.bounces = false
        self.spreedSheetView.dataSource = self
        self.spreedSheetView.delegate = self
        self.spreedSheetView.showsHorizontalScrollIndicator = false
        self.spreedSheetView.showsVerticalScrollIndicator = false
        self.spreedSheetView.addCorner()
        self.spreedSheetView.addBorder(color: .gray.withAlphaComponent(0.4))
    }
    
    
    @IBAction func createNewContractsAction(_ sender: Any) {
        let vc = siteContractsSB.instantiateViewController(withIdentifier: "CreateContractsVC") as! CreateContractsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadCategoryDetail() {
        let apiService = ApiService.getProjectContractsCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.viewCategoryXIB.lblText.text = "Category"
                        self.siteContractsCategoryResponseArray = siteContractsCategotyArray
                        self.setContractsCategoryXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadSubCategoryDetail() {
        let apiService = ApiService.getProjectContractSubCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.viewSubCategoryXIB.lblText.text = "Sub Category"
                        self.siteContractsSubCategoryResponseArray = siteContractsCategotyArray
                        self.setSubContractsCategoryXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getSiteContractsDetails() {
        guard UserDefaults.standard.userRole != .contractor else { return }
        self.switchViewHeight.constant = 0.0
        self.switchMainView.isHidden = true
        
        self.loadingStatus = .loading
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.projectContractsAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    strongSelf.loadingStatus = .failed
                    break
                case .single(let single):
                    if let array = single.projectContracts {
                        if array.isEmpty {
                            strongSelf.loadingStatus = .noResponse
                        }else {
                            strongSelf.loadingStatus = .default
                            if UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers {
                                strongSelf.siteContractsDetailArray = array.filter({$0.contractorCompanyName == UserConstants.shared.userDetail?.companyName})
                                strongSelf.siteContractsDetailArrayList = array.filter({$0.contractorCompanyName == UserConstants.shared.userDetail?.companyName})
                            }else {
                                strongSelf.siteContractsDetailArray = array
                                strongSelf.siteContractsDetailArrayList = array
                            }
                            
                            strongSelf.searchFilter(searchText: strongSelf.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                        }
                        strongSelf.spreedSheetView.reloadData()
                    }else {
                        strongSelf.loadingStatus = .noResponse
                        strongSelf.spreedSheetView.reloadData()
                    }
                    break
                }
            case .failure(let error):
                self?.loadingStatus = .failed
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadContracterContractDetail() {
        guard UserDefaults.standard.userRole == .contractor else { return }
        self.createNewContractHeight.constant = 0.0
        self.loadingStatus = .loading
        
        guard let contractId = UserConstants.shared.userDetail?.companyId else {
            self.loadingStatus = .failed
            return
        }

        let apiService = ApiService.contracterContractsDetails(contractId: contractId)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    strongSelf.loadingStatus = .failed
                    break
                case .single(let single):
                    if let array = single.projectContracts {
                        if array.isEmpty {
                            strongSelf.loadingStatus = .noResponse
                        }else {
                            strongSelf.loadingStatus = .default
                            strongSelf.siteContractsDetailArray = array
                            strongSelf.siteContractsDetailArrayList = array
                            
                            strongSelf.searchFilter(searchText: strongSelf.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                        }
                        strongSelf.spreedSheetView.reloadData()
                    }
                    break
                }
            case .failure(let error):
                self?.loadingStatus = .failed
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            guard UserDefaults.standard.userRole == .contractor else { return }
            self.loadingStatus = .loading
            self.spreedSheetView.reloadData()
            
            guard let contractId = UserConstants.shared.userDetail?.companyId else {
                self.loadingStatus = .failed
                return
            }
            
            guard let siteID = UserConstants.shared.selectedSiteID else {
                self.loadingStatus = .failed
                return
            }

            let apiService = ApiService.getSelectedSiteContractDetails(siteId: siteID, contractId: contractId, area: nil)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array:
                        strongSelf.loadingStatus = .failed
                        break
                    case .single(let single):
                        if let array = single.projectContracts {
                            if array.isEmpty {
                                strongSelf.loadingStatus = .noResponse
                            }else {
                                strongSelf.loadingStatus = .default
                                strongSelf.siteContractsDetailArray = array
                                strongSelf.siteContractsDetailArrayList = array
                                
                                strongSelf.searchFilter(searchText: strongSelf.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                            }
                            strongSelf.spreedSheetView.reloadData()
                        }else {
                            strongSelf.siteContractsDetailArray = []
                            strongSelf.siteContractsDetailArrayList = []
                            strongSelf.loadingStatus = .noResponse
                            strongSelf.spreedSheetView.reloadData()
                        }
                        break
                    }
                case .failure(let error):
                    self?.loadingStatus = .failed
                    print("Error: \(error.localizedDescription)")
                }
            }
        } else {
            self.loadContracterContractDetail()
        }
    }
    
}

extension SiteContractsVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerRowArray.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if !self.siteContractsDetailArrayList.isEmpty {
                return self.siteContractsDetailArrayList.count + 1
            }
            return 1 + 1
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray = ["Loading..."]
            stringsArray.append(headerRowArray[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.summary}
                stringsArray.append(headerRowArray[column])
            }else if column == 1 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.category}
                stringsArray.append(headerRowArray[column])
            }else if column == 2 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.subCategory}
                stringsArray.append(headerRowArray[column])
            }else if column == 3 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.contractorCompanyName}
                stringsArray.append(headerRowArray[column])
            }else if column == 4 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.startDate}
                stringsArray.append(headerRowArray[column])
            }else if column == 5 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.endDate}
                stringsArray.append(headerRowArray[column])
            }else if column == 6 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.cost}
                stringsArray.append(headerRowArray[column])
            }else if column == 7 {
                stringsArray = self.siteContractsDetailArrayList.compactMap{$0.status}
                stringsArray.append(headerRowArray[column])
            }
            if column != 8 {
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else if column == 8 {
                return 120
            }else {
                return 0.0
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let textArray = self.headerRowArray
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = self.headerRowArray
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: [(siteContractsDetailArrayList[row-1].summary),(siteContractsDetailArrayList[row-1].category),(siteContractsDetailArrayList[row-1].subCategory),(siteContractsDetailArrayList[row-1].contractorCompanyName),(siteContractsDetailArrayList[row-1].startDate),(siteContractsDetailArrayList[row-1].endDate),(siteContractsDetailArrayList[row-1].cost),(siteContractsDetailArrayList[row-1].status)])
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = headerRowArray[indexPath.section]
            return cell
        } else if indexPath.row == 1 && isDataNotReceive {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = UIColor.white
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = loadingStatus.rawValue
            if loadingStatus == .noResponse && !self.siteContractsDetailArrayList.isEmpty {
                cell.lblText.text = "No search result found!!"
            }
            return cell
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7 || indexPath.section == 8 {
            
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.backgroundColor = UIColor.clear
            
            if indexPath.section == 0 {
                cell.lblText.text = self.siteContractsDetailArrayList[indexPath.row-1].summary
            }else if indexPath.section == 1 {
                cell.lblText.text = self.siteContractsDetailArrayList[indexPath.row-1].category
            }else if indexPath.section == 2 {
                cell.lblText.text = self.siteContractsDetailArrayList[indexPath.row-1].subCategory
            }else if indexPath.section == 3 {
                cell.lblText.text = self.siteContractsDetailArrayList[indexPath.row-1].contractorCompanyName
            }else if indexPath.section == 4 {
                if let startDate = self.siteContractsDetailArrayList[indexPath.row-1].startDate {
                    cell.lblText.text = formatDateString(startDate) ?? startDate
                }
            }else if indexPath.section == 5 {
                if let endDate = self.siteContractsDetailArrayList[indexPath.row-1].endDate {
                    cell.lblText.text = formatDateString(endDate) ?? endDate
                }
            }else if indexPath.section == 6 {
                cell.lblText.text = self.siteContractsDetailArrayList[indexPath.row-1].cost
            }else if indexPath.section == 7 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
                cell.setUp(string: self.siteContractsDetailArrayList[indexPath.row - 1].status ?? "")
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                return cell
            }else if indexPath.section == 8 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ViewActionBtnXIB", for: indexPath) as! ViewActionBtnXIB
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                
                cell.viewActionBtn.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let projectContractId = self.siteContractsDetailArrayList[row].projectContractId {
                            self.goFurther(projectContractId: projectContractId)
                        }
                    }
                }

                return cell
            }
            return cell
        }
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
        cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRowArray.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
}

extension SiteContractsVC {
    
    func goFurther(projectContractId: Int) {
        let vc = siteContractsSB.instantiateViewController(withIdentifier: "CreateContractsVC") as! CreateContractsVC
        vc.projectContractId = projectContractId
        vc.isForViewOnly = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
