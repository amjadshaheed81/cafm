//
//  AddNewUserVC.swift
//  cafm
//
//  Created by ShitaRam on 25/08/24.
//

import UIKit
import SearchTextField
import SCLAlertView

class AddNewUserVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewNameXib: TextFiledDataXib!
    @IBOutlet weak var viewLastNXib: TextFiledDataXib!
    @IBOutlet weak var viewEmailXib: TextFiledDataXib!
    @IBOutlet weak var viewPasswordXib: TextFiledDataXib!
    @IBOutlet weak var heightOfPasswordView: NSLayoutConstraint!
    
    @IBOutlet weak var viewPhoneXib: TextFiledDataXib!
    
    
    @IBOutlet weak var viewRoleXib: OptionBtnXib!
    @IBOutlet weak var viewTypeIOEXib: OptionBtnXib!
    @IBOutlet weak var viewStatusXib: OptionBtnXib!
    @IBOutlet weak var switchCompany: UISwitch!
    
    
    @IBOutlet weak var searchTextFiled: SearchTextField!
    
    @IBOutlet weak var viewTagSiteMainBG: UIView!
    @IBOutlet weak var heightOfCVMainBG: NSLayoutConstraint!
    
    @IBOutlet weak var cvTagSite: UICollectionView!
    
    
    @IBOutlet weak var viewMainTradeBG: UIView!
    @IBOutlet weak var heightMainTradeBG: NSLayoutConstraint!
    @IBOutlet weak var viewTradeXib: OptionBtnXib!
    
    
    var selectUserRole: UserEnum = .role
    var userTypeArray = UserEnum.userTypeArray
    var siteDetailsArray = [SiteModel]()
    var selectedSiteDetailsArray = [SiteModel]()
    
    enum TypeInternalExternal: String {
        case notSelect = "Select Internal/External"
        case `internal` = "Internal"
        case external = "External"
    }
    var selectIOEType : TypeInternalExternal = .notSelect
    
    var selectedTradeType = TradeTypeEnum.na
    enum TradeTypeEnum: String {
        case na = "NA"
        case electrician = "Electrician"
        case gasEngineer = "Gas Engineer"
        case asbestosSurveyor = "Asbestos Surveyor"
        case aCEngineer = "AC Engineer"
        case fireDoorInstall = "Fire Door Install"
        case generalCompany = "General Company"
        case lifeMaintenance = "Life Maintenance"
        case plumber = "Plumber"
        case autoDoorMaintanance = "Auto Door Maintanance"
        case refuseCollector = "Refuse Collector"
        case fireAlarm = "Fire Alarm"
        
        static var tradeArray: [TradeTypeEnum] = [.na,.electrician,.gasEngineer,.asbestosSurveyor, .aCEngineer, .fireDoorInstall, .generalCompany, .lifeMaintenance,.plumber,.autoDoorMaintanance,.refuseCollector,.fireAlarm]
        
    }
    
    
    enum Status: String {
        case status = "Select Status"
        case active = "Active"
        case inactive = "Inactive"
    }
    var selectStatus: Status = .status
    
    
    @IBOutlet weak var viewCompanyMainBG: UIView!        
    @IBOutlet weak var tfSearchCompany: SearchTextField!
    @IBOutlet weak var heightofCompanyMainBG: NSLayoutConstraint!
    
    
    var companyDetailsArray = [Company]()
    var selectedCompany: Company?
    
    weak var delegate: AddAndUpdateUserDelegate?
    weak var user: User?
    
    var availableSite: [Int] = []
    
    var isOnlyView = false
    var isEditProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil {
            self.title = "Add User"
        }else {
            if isOnlyView {
                self.title = "View User Details"
            }else if isEditProfile {
                self.title = "Edit Profile"
            }else {
                self.title = "Update User"
            }
        }
        self.cvTagSite.delegate = self
        self.cvTagSite.dataSource = self
        siteDetailsSetUp()
        companySetUp()
        loadSiteDetailsData()
        viewRoleXib.lblText.text = "Select Role"
        viewTypeIOEXib.lblText.text = "Select Internal/External"
        viewTradeXib.lblText.text = selectedTradeType.rawValue
        viewStatusXib.lblText.text = "Select Status"
        viewTypeIOEXib.lblText.text = selectIOEType.rawValue
        setUpTextFiledXib()
        setUpForUpdateUserDetails()
        setUpRoleXib()
        setUpTypeIOEXib()
        setUpTradeEXib()
        setStatusXib()
        if selectIOEType == .external {
            self.viewMainTradeBG.isHidden = false
            self.heightMainTradeBG.constant = 76
        }else {
            self.viewMainTradeBG.isHidden = true
            self.heightMainTradeBG.constant = 0
        }
        if switchCompany.isOn || selectedCompany != nil {
            switchCompany.isOn = true
            self.heightofCompanyMainBG.constant = 76
            self.viewCompanyMainBG.isHidden = false
        }else {
            self.heightofCompanyMainBG.constant = 0
            self.viewCompanyMainBG.isHidden = true
            self.selectedCompany = nil
            self.tfSearchCompany.text = ""
        }
        if isOnlyView {
            setUpView()
        }else {
            let rightBarButton = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(buttonTapped))
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    func setUpView() {
        self.viewNameXib.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewNameXib.isUserInteractionEnabled = false
        self.viewLastNXib.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewLastNXib.isUserInteractionEnabled = false

        self.viewEmailXib.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewEmailXib.isUserInteractionEnabled = false

        self.viewPasswordXib.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewPasswordXib.isUserInteractionEnabled = false

        self.viewPhoneXib.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewPhoneXib.isUserInteractionEnabled = false

        self.viewRoleXib.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewRoleXib.isUserInteractionEnabled = false

        self.viewTypeIOEXib.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.viewTypeIOEXib.isUserInteractionEnabled = false

        self.viewTradeXib.isUserInteractionEnabled = false
//        self.cvTagSite.isUserInteractionEnabled = false
        self.searchTextFiled.isUserInteractionEnabled = false
        self.viewStatusXib.isUserInteractionEnabled = false
        self.switchCompany.isUserInteractionEnabled = false
        self.tfSearchCompany.isUserInteractionEnabled = false
    }
    
    func setUpForUpdateUserDetails() {
        if let user = self.user {
            if let name = self.user?.name, !name.isEmpty {
                self.viewNameXib.tfData.text = splitName(fullName: name).firstName
                self.viewLastNXib.tfData.text = splitName(fullName: name).lastName
            }
            self.viewEmailXib.tfData.text = self.user?.email
            self.heightOfPasswordView.constant = 0
            self.viewPhoneXib.tfData.text = self.user?.phone
            if let user = user.role, let item = UserEnum(rawValue: user) {
                self.selectUserRole = item
                self.viewRoleXib.lblText.text = item.rawValue
            }
            if let user = user.userType, let item = TypeInternalExternal(rawValue: user) {
                selectIOEType = item
                viewTypeIOEXib.lblText.text = selectIOEType.rawValue
            }
            if let trade = user.trade, let item = TradeTypeEnum(rawValue: trade) {
                selectedTradeType = item
                self.viewTradeXib.lblText.text = item.rawValue
            }
            if let status = user.status, let item = Status(rawValue: status) {
                self.selectStatus = item
                self.viewStatusXib.lblText.text = self.selectStatus.rawValue
            }
        }
    }
    
    @objc func buttonTapped() {
        print("Navigation bar button tapped")
        var request = AddUserRequet()
        if let text = viewNameXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            request.firstName = text.replacingOccurrences(of: " ", with: "-")
        }else {
            SCLAlertView().showError("Error", subTitle: "Please enter your First Name.")
            return
        }
        if let text = viewLastNXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            request.lastName = text.replacingOccurrences(of: " ", with: "-")
        }else {
            SCLAlertView().showError("Error", subTitle: "Please enter your Last Name.")
            return
        }
        if let text = viewEmailXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty && validateEmail(text) {
            request.email = text
        }else {
            SCLAlertView().showError("Error", subTitle: "Please enter a valid email address.")
            return
        }
        if user == nil {
            if let text = viewPasswordXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty, validatePassword(text) {
                request.password = text
            }else {
                SCLAlertView().showError("Error", subTitle: "Password must be at least 6 characters long and contain at least one uppercase letter.")
                return
            }
        }else {
            request.userId = self.user?.id
            request.defaultSiteId = self.user?.defaultSiteId
        }
        if let text = viewPhoneXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), let number = Double(text) {
            request.phone = CGFloat(number)
        }else {
            SCLAlertView().showError("Error", subTitle: "Please enter a valid number")
            return
        }
        if selectUserRole != .role {
            request.role = selectUserRole.rawValue
        }else {
            SCLAlertView().showError("Error", subTitle: "Please Select role")
            return
        }
        if selectIOEType != .notSelect {
            request.userType = selectIOEType.rawValue
            if selectIOEType == .external {
                request.trade = selectedTradeType == .na ? "" : selectedTradeType.rawValue
            }
        }else {
            SCLAlertView().showError("Error", subTitle: "Please select user type.")
            return
        }
        //rk-pd not passs in the web
//        if !selectedSiteDetailsArray.isEmpty {
//            var tagSites = [TaggedSite]()
//            for item in selectedSiteDetailsArray {
//                if let id = item.siteId, let name = item.siteName {
//                    let site = TaggedSite()
//                    site.id = id
//                    site.name = name
//                    tagSites.append(site)
//                }
//            }
//            request.taggedSites = tagSites
//        }
        if selectStatus != .status {
            request.status = selectStatus.rawValue
        }else {
            SCLAlertView().showError("Error", subTitle: "Please select user status.")
            return
        }
        if let companyId = selectedCompany?.companyId {
            request.companyId = companyId
        }
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.newUserAdd(userModel: request)
        print("rk: request \(request.toJSON())")
        APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<User>, Error>) in
            DispatchQueue.main.async { [weak self] in
//                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let user) = responseResult {
                        DispatchQueue.main.async { [weak self] in
                            print("rk: responseResult \(user.toJSON())")
                            guard let self else {return}
                            if user.error != nil || user.error != "" {
                                self.upDateTheSiteId(currentUser: user, scl: scl)
//                                if self.user == nil {
//                                    self.delegate?.sucessFullyAddUser()
//                                }else {
//                                    self.delegate?.sucessFullyUpdateUser()
//                                }
                            }else if let message = user.message {
                                scl.hideView()
                                SCLAlertView().showError("Error", subTitle: message)
                            }
                        }
                    }else {
                        scl.hideView()
                    }
                case .failure(let error):
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func upDateTheSiteId(currentUser: User, scl: SCLAlertView) {
        //rk-pd not passs in the web
        var currecntSiteID = [Int]()
        if !selectedSiteDetailsArray.isEmpty {
            for item in selectedSiteDetailsArray {
                currecntSiteID.append(item.siteId ?? 0)
            }
        }
        // Find removed site IDs
        let removedSites = availableSite.filter {!currecntSiteID.contains($0)}
        
        if Set(currecntSiteID) == Set(availableSite) {
            scl.hideView()
            if isEditProfile {
                let sclAlertView = SCLAlertView()
                sclAlertView.showSuccess("", subTitle: "User has been updated successfully.")
            }else if self.user == nil {
                self.delegate?.sucessFullyAddUser()
            }else {
                self.delegate?.sucessFullyUpdateUser()
            }
        }else {
            let api = ApiService.userManagerAddSite(userID: currentUser.id ?? 0, addedSites: currecntSiteID, removedSites: removedSites)
            APIClient.requestWithCode(api) { isSucess, code in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    scl.hideView()
                    if code == 200 {
                        if isEditProfile {
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "User has been updated successfully.")
                        }else if self.user == nil {
                            self.delegate?.sucessFullyAddUser()
                        }else {
                            self.delegate?.sucessFullyUpdateUser()
                        }
                    }else {
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                }
            }
        }
    }

    
    func siteDetailsSetUp()  {
        if let user = self.user, let siteDeails = user.taggedSites, !siteDeails.isEmpty {
            for siteDeail in siteDeails {
                if !selectedSiteDetailsArray.contains(where: {$0.siteId == siteDeail.id}), let ind = siteDetailsArray.firstIndex(where: {$0.siteId == siteDeail.id}) {
                    selectedSiteDetailsArray.append(siteDetailsArray[ind])
                    self.availableSite.append(siteDeail.id ?? 0)
                }else if !selectedSiteDetailsArray.contains(where: {$0.siteId == siteDeail.id}) {
                    let siteModel = SiteModel()
                    siteModel.siteName = siteDeail.name
                    siteModel.siteId = siteDeail.id
                    selectedSiteDetailsArray.append(siteModel)
                    self.availableSite.append(siteDeail.id ?? 0)
                }
            }
        }
        var suggetion = [String]()
        for item in siteDetailsArray {
            if !selectedSiteDetailsArray.contains(where: {$0.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == item.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)}) {
                suggetion.append(item.siteName ?? "")
            }
        }
        self.searchTextFiled.filterStrings(suggetion)
        setUpSiteCollection(siteName: nil)
        searchTextFiled.highlightAttributes = [.font: UIFont.boldSystemFont(ofSize: 15)]
        searchTextFiled.theme.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        searchTextFiled.startVisible = true
        searchTextFiled.theme.bgColor = .white
        searchTextFiled.delegate = self
    }
    
    func companySetUp()  {
        var suggetion = [String]()
        for item in companyDetailsArray {
            suggetion.append(item.companyName ?? "")
        }
        if let user = self.user, let Id = user.companyId, let name = user.companyName {
            self.tfSearchCompany.text = name
            if let ind = self.companyDetailsArray.firstIndex(where: {$0.companyId == Id}) {
                self.selectedCompany = self.companyDetailsArray[ind]
            }else {
                let company = Company()
                company.companyName = name
                company.companyId = Id
                self.selectedCompany = company
            }
        }
        self.tfSearchCompany.filterStrings(suggetion)
        //rk-pd
//        setUpSiteCollection(siteName: nil)
        tfSearchCompany.highlightAttributes = [.font: UIFont.boldSystemFont(ofSize: 15)]
        tfSearchCompany.theme.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tfSearchCompany.startVisible = true
        tfSearchCompany.theme.bgColor = .white
        tfSearchCompany.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTextFiled {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            setUpSiteCollection(siteName: text)
            self.searchTextFiled.text = ""
        }else if textField == tfSearchCompany {
            let text = textField.text?.lowercased()
            if let ind = self.companyDetailsArray.firstIndex(where: {$0.companyName?.lowercased() == text}) {
                self.selectedCompany = self.companyDetailsArray[ind]
            }else {
                self.tfSearchCompany.text = ""
                self.selectedCompany = nil
            }
        }
    }
    
    
    @IBAction func btnSwitchClick(_ sender: UISwitch) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if sender.isOn {
                self.heightofCompanyMainBG.constant = 76
                self.viewCompanyMainBG.isHidden = false
            }else {
                self.heightofCompanyMainBG.constant = 0
                self.viewCompanyMainBG.isHidden = true
                self.selectedCompany = nil
                self.tfSearchCompany.text = ""
            }
        }
    }
    
    func setUpSiteCollection(siteName: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if let siteName = siteName, let ind = self.siteDetailsArray.firstIndex(where: {$0.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == siteName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)}) {
                self.selectedSiteDetailsArray.insert(siteDetailsArray[ind], at: 0)
                var suggetion = [String]()
                for item in siteDetailsArray {
                    if !selectedSiteDetailsArray.contains(where: {$0.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == item.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)}) {
                        suggetion.append(item.siteName ?? "")
                    }
                }
                self.searchTextFiled.filterStrings(suggetion)
            }
            if self.selectedSiteDetailsArray.isEmpty {
                self.viewTagSiteMainBG.isHidden = true
                self.heightOfCVMainBG.constant = 0
            }else {
                self.viewTagSiteMainBG.isHidden = false
                self.heightOfCVMainBG.constant = 45
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.cvTagSite.reloadData()
            }
        }
    }

    func loadSiteDetailsData() {
        loadComapnysDetails()
        
        let siteAllDetails = ApiService.siteAllDetails(sort: "asc", sortName: "siteName")
        
        APIClient.request(siteAllDetails) { [weak self] (result: Result<APIClient.MappableResult<SiteModel>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteDetailsArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.siteDetailsArray = siteDetailsArray
                        var suggetion = [String]()
                        if let user = self.user, let siteDeails = user.taggedSites, !siteDeails.isEmpty {
                            for siteDeail in siteDeails {
                                if !self.selectedSiteDetailsArray.contains(where: {$0.siteId == siteDeail.id}), let ind = self.siteDetailsArray.firstIndex(where: {$0.siteId == siteDeail.id}) {
                                    self.selectedSiteDetailsArray.append(siteDetailsArray[ind])
                                }else if !self.selectedSiteDetailsArray.contains(where: {$0.siteId == siteDeail.id}) {
                                    let siteModel = SiteModel()
                                    siteModel.siteName = siteDeail.name
                                    siteModel.siteId = siteDeail.id
                                    self.selectedSiteDetailsArray.append(siteModel)
                                }
                            }
                        }
                        for item in siteDetailsArray {
                            if !self.selectedSiteDetailsArray.contains(where: {$0.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == item.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)}) {
                                suggetion.append(item.siteName ?? "")
                            }
                        }
                        self.searchTextFiled.filterStrings(suggetion)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func loadComapnysDetails() {
        let companiesAllDetails = ApiService.getAllCompanies
        
        APIClient.request(companiesAllDetails) { [weak self] (result: Result<APIClient.MappableResult<Company>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let companyArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.companyDetailsArray = companyArray
                        var suggetion = [String]()
                        for item in self.companyDetailsArray {
                            suggetion.append(item.companyName ?? "")
                        }
                        self.tfSearchCompany.filterStrings(suggetion)
                        if let user = self.user, let Id = user.companyId, let name = user.companyName {
                            self.tfSearchCompany.text = name
                            if let ind = self.companyDetailsArray.firstIndex(where: {$0.companyId == Id}) {
                                self.selectedCompany = self.companyDetailsArray[ind]
                            }else {
                                let company = Company()
                                company.companyName = name
                                company.companyId = Id
                                self.selectedCompany = company
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func setUpTextFiledXib() {
        viewNameXib.lblTFName.text = "First Name"
        viewLastNXib.lblTFName.text = "Last Name"
        viewEmailXib.lblTFName.text = "Email ID"
        viewPasswordXib.lblTFName.text = "Password"
        viewPhoneXib.lblTFName.text = "Phone Number"
        //rk-pd
//        viewPasswordXib.tfData.isSecureTextEntry = true
        viewPhoneXib.tfData.keyboardType = .phonePad
    }
    
    func setUpRoleXib() {
        var actions = [UIAction]()
        for item in userTypeArray {
            actions.append(UIAction(title: item.rawValue, state: selectUserRole == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectUserRole = item
                    self.viewRoleXib.lblText.text = item.rawValue
                    if item == .role {
                        self.viewRoleXib.lblText.text = "Select Role"
                    }
                    self.setUpRoleXib()
                }
            }))
        }
        viewRoleXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewRoleXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setUpTypeIOEXib() {
        var actions = [UIAction]()
        let array: [TypeInternalExternal] = [.internal,.external]
        for item in array {
            actions.append(UIAction(title: item.rawValue, state: selectIOEType == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectIOEType = item
                    self.viewTypeIOEXib.lblText.text = item.rawValue
                    self.setUpTypeIOEXib()
                    if selectIOEType == .external {
                        self.viewMainTradeBG.isHidden = false
                        self.heightMainTradeBG.constant = 76
                    }else {
                        self.viewMainTradeBG.isHidden = true
                        self.heightMainTradeBG.constant = 0
                        self.selectedTradeType = .na
                        self.viewTradeXib.lblText.text = self.selectedTradeType.rawValue
                    }
                }
            }))
        }
        
        viewTypeIOEXib.btnDownClick.menu = UIMenu(title: "Select Internal/External", children: actions)
        viewTypeIOEXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setUpTradeEXib() {
        var actions = [UIAction]()
        let array = TradeTypeEnum.tradeArray
        for item in array {
            actions.append(UIAction(title: item.rawValue, state: selectedTradeType == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedTradeType = item
                    self.viewTradeXib.lblText.text = item.rawValue
                    self.setUpTradeEXib()
                }
            }))
        }
        
        viewTradeXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewTradeXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setStatusXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: Status.active.rawValue, state: selectStatus == .active ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectStatus = .active
                self.viewStatusXib.lblText.text = Status.active.rawValue
                self.setStatusXib()
            }
        }))
        actions.append(UIAction(title: Status.inactive.rawValue, state: selectStatus == .inactive ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectStatus = .inactive
                self.viewStatusXib.lblText.text = Status.inactive.rawValue
                self.setStatusXib()
            }
        }))
        viewStatusXib.btnDownClick.menu = UIMenu(title: "Select Status", children: actions)
        viewStatusXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
}

extension AddNewUserVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSiteDetailsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        let item = selectedSiteDetailsArray[indexPath.row].siteName?.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.lblSiteName.text = item
        if !isOnlyView {
            cell.btnRemoveSite.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let item = self.selectedSiteDetailsArray.remove(at: indexPath.row)
                    var suggetion = [String]()
                    for item in siteDetailsArray {
                        if !selectedSiteDetailsArray.contains(where: {$0.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == item.siteName?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)}) {
                            suggetion.append(item.siteName ?? "")
                        }
                    }
                    self.searchTextFiled.filterStrings(suggetion)
                    self.setUpSiteCollection(siteName: nil)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = selectedSiteDetailsArray[indexPath.row].siteName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        let width = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).width
        return CGSize(width: width+40+3, height: 40)
    }

}

class SiteTagCell: UICollectionViewCell {
    
    @IBOutlet weak var lblSiteName: UILabel!
    @IBOutlet weak var btnRemoveSite: UIButton!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var closeImageViewWidth: NSLayoutConstraint!
    
}

private var actionKey: UInt8 = 0

extension UIButton {
    
    func addAction(for event: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        objc_setAssociatedObject(self, &actionKey, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(handleAction), for: event)
    }
    
    @objc private func handleAction() {
        if let closure = objc_getAssociatedObject(self, &actionKey) as? () -> Void {
            closure()
        }
    }
    
    func removeAction(for event: UIControl.Event = .touchUpInside) {
        removeTarget(self, action: #selector(handleAction), for: event)
    }
}

protocol AddAndUpdateUserDelegate: AnyObject {
    func sucessFullyUpdateUser()
    func sucessFullyAddUser()
    func passwordResteSucessFully()
}

private var switchActionKey: UInt8 = 0

extension UISwitch {
    
    func addAction(for event: UIControl.Event = .valueChanged, _ closure: @escaping (Bool) -> Void) {
        objc_setAssociatedObject(self, &switchActionKey, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(handleSwitchAction(_:)), for: event)
    }
    
    @objc private func handleSwitchAction(_ sender: UISwitch) {
        if let closure = objc_getAssociatedObject(self, &switchActionKey) as? (Bool) -> Void {
            closure(sender.isOn)
        }
    }
}
