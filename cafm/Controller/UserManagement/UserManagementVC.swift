//
//  UserManagementVC.swift
//  cafm
//
//  Created by ShitaRam on 18/08/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

let textFontSize: CGFloat = 16

class UserManagementVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var viewSpred: SpreadsheetView!
    
    @IBOutlet weak var tfSearchUser: UITextField!
    @IBOutlet weak var viewRoleXib: OptionBtnXib!
    @IBOutlet weak var viewSiteXib: OptionBtnXib!
    @IBOutlet weak var viewStatusXib: OptionBtnXib!
    @IBOutlet weak var viewExportXib: ExportBtnXib!
    
    var headerRow: [String] = ["Full Name", "Email ID", "Site", "Role", "Creation Date", "Type", "Company", "Status", "Actions"]
    var userList = [User]()
    
    var searchUserList = [User]()
    
    var loadingStatus: LoadingStatus = .loading
    
    var searchUserRole: UserEnum = .role
    var userTypeArray = UserEnum.userTypeArray
    
    
    var siteDetailsArray = [SiteModel]()
    var companyDetailsArray = [Company]()
    var searchSiteInd = 0
    
    enum Status: String {
        case status = "Status"
        case active = "Active"
        case inactive = "Inactive"
    }
    var searchStatus: Status = .status
    
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        viewSpred.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpred.register(UINib(nibName: String(describing: SiteViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SiteViewXib.self))
        viewSpred.register(UINib(nibName: String(describing: StatusXIb.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StatusXIb.self))
        viewSpred.register(UINib(nibName: String(describing: ActionViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ActionViewXib.self))
        self.title = "User Management"
        viewSpred.bounces = false
        viewSpred.dataSource = self
        viewSpred.delegate = self
        fetchData()
        viewRoleXib.lblText.text = "Role"
        viewSiteXib.lblText.text = "Site"
        viewStatusXib.lblText.text = "Status"
        setUpRoleXib()
        setUpSiteXib()
        setStatusXib()
        tfSearchUser.delegate = self
        let rightBarButton = UIBarButtonItem(title: "Add New", style: .plain, target: self, action: #selector(buttonTapped))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func buttonTapped() {
        print("Navigation bar button tapped")
        let vc = userManagemnetSB.instantiateViewController(withIdentifier: "AddNewUserVC") as! AddNewUserVC
        vc.delegate = self
        vc.siteDetailsArray = self.siteDetailsArray
        vc.companyDetailsArray = self.companyDetailsArray
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)

        // Call your search functionality with the updated text
        print("rk : \(updatedText)")
        
        searchFilter(searchText: updatedText)

        return true
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("rk : \(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))")
    }
    
    func setUpRoleXib() {
        var actions = [UIAction]()
        for item in userTypeArray {
            actions.append(UIAction(title: item.rawValue, state: searchUserRole == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.searchUserRole = item
                    self.viewRoleXib.lblText.text = item.rawValue
                    self.setUpRoleXib()
                    self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        viewRoleXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewRoleXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setUpSiteXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Site", state: searchSiteInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchSiteInd = 0
                self.viewSiteXib.lblText.text = "Site"
                self.setUpSiteXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        for (key,item) in siteDetailsArray.enumerated() {
            actions.append(UIAction(title: item.siteName ?? "No Name", state: searchSiteInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.searchSiteInd = key+1
                    self.viewSiteXib.lblText.text = item.siteName
                    self.setUpSiteXib()
                    self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        viewSiteXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewSiteXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setStatusXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: Status.status.rawValue, state: searchStatus == .status ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .status
                self.viewStatusXib.lblText.text = Status.status.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.active.rawValue, state: searchStatus == .active ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .active
                self.viewStatusXib.lblText.text = Status.active.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.inactive.rawValue, state: searchStatus == .inactive ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .inactive
                self.viewStatusXib.lblText.text = Status.inactive.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        viewStatusXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewStatusXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func loadSiteDetailsData() {
        let apiService = ApiService.siteAllDetails
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteModel>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteDetailsArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.viewSiteXib.lblText.text = "Site"
                        self.searchSiteInd = 0
                        self.siteDetailsArray = siteDetailsArray
                        self.setUpSiteXib()
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
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchData() {
        loadComapnysDetails()
        loadSiteDetailsData()
        loadingStatus = .loading
        let loginService = ApiService.getAllUserData
        APIClient.request(loginService) { [weak self] (result: Result<UsersList, Error>) in
            switch result {
            case .success(let data):
                if let users = data.users {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        self.loadingStatus = users.isEmpty ? .noResponse : .default
                        self.userList = users
                        self.searchFilter(searchText: self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self?.loadingStatus = .failed
                self?.reloadCollection()
            }
        }
    }
    
    func searchFilter(searchText: String) {
        if self.userList.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if searchText == "" {
                self.searchUserList = self.userList
            }else {
                self.searchUserList = userList.filter({ user in
                    user.name?.lowercased().contains(searchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.name?.lowercased() ?? ""
                    let name2 = user2.name?.lowercased() ?? ""
                    
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
            if searchUserRole != .role {
                self.searchUserList = self.searchUserList.filter({ user in
                    (user.role?.lowercased() ?? "") == self.searchUserRole.rawValue.lowercased()
                })
            }
            if searchSiteInd != 0, let siteId = siteDetailsArray[searchSiteInd-1].siteId {
                self.searchUserList = self.searchUserList.filter({ user in
                    user.taggedSites?.contains(where: { taggedSite in
                        taggedSite.id == siteId
                    }) ?? false
                })
            }
            if searchStatus != .status {
                self.searchUserList = self.searchUserList.filter({ user in
                    (user.status?.lowercased() ?? "") == self.searchStatus.rawValue.lowercased()
                })
            }
            if searchUserList.isEmpty {
                self.loadingStatus = .noResponse
            }else {
                self.loadingStatus = .default
            }
            self.reloadCollection()
        }
    }
    
    func reloadCollection() {
        viewSpred.reloadData()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 9
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if searchUserList.isEmpty {
                return 1+1
            }else {
                return searchUserList.count+1
            }
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray = searchUserList.compactMap{$0.name}
            stringsArray.append(headerRow[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            break
        }
        if column == 0 || column == 1 || column == 3 || column == 4 || column == 5 || column == 6 {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = searchUserList.compactMap{$0.name}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = searchUserList.compactMap{$0.email}
                stringsArray.append(headerRow[column])
            }else if column == 3 {
                stringsArray = searchUserList.compactMap{$0.role}
                stringsArray.append(headerRow[column])
            }else if column == 4 {
                stringsArray = searchUserList.compactMap{(convertDateString($0.creationDate))}
                stringsArray.append(headerRow[column])
            }else if column == 5 {
                stringsArray = searchUserList.compactMap{$0.userType}
                stringsArray.append(headerRow[column])
            }else if column == 6 {
                stringsArray = searchUserList.compactMap{$0.companyName}
                stringsArray.append(headerRow[column])
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }else if column == 2 {
            return 175
        } else if column == 7 {
            return 100
        }else if column == 8 {
            return 40+40+40+10+10+5+5
        }else {
            return 60
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRow.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let textArray = headerRow
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = headerRow
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: [searchUserList[row-1].name,
                                                searchUserList[row-1].email,
                                                searchUserList[row-1].role,
                                                convertDateString(searchUserList[row-1].creationDate),
                                                searchUserList[row-1].userType ,
                                                searchUserList[row-1].companyName])
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                var secondHeight = 0
                var stringsArray = searchUserList[row-1].taggedSites?.compactMap{$0.name} ?? []
                if stringsArray.isEmpty || stringsArray.count > 3 {
                    secondHeight = 60
                }else {
                    if stringsArray.count == 1 {
                        secondHeight = 33+10+10
                    }else if stringsArray.count == 2 {
                        secondHeight = (33+33+10+10+5+5)
                    }else if stringsArray.count == 3 {
                        secondHeight = (33+33+33+10+10+5+5+5)
                    }else {
                        secondHeight = 60
                    }
                }
                return max(headerHeight, CGFloat(secondHeight))
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
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        }else if indexPath.row == 1 && isDataNotRecive {
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
            if loadingStatus == .noResponse && !userList.isEmpty {
                cell.lblText.text = "No search result found!!"
            }
            return cell
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = UIColor.white
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            var text: String?
            if indexPath.section == 0 {
                text = searchUserList[indexPath.row-1].name
            }else if indexPath.section == 1 {
                text = searchUserList[indexPath.row-1].email
            }else if indexPath.section == 3 {
                text = searchUserList[indexPath.row-1].role
            }else if indexPath.section == 4 {
                text = convertDateString(searchUserList[indexPath.row-1].creationDate)
            }else if indexPath.section == 5 {
                text = searchUserList[indexPath.row-1].userType
            }else if indexPath.section == 6 {
                text = searchUserList[indexPath.row-1].companyName
            }
            cell.lblText.text = text
            return cell
        }else if indexPath.section == 2 && indexPath.row != 0  {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SiteViewXib", for: indexPath) as! SiteViewXib
            let stringsArray = searchUserList[indexPath.row-1].taggedSites?.compactMap{$0.name} ?? []
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.setUpSite(stringsArray: stringsArray)
            if !stringsArray.isEmpty {
                let actions = stringsArray.map { title in
                    UIAction(title: title, handler: { _ in
                        print("Selected \(title)")
                    })
                }
                cell.lbl1Btn.menu = UIMenu(title: "", children: actions)
                cell.lbl1Btn.showsMenuAsPrimaryAction = true
                cell.lbl2Btn.menu = UIMenu(title: "", children: actions)
                cell.lbl2Btn.showsMenuAsPrimaryAction = true
                cell.lbl3Btn.menu = UIMenu(title: "", children: actions)
                cell.lbl3Btn.showsMenuAsPrimaryAction = true
            }
            return cell
        }else if indexPath.section == 7 && indexPath.row != 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
            cell.setUp(string: searchUserList[indexPath.row-1].status ?? "")
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            return cell
        }else if indexPath.section == 8 && indexPath.row != 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ActionViewXib", for: indexPath) as! ActionViewXib
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.btnView.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    
                }
            }
            cell.btnEditView.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    let vc = userManagemnetSB.instantiateViewController(withIdentifier: "AddNewUserVC") as! AddNewUserVC
                    vc.delegate = self
                    vc.siteDetailsArray = self.siteDetailsArray
                    vc.user = self.searchUserList[row]
                    vc.companyDetailsArray = self.companyDetailsArray
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            cell.btnDelete.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    self.showDeleteAlert(userName: self.searchUserList[row].name ?? "",id: self.searchUserList[row].id ?? 0)
                }
            }
            return cell
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
            return cell
        }
    }
    
    func showDeleteAlert(userName: String, id: Int) {
        let alert = UIAlertController(title: nil, message: "Do you want to delete \(userName)?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("\(userName) deleted.")
            DispatchQueue.main.async { [weak self] in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false // if you dont want the close button use false
                )
                let scl = SCLAlertView(appearance: appearance)
                scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                guard let self else {return}
                let api = ApiService.deleteUser(userId: id)
                APIClient.requestDelete(api) { [weak self] isSucess in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        scl.hideView()
                        if isSucess {
                            fetchData()
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "User delete successfully.")
                        }else {
                            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if (loadingStatus == .noInternet || loadingStatus == .failed) {
            fetchData()
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

}

extension UserManagementVC: AddAndUpdateUserDelegate {
    
    func sucessFullyUpdateUser() {
        self.navigationController?.popViewController(animated: true)
        self.fetchData()
        let sclAlertView = SCLAlertView()
        sclAlertView.showSuccess("", subTitle: "User has been updated successfully.")
    }
    
    func sucessFullyAddUser() {
        self.navigationController?.popViewController(animated: true)
        self.fetchData()
        let sclAlertView = SCLAlertView()
        sclAlertView.showSuccess("", subTitle: "User added successfully.")
    }
        
}
