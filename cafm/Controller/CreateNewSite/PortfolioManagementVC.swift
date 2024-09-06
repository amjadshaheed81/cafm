//
//  PortfolioManagementVC.swift
//  cafm
//
//  Created by Savan Lakhani on 25/08/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class PortfolioManagementVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var viewSpred: SpreadsheetView!
    @IBOutlet weak var tfSearchUser: UITextField!
    @IBOutlet weak var viewCityXib: OptionBtnXib!
    @IBOutlet weak var viewAreaXib: OptionBtnXib!
    @IBOutlet weak var viewStatusXib: OptionBtnXib!
    @IBOutlet weak var viewExportXib: ExportBtnXib!
    
    var headerRow: [String] = ["Site", "Address", "Status", "Outstanding Risk", "Actions"]
    var userList = [User]()
    
    var searchUserList = [SiteModel]()
    
    var loadingStatus: LoadingStatus = .loading
    
    var searchUserRole: UserEnum = .role
    var userTypeArray = UserEnum.userTypeArray
    
    var siteDetailsArray = [SiteModel]()
    var searchSiteAndCity = 0
    
    var riskScoreArray: RiskScoreResponse?
    
    enum Status: String {
        case status = "Status"
        case open = "Open"
        case closed = "Closed"
        case sold = "Sold"
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
        viewSpred.register(UINib(nibName: String(describing: RiskViewXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: RiskViewXIB.self))
        self.title = "Portfolio Management"
        viewSpred.bounces = false
        viewSpred.dataSource = self
        viewSpred.delegate = self
        fetchData()
        viewCityXib.lblText.text = "City"
        viewAreaXib.lblText.text = "Area"
        viewStatusXib.lblText.text = "Status"
        setUpCityXib()
        setUpAreaXib()
        setStatusXib()
        tfSearchUser.delegate = self
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
    
    func setUpCityXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "City", state: searchSiteAndCity == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewCityXib.lblText.text = "City"
                self.searchSiteAndCity = 0
                self.setUpCityXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()

        for (key,item) in siteDetailsArray.enumerated() {
            let area = item.city ?? "No City"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchSiteAndCity == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchSiteAndCity = key + 1
                    self.viewCityXib.lblText.text = item.city
                    self.setUpCityXib()
                    self.searchFilter(searchText: self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        viewCityXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewCityXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setUpAreaXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Area", state: searchSiteAndCity == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewAreaXib.lblText.text = "Area"
                self.searchSiteAndCity = 0
                self.setUpAreaXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()

        for (key,item) in siteDetailsArray.enumerated() {
            let area = item.area ?? "No Area"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchSiteAndCity == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchSiteAndCity = key + 1
                    self.viewAreaXib.lblText.text = item.area
                    self.setUpAreaXib()
                    self.searchFilter(searchText: self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        viewAreaXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewAreaXib.btnDownClick.showsMenuAsPrimaryAction = true
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
        actions.append(UIAction(title: Status.open.rawValue, state: searchStatus == .open ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .open
                self.viewStatusXib.lblText.text = Status.open.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.closed.rawValue, state: searchStatus == .closed ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .closed
                self.viewStatusXib.lblText.text = Status.closed.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.sold.rawValue, state: searchStatus == .sold ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .sold
                self.viewStatusXib.lblText.text = Status.sold.rawValue
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
                        self.loadingStatus = siteDetailsArray.isEmpty ? .noResponse : .default
                        self.viewAreaXib.lblText.text = "Area"
                        self.viewCityXib.lblText.text = "City"
                        self.siteDetailsArray = siteDetailsArray
                        self.searchSiteAndCity = 0
                        self.setUpCityXib()
                        self.setUpAreaXib()
                        self.mergeRiskDataToSiteDetails()
                        self.searchFilter(searchText: self.tfSearchUser.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func loadRiskDetailsData() {
        let riskScore = ApiService.siteDetailsRiskData
        
        APIClient.request(riskScore) { [weak self] (result: Result<APIClient.MappableResult<RiskScoreResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let riskScoreResponse) = responseResult {
                    self?.riskScoreArray = riskScoreResponse
                    self?.mergeRiskDataToSiteDetails()
                }
                break
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func mergeRiskDataToSiteDetails() {
        if let riskScoresDictionary = self.riskScoreArray?.riskScores {
            for site in self.siteDetailsArray {
                if let siteId = site.siteId,
                   let riskScore = riskScoresDictionary["\(siteId)"] {
                    site.riskScores = [
                        riskScore.riskScoreRed ?? 0,
                        riskScore.riskScoreAmber ?? 0,
                        riskScore.riskScoreYellow ?? 0,
                        riskScore.riskScoreGreen ?? 0
                    ]
                }
            }
        }
    }
    
    func fetchData() {
        loadingStatus = .loading
        loadRiskDetailsData()
        loadSiteDetailsData()
    }
    
    func searchFilter(searchText: String) {
        if self.siteDetailsArray.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if searchText == "" {
                self.searchUserList = self.siteDetailsArray
            }else {
                self.searchUserList = siteDetailsArray.filter({ user in
                    user.siteName?.lowercased().contains(searchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.siteName?.lowercased() ?? ""
                    let name2 = user2.siteName?.lowercased() ?? ""
                    
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
            
            if self.viewAreaXib.lblText.text != "Area" {
                self.searchUserList = self.searchUserList.filter({ user in
                    (user.area?.lowercased() ?? "") == self.viewAreaXib.lblText.text?.lowercased()
                })
            }
            
            if self.viewCityXib.lblText.text != "City" {
                self.searchUserList = self.searchUserList.filter({ user in
                    (user.city?.lowercased() ?? "") == self.viewCityXib.lblText.text?.lowercased()
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
        return self.headerRow.count
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
            var stringsArray = siteDetailsArray.compactMap{"\($0.siteName) + \($0.postCode)"}
            stringsArray.append(headerRow[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            break
        }
        if column == 0 || column == 1 {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = searchUserList.compactMap{"\($0.siteName) + \($0.postCode)"}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = searchUserList.compactMap{$0.address1}
                stringsArray.append(headerRow[column])
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }else if column == 2 {
            return 100
        } else if column == 3 {
            return 200
        }else if column == 4 {
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
                optionArray.append(contentsOf: ["\(searchUserList[row-1].siteName) + \(searchUserList[row-1].postCode)",  searchUserList[row-1].address1, searchUserList[row-1].status])
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
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        } else if indexPath.row == 1 && isDataNotRecive {
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
        } else if indexPath.section == 0 || indexPath.section == 1 {
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
                let siteName = searchUserList[indexPath.row - 1].siteName ?? ""
                let postCode = searchUserList[indexPath.row - 1].postCode ?? ""

                let attributedText = NSMutableAttributedString()

                // Define attributes
                let siteNameAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(appColor: .AppTint)
                ]
                let postCodeAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.black
                ]

                // Create attributed strings
                let siteNameString = NSAttributedString(string: siteName, attributes: siteNameAttributes)
                let newlineString = NSAttributedString(string: "\n")
                let postCodeString = NSAttributedString(string: postCode, attributes: postCodeAttributes)

                // Append to attributedText
                attributedText.append(siteNameString)
                attributedText.append(newlineString)
                attributedText.append(postCodeString)

                cell.lblText.attributedText = attributedText
            } else if indexPath.section == 1 {
                let address = searchUserList[indexPath.row - 1].address1 ?? ""
                cell.lblText.text = address
            }
            return cell
        } else if indexPath.section == 2 && indexPath.row != 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
            cell.setUp(string: searchUserList[indexPath.row - 1].status ?? "")
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            return cell
        } else if indexPath.section == 4 && indexPath.row != 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ActionViewXib", for: indexPath) as! ActionViewXib
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            
            cell.btnDelete.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    showDeleteAlert(userName: self.searchUserList[row].siteName ?? "",id: self.searchUserList[row].siteId ?? 0)
                }
            }
            
            cell.btnView.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    goFurtherToSiteDetailScreen(id: self.searchUserList[row].siteId ?? 0, isForViewOnly: true)
                }
            }
            
            cell.btnEditView.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    goFurtherToSiteDetailScreen(id: self.searchUserList[row].siteId ?? 0)
                }
            }
                        
            return cell
        } else if indexPath.section == 3 && indexPath.row != 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "RiskViewXIB", for: indexPath) as! RiskViewXIB
            cell.redRiskLbl.text = "\(searchUserList[indexPath.row - 1].riskScores[0])"
            cell.amberRiskLbl.text = "\(searchUserList[indexPath.row - 1].riskScores[1])"
            cell.yelloriskLbl.text = "\(searchUserList[indexPath.row - 1].riskScores[2])"
            cell.greenRiskLbl.text = "\(searchUserList[indexPath.row - 1].riskScores[3])"
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
            return cell
        }
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

extension PortfolioManagementVC {
    
    func goFurtherToSiteDetailScreen(id: Int, isForViewOnly: Bool = false) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let apiService = ApiService.getAllSiteDetailsBySiteID(userId: id)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteResponseModel>, Error>) in
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
    
    func showDeleteAlert(userName: String, id: Int) {
        let alert = UIAlertController(title: nil, message: "Do you want to delete \(userName)?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("\(userName) deleted.")
            DispatchQueue.main.async { [weak self] in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let scl = SCLAlertView(appearance: appearance)
                scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                guard let self else {return}
                let api = ApiService.deleteSiteDetails(userId: id)
                APIClient.requestDelete(api) { [weak self] isSucess in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        scl.hideView()
                        if isSucess {
                            fetchData()
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "\(userName) site has been deleted successully")
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
    
}
