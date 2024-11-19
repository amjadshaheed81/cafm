//
//  PreActionVC.swift
//  cafm
//
//  Created by Savan Lakhani on 05/10/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class PreActionVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txField1: UITextField!
    
    @IBOutlet weak var viewStatusXIB: OptionBtnXib!
        
    @IBOutlet weak var createNewView: UIControl!
    @IBOutlet weak var exportView: UIControl!
    
    @IBOutlet weak var createNewLbl: UILabel!
    @IBOutlet weak var exportLbl: UILabel!
    
    @IBOutlet weak var spreedSheetView: SpreadsheetView!
    
    var preActionDetailArray: [PreAction] = []
    var preActionDetailArrayList: [PreAction] = []
        
    var headerRowArray = ["PRE ACTIONID", "RAISED BY", "COMMENT", "LOCATION", "RAISED ON", "STATUS", "ACTION"]

    var searchStatusInd = 0
    
    enum Status: String {
        case status = "Status"
        case pending = "Pending"
        case closed = "Closed"
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
        self.title = "Pre-Action"
        
        self.createNewLbl.font = UIFont(name: .MontserratMedium, size: textFontSize)
        self.exportLbl.font = UIFont(name: .MontserratMedium, size: textFontSize)
        
        self.viewStatusXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        
        self.txField1.addCorner()
        self.txField1.addBorder(color: .gray.withAlphaComponent(0.3))
        self.txField1.addCorner()
        self.viewStatusXIB.addCorner()
        self.exportView.addCorner()
        self.createNewView.addCorner()
        
        self.txField1.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewStatusXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        
        self.txField1.placeholder = "Search"
        self.txField1.text = ""
        self.viewStatusXIB.lblText.text = "Status"
        
        self.txField1.delegate = self
        
        self.setStatusXib()
        
        self.getPreActionDetails()
        
        self.setUpSpreedSheetView()
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
        actions.append(UIAction(title: Status.pending.rawValue, state: searchStatus == .pending ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .pending
                self.viewStatusXIB.lblText.text = Status.pending.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        actions.append(UIAction(title: Status.closed.rawValue, state: searchStatus == .closed ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.searchStatus = .closed
                self.viewStatusXIB.lblText.text = Status.closed.rawValue
                self.setStatusXib()
                self.searchFilter(searchText:self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        
        self.viewStatusXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewStatusXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.searchFilter(searchText: updatedText)
        return true
    }
    
    func searchFilter(searchText: String) {
        if self.preActionDetailArray.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if searchText == "" {
                self.preActionDetailArrayList = self.preActionDetailArray
            }else {
                self.preActionDetailArrayList = preActionDetailArray.filter({ user in
                    user.raisedByUserName?.lowercased().contains(searchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.raisedByUserName?.lowercased() ?? ""
                    let name2 = user2.raisedByUserName?.lowercased() ?? ""
                    
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
            
            if searchStatus != .status {
                self.preActionDetailArrayList = self.preActionDetailArrayList.filter({ user in
                    (user.status?.lowercased() ?? "") == self.searchStatus.rawValue.lowercased()
                })
            }
            if preActionDetailArrayList.isEmpty {
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
        self.spreedSheetView.register(UINib(nibName: String(describing: UserActionCellXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: UserActionCellXib.self))
        self.spreedSheetView.bounces = false
        self.spreedSheetView.dataSource = self
        self.spreedSheetView.delegate = self
        self.spreedSheetView.showsHorizontalScrollIndicator = false
        self.spreedSheetView.showsVerticalScrollIndicator = false
        self.spreedSheetView.addCorner()
        self.spreedSheetView.addBorder(color: .gray.withAlphaComponent(0.4))
    }
    
    @IBAction func createNewContractsAction(_ sender: Any) {
        let vc = preActionSB.instantiateViewController(withIdentifier: "CreateNewPreActionVC") as! CreateNewPreActionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
            
    func getPreActionDetails() {
        guard UserDefaults.standard.userRole != .contractor else { return }
        
        self.loadingStatus = .loading
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.getPreActionSummaryDetail(taggedSiteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<PreActionsResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    strongSelf.loadingStatus = .failed
                    break
                case .single(let single):
                    if let array = single.preActions?.filter({ $0.status != "Pending Action" }) {
                        if array.isEmpty {
                            strongSelf.loadingStatus = .noResponse
                        }else {
                            strongSelf.loadingStatus = .default
                            strongSelf.preActionDetailArray = array
                            strongSelf.preActionDetailArrayList = array
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
    
}

extension PreActionVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerRowArray.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if !self.preActionDetailArrayList.isEmpty {
                return self.preActionDetailArrayList.count + 1
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
                stringsArray = self.preActionDetailArrayList.compactMap { item in
                    if let actionId = item.actionId {
                        return String(actionId)
                    }
                    return nil
                }
                stringsArray.append(headerRowArray[column])
            }else if column == 1 {
                stringsArray = self.preActionDetailArrayList.compactMap{$0.raisedByUserName}
                stringsArray.append(headerRowArray[column])
            }else if column == 2 {
                stringsArray = self.preActionDetailArrayList.compactMap{$0.description}
                stringsArray.append(headerRowArray[column])
            }else if column == 3 {
                var categoryArray: [String] = []
                
                for item in preActionDetailArrayList {
                    let category = item.category
                    let subCategory = item.floor
                    let subCategory2 = item.room
                    
                    let categories = [category, subCategory, subCategory2]
                    
                    let categoriesResult = categories
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    categoryArray.append(categoriesResult)
                }
                categoryArray.append(self.headerRowArray[4])
                let maxColumnWidth = getMaxLabelSize(textArray: categoryArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else if column == 4 {
                stringsArray = self.preActionDetailArrayList.compactMap{$0.raisedDate}
                stringsArray.append(headerRowArray[column])
            }else if column == 5 {
                stringsArray = self.preActionDetailArrayList.compactMap{$0.status}
                stringsArray.append(headerRowArray[column])
            }
            
            if column != 6 {
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else if column == 6 {
                return 180
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
                
                optionArray.append(contentsOf: self.preActionDetailArrayList.compactMap { item in
                    if let actionId = item.actionId {
                        return String(actionId)
                    }
                    return nil
                })
                
                optionArray.append(contentsOf: self.preActionDetailArrayList.compactMap{$0.raisedByUserName})
                
                optionArray.append(contentsOf: self.preActionDetailArrayList.compactMap{$0.description})
                
                optionArray.append(contentsOf: self.preActionDetailArrayList.compactMap{$0.raisedDate})
                
                optionArray.append(contentsOf: self.preActionDetailArrayList.compactMap{$0.status})
                
                optionArray.append(contentsOf: self.headerRowArray)

                
                var categoryArray: [String] = []
                
                for item in preActionDetailArrayList {
                    let category = item.category
                    let subCategory = item.floor
                    let subCategory2 = item.room
                    
                    let categories = [category, subCategory, subCategory2]
                    
                    let categoriesResult = categories
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    categoryArray.append(categoriesResult)
                }

                optionArray.append(contentsOf: categoryArray)
                
                optionArray.append(contentsOf: headerRowArray)

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
            if loadingStatus == .noResponse && !self.preActionDetailArrayList.isEmpty {
                cell.lblText.text = "No search result found!!"
            }
            return cell
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 {
            
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
                if let actionId = self.preActionDetailArrayList[indexPath.row-1].actionId {
                    cell.lblText.text = "\(actionId)"
                }
            }else if indexPath.section == 1 {
                if let raisedByUserName = self.preActionDetailArrayList[indexPath.row-1].raisedByUserName {
                    cell.lblText.text = raisedByUserName
                }
            }else if indexPath.section == 2 {
                if let description = self.preActionDetailArrayList[indexPath.row-1].description {
                    cell.lblText.text = description
                }
            }else if indexPath.section == 3 {
                let category = self.preActionDetailArrayList[indexPath.row-1].category
                let subCategory = self.preActionDetailArrayList[indexPath.row-1].floor
                let subCategory2 = self.preActionDetailArrayList[indexPath.row-1].room
                
                let categories = [category, subCategory, subCategory2]
                
                let categoriesResult = categories
                    .compactMap { $0?.isEmpty == false ? $0 : nil }
                    .joined(separator: " > ")
                cell.lblText.text = categoriesResult
            }else if indexPath.section == 4 {
                if let raisedDate  = self.preActionDetailArrayList[indexPath.row-1].raisedDate {
                    let raisedDateString = formatDateString(raisedDate) ?? raisedDate
                    cell.lblText.text = raisedDateString
                }
            }else if indexPath.section == 5 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
                cell.setUp(string: self.preActionDetailArrayList[indexPath.row - 1].status ?? "")
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                return cell
            }else if indexPath.section == 6 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "UserActionCellXib", for: indexPath) as! UserActionCellXib
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.eyeImageView.image = UIImage(systemName: "checkmark.square.fill")
                cell.pencilImageView.image = UIImage(systemName: "xmark.square.fill")
                cell.lockImageView.image = UIImage(named: "eye")
                
                if UserDefaults.standard.userRole == .siteUsers {
                    cell.btnView.isHidden = true
                    cell.btnEditView.isHidden = true
                    cell.btnDelete.isHidden = true
                }
                
                cell.btnLock.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let actionId = self.preActionDetailArrayList[row].actionId {
                            self.goFurther(preActionType: .viewOnly, actionId: actionId)
                        }
                    }
                }
                
                cell.btnView.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let actionId = self.preActionDetailArrayList[row].actionId {
                            self.goFurther(preActionType: .markAsApproved, actionId: actionId)
                        }
                    }
                }
                
                cell.btnEditView.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let actionId = self.preActionDetailArrayList[row].actionId {
                            self.goFurther(preActionType: .markAsClosed, actionId: actionId)
                        }
                    }
                }
                
                cell.btnDelete.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let actionId = self.preActionDetailArrayList[row].actionId {
                            self.showDeleteAlert(id: actionId)
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

extension PreActionVC {
    
    func showDeleteAlert(id: Int) {
        let alert = UIAlertController(title: nil, message: " you want to delete pre action #\(id)?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DispatchQueue.main.async { [weak self] in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let scl = SCLAlertView(appearance: appearance)
                scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                guard let self else {return}
                let api = ApiService.deletePreAction(actionId: id)
                APIClient.requestDelete(api) { [weak self] isSucess in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        scl.hideView()
                        if isSucess {
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "#\(id) pre action has been deleted successully.")
                            
                            self.getPreActionDetails()
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

    
    func goFurther(preActionType: PreActionType, actionId: Int) {
        let vc = preActionSB.instantiateViewController(withIdentifier: "CreateNewPreActionVC") as! CreateNewPreActionVC
        vc.preActionType = preActionType
        vc.actionId = actionId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

