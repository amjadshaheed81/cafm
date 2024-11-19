//
//  SettingsVC.swift
//  cafm
//
//  Created by Savan Lakhani on 21/08/24.
//

import UIKit
import SCLAlertView

struct SettingsSectionData {
    var name: String
    var items: [(index: Int, name: String, image: String)]
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var itemArray: [SettingsSectionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setItemArray()
    }
    
    func setItemArray() {
        let userRole: UserEnum = UserDefaults.standard.userRole
        
        self.itemArray = []
        
        var generalSection = SettingsSectionData(name: "General", items: [])
        generalSection.items.append((index: 1, name: "Dashboard", image: "house.fill"))
        generalSection.items.append((index: 2, name: "Edit Profile", image: "person.circle.fill"))
        generalSection.items.append((index: 3, name: "Portfolio", image: "square.grid.2x2"))
        generalSection.items.append((index: 4, name: "Reports", image: "chart.bar.fill"))
        if userRole == .admin {
            generalSection.items.append((index: 5, name: "Users", image: "person.2.fill"))
        }
        generalSection.items.append((index: 6, name: "Notifications", image: "bell.fill"))
        generalSection.items.append((index: 7, name: "Actions", image: "bolt.fill"))
        self.itemArray.append(generalSection)
        
        var siteActionsSection = SettingsSectionData(name: "Site Actions", items: [])
        if userRole == .admin {
            siteActionsSection.items.append((index: 11, name: "Create Site", image: "plus"))
        }
        if UserConstants.shared.selectedSiteID != nil {
            siteActionsSection.items.append((index: 12, name: "Site Details", image: "building.2.fill"))
        }
        siteActionsSection.items.append((index: 13, name: "Site Documents", image: "folder.fill"))
        siteActionsSection.items.append((index: 14, name: "Statutory Register", image: "doc.fill"))
        siteActionsSection.items.append((index: 15, name: "Site Assets", image: "wrench.fill"))
        if userRole != .surveyor && userRole != .tradesman {
            siteActionsSection.items.append((index: 16, name: "Site Contracts", image: "pip.fill"))
        }
        if userRole != .contractor && userRole != .surveyor && userRole != .tradesman {
            siteActionsSection.items.append((index: 17, name: "Pre-Action", image: "checkmark.shield.fill"))
        }
        siteActionsSection.items.append((index: 18, name: "Site Checks", image: "checklist.checked"))
        siteActionsSection.items.append((index: 19, name: "Energy Cost", image: "bolt.shield.fill"))
        //siteActionsSection.items.append((index: 20, name: "Site Calendar", image: "calendar"))
        self.itemArray.append(siteActionsSection)
        
        if userRole == .admin {
            var adminSection = SettingsSectionData(name: "Admin", items: [])
            adminSection.items.append((index: 21, name: "Categories", image: "person.badge.shield.checkmark.fill"))
            adminSection.items.append((index: 22, name: "Dropdowns", image: "lanyardcard.fill"))
            adminSection.items.append((index: 23, name: "Company", image: "building.columns.fill"))
            self.itemArray.append(adminSection)
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeNavigationBarAppearance(appDefault: false, backgroundColor: UIColor.black, tintColor: UIColor.white)
        self.configureNavigationBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.changeNavigationBarAppearance()
    }
    
    func getUserDetails() {
        guard let userID = UserConstants.shared.currentUserID else {
            return
        }
        let apiService = ApiService.userDetailsAPI(userId: userID)
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<User>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single(let response):
                        UserConstants.shared.userDetail = response
                        let vc = userManagemnetSB.instantiateViewController(withIdentifier: "AddNewUserVC") as! AddNewUserVC
                        vc.user = response
                        vc.isEditProfile = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        break
                    case .array:
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                }
            }
        }
    }
    
    func getDropDownCategory() {
        let apiService = ApiService.dropDownTyprList
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        APIClient.requestWithStringArray(apiService) { [weak self] catData, error in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                if let data = catData {
                    print(data)
                    let vc = dropdownSB.instantiateViewController(withIdentifier: "DropdownVC") as! DropdownVC
                    vc.categoryList = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    func getSiteEnergy() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.energyCostCategory
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<EnergyCostBudgetCategory>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let response):
                        let energyCosetApi = ApiService.siteEnergyCostDetails(siteId: siteID)
                        print("response category \(response)")
                        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<Energy>, Error>) in
                            DispatchQueue.main.async { [weak self] in
                                guard let self else {return}
                                scl.hideView()
                                switch result {
                                case .success(let mappableResult):
                                    switch mappableResult {
                                    case .array(let response):
                                        print("response energy \(response)")
                                        break
                                    default:
                                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                                        break
                                    }
                                case .failure(let error):
                                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                                    print(apiService.api(), "Error:", error.localizedDescription)
                                }
                            }
                        }
                        break
                    default:
                        scl.hideView()
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        break
                    }
                case .failure(let error):
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    print(apiService.api(), "Error:", error.localizedDescription)
                }
            }
        }
    }
    
    func goFurtherToSiteDetailScreen(id: Int, isForViewOnly: Bool = false) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let apiService = ApiService.getAllSiteDetailsBySiteID(userId: id)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CreateSiteRequestModel>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        DispatchQueue.main.async {
                            let vc = siteActionSB.instantiateViewController(withIdentifier: "CreateNewSiteVC") as! CreateNewSiteVC
                            vc.siteResponseDetail = responseResult
                            vc.isForViewOnly = isForViewOnly
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemArray.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let section = section-1
        if self.itemArray.count > section {
            return self.itemArray[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell1")
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            
            let user = UserConstants.shared.userDetail
            cell.textLabel?.text = user?.name
            cell.textLabel?.font = UIFont(name: .MontserratMedium, size: 18)
            cell.textLabel?.textColor = UIColor.white
            
            cell.detailTextLabel?.text = user?.role
            cell.detailTextLabel?.font = UIFont(name: .MontserratRegular, size: 14)
            cell.detailTextLabel?.textColor = UIColor.white
            
            cell.imageView?.sd_setImage(with: URL(string: ""), completed: { image, _, _, _ in
                if image != nil {
                    if let imageView = cell.imageView {
                        cell.layoutIfNeeded()
                        imageView.addCorner(value: min(imageView.frame.width, imageView.frame.height)/2)
                    }
                }else {
                    cell.imageView?.image = UIImage(systemName: "person.circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32))
                }
            })
            cell.imageView?.contentMode = .scaleAspectFit
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cell.selectionStyle = .none
        
        let section = indexPath.section-1
        if self.itemArray.count > section {
            let items = self.itemArray[section].items
            if items.count > indexPath.row {
                let item = items[indexPath.row]
                cell.textLabel?.text = item.name
                cell.textLabel?.font = UIFont(name: .MontserratRegular, size: 17)
                cell.textLabel?.textColor = UIColor.white
                
                cell.imageView?.image = UIImage(systemName: item.image)?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.contentMode = .scaleAspectFit
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let section = indexPath.section-1
        if self.itemArray.count > section {
            let items = self.itemArray[section].items
            if items.count > indexPath.row {
                let item = items[indexPath.row]
                switch item.name {
                case "Dashboard":
                    self.navigationController?.popViewController(animated: false)
                    break
                case "Edit Profile":
                    DispatchQueue.main.async {
                        self.getUserDetails()
                    }
                    break
                case "Portfolio":
                    let vc = siteActionSB.instantiateViewController(withIdentifier: "PortfolioManagementVC") as! PortfolioManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Reports":
                    let vc = reportsSB.instantiateViewController(withIdentifier: "ReportsVC") as! ReportsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Users":
                    let vc = userManagemnetSB.instantiateViewController(withIdentifier: "UserManagementVC") as! UserManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Notifications":
                    let vc = notificationSB.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Actions":
                    let vc = generalSB.instantiateViewController(withIdentifier: "ActionsVC") as! ActionsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Create Site":
                    let vc = siteActionSB.instantiateViewController(withIdentifier: "CreateNewSiteVC") as! CreateNewSiteVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Details":
                    if let siteID = UserConstants.shared.selectedSiteID {
                        self.goFurtherToSiteDetailScreen(id: siteID, isForViewOnly: false)
                    }
                    break
                case "Site Documents":
                    let vc = documnetSB.instantiateViewController(withIdentifier: "DocumnetsVC") as! DocumnetsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Statutory Register":
                    let vc =  statutoryRegisterSB.instantiateViewController(withIdentifier: "StatutoryRegisterVC") as! StatutoryRegisterVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Assets":
                    let vc = siteAssetsSB.instantiateViewController(withIdentifier: "AssetRegisterVC") as! AssetRegisterVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Contracts":
                    let vc = siteContractsSB.instantiateViewController(withIdentifier: "SiteContractsVC") as! SiteContractsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Pre-Action":
                    let vc = preActionSB.instantiateViewController(withIdentifier: "PreActionVC") as! PreActionVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Checks":
                    let vc = siteCheckSB.instantiateViewController(withIdentifier: "SiteCheckVC") as! SiteCheckVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Energy Cost":
                    let vc = siteReadingsCostSB.instantiateViewController(withIdentifier: "SiteReadingsCostVC") as! SiteReadingsCostVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Calendar":
                    break
                case "Categories":
                    let vc = categoriesManagementSB.instantiateViewController(withIdentifier: "CategoriesManagementVC") as! CategoriesManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Dropdowns":
                    self.getDropDownCategory()
                    break
                case "Company":
                    let vc = CompanyManagementSB.instantiateViewController(withIdentifier: "CompanyManagementVC") as! CompanyManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let section = section-1
        if self.itemArray.count > section {
            return self.itemArray[section].name
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let viewSize: CGFloat = 120
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth-40, height: viewSize))
            view.widthAnchor.constraint(equalToConstant: screenWidth-40).isActive = true
            view.heightAnchor.constraint(equalToConstant: viewSize).isActive = true
            
            let padding: CGFloat = 20
            let imageSize = viewSize-(padding*3)
            let imageView = UIImageView(frame: CGRect(x: 0, y: padding, width: screenWidth-40, height: imageSize))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "setting_logo")
            
            imageView.widthAnchor.constraint(equalToConstant: screenWidth-40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
            view.addSubview(imageView)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
            
            return view
        }
        return nil
    }
    
}

