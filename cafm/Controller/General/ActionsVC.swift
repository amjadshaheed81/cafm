//
//  ActionsVC.swift
//  cafm
//
//  Created by NS on 24/08/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class ActionsVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var searchView: CustomTextField!
    @IBOutlet weak var statusView: OptionBtnXib!
    @IBOutlet weak var exportBtnView: ExportBtnXib!
    
    @IBOutlet weak var spreadsheetContainerView: DesignableView!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var spreadsheetViewWidth: NSLayoutConstraint!
    @IBOutlet weak var spreadsheetViewHeight: NSLayoutConstraint!
    
    lazy var searchViewTextField: UITextField = {
        return self.searchView.textField
    }()
    let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    
    var headerColumnNames: [String] = []
    var itemArray: [ActionModel] = []
    var searchItemArray: [ActionModel] = []
    var selectedStatus: ActionModel.Status = .default
    var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.mainView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                if self.loadingStatus == .loading || self.loadingStatus.shouldReload {
                    self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                    self.emptyView.isHidden = false
                    self.mainView.isHidden = true
                }else {
                    self.mainView.isHidden = false
                    self.emptyView.isHidden = true
                }
            }
        }
    }
    
    let userRole: UserEnum = UserDefaults.standard.userRole
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var headerColumns = [
            "Action Type",
            "Description",
            "Observation",
            "Required Action",
            "Risk Score",
            "Status"
        ]
        if userRole != .siteUsers && userRole != .surveyor {
            headerColumns.append("Actions")
        }
        self.headerColumnNames = headerColumns
        
        self.emptyView.delegate = self
        
        self.setupSearchView()
        self.setupStatusView()
        self.setupExportBtnView()
        self.setupSpreadsheetView()
        
        self.loadData()
    }
    
    func setupSearchView() {
        self.searchView.delegate = self
        self.searchViewTextField.delegate = self
        self.searchViewTextField.placeholder = "Search"
    }
    
    func setupStatusView() {
        self.statusView.lblText.text = "Status"
        self.setupStatusMenu()
    }
    
    func setupStatusMenu() {
        var actions: [UIMenuElement] = []
        for status in ActionModel.Status.allCases {
            let action = UIAction(title: status.rawValue, state: self.selectedStatus == status ? .on : .off) { [weak self] action in
                guard let strongSelf = self else { return }
                strongSelf.selectedStatus = status
                strongSelf.statusView.lblText.text = status.rawValue
                strongSelf.searchFilter(searchText: strongSelf.searchView.textField.text)
                strongSelf.setupStatusMenu()
            }
            actions.append(action)
        }
        self.statusView.btnDownClick.menu = UIMenu(children: actions)
        self.statusView.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupExportBtnView() {
        self.exportBtnView.addCorner()
        self.exportBtnView.addBorder(color: UIColor(appColor: .Separator2))
        self.exportBtnView.btnExport.addTarget(self, action: #selector(self.exportBtnClicked(_:)), for: .touchUpInside)
    }
    
    func setupSpreadsheetView() {
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: BadgeLabelCell.className(), bundle: nil), forCellWithReuseIdentifier: BadgeLabelCell.className())
        self.spreadsheetView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
    }
    
    func loadData(forNewStatus newStatus: ActionModel.Status? = nil) {
        self.fetchSiteActions(forNewStatus: newStatus)
    }
    
    func fetchSiteActions(forNewStatus newStatus: ActionModel.Status? = nil) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            if let newStatus {
                self.hideLoadingAndShowError(newStatus: newStatus)
            }
            return
        }
        
        let apiService = ApiService.siteActionsAPI(siteId: siteID)
        
        if newStatus == nil {
            // loading with empty data
            self.loadingStatus = .loading
            self.reloadSpreadsheetView()
        }
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.loadingStatus = .failed
                    if let newStatus {
                        strongSelf.hideLoadingAndShowError(newStatus: newStatus)
                    }
                case .array(let array):
                    strongSelf.itemArray = array
                    strongSelf.searchItemArray = strongSelf.itemArray
                    strongSelf.loadingStatus = strongSelf.itemArray.isEmpty ? .noResponse : .default
                    if newStatus != nil {
                        strongSelf.loadingSCLAlertView.hideView()
                        strongSelf.searchFilter(searchText: strongSelf.searchView.textField.text)
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
                if let newStatus {
                    strongSelf.hideLoadingAndShowError(newStatus: newStatus)
                }
            }
            strongSelf.reloadSpreadsheetView()
        }
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
        let spreadsheetSize = self.spreadsheetView.contentSize
        let width = min(self.spreadsheetContainerView.frame.width, spreadsheetSize.width)
        self.spreadsheetViewWidth.constant = width
        self.spreadsheetView.frame.size.width = width
        let height = min(self.spreadsheetContainerView.frame.height, spreadsheetSize.height)
        self.spreadsheetViewHeight.constant = height
        self.spreadsheetView.frame.size.height = height
    }
    
    func searchFilter(searchText: String?) {
        guard let text = searchText?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if text.isEmpty {
                strongSelf.searchItemArray = strongSelf.itemArray
            }else {
                strongSelf.searchItemArray = strongSelf.itemArray.filter({ model in
                    if model.type?.lowercased().contains(text.lowercased()) ?? false {
                        return true
                    }else if model.desc?.lowercased().contains(text.lowercased()) ?? false {
                        return true
                    }/*else if model.observation?.lowercased().contains(text.lowercased()) ?? false {
                      return true
                      }else if model.requiredAction?.lowercased().contains(text.lowercased()) ?? false {
                      return true
                      }*/
                    return false
                })
            }
            
            if strongSelf.selectedStatus != .default {
                strongSelf.searchItemArray = strongSelf.searchItemArray.filter({ $0.status == strongSelf.selectedStatus })
            }
            
            strongSelf.loadingStatus = strongSelf.searchItemArray.isEmpty ? .noResponse : .default
            
            strongSelf.reloadSpreadsheetView()
        }
    }
    
    @objc func exportBtnClicked(_ sender: UIButton) {
        guard !self.searchItemArray.isEmpty else { return }
        var csvString = "actionId,type,status,observation,desc,requiredAction,riskScore,dueDate,siteId,userId\n"
        for item in self.searchItemArray {
            csvString += "\(item.actionId ?? 0),\(item.type ?? ""),\(item.status?.rawValue ?? ""),\(item.observation ?? ""),\(item.desc ?? ""),\(item.requiredAction ?? ""),\(item.riskScore ?? 0),\(item.dueDate ?? ""),\(item.siteId ?? 0),\(item.userId ?? 0)\n"
        }
        
        let fileName = "actions-list.csv"
        let fileURL = documentDirectory().appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            shareFile(filePath: fileURL)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }
    
    func shareFile(filePath: URL) {
        if FileManager.default.fileExists(atPath: filePath.path) {
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [filePath], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
                guard self != nil else { return }
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceRect = self.exportBtnView.frame
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.permittedArrowDirections = .any
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}

extension ActionsVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

extension ActionsVC {
    
    @objc func completedBtnClicked(_ sender: ActionButton) {
        self.callSiteActionsPut(index: sender.tag, newStatus: .completed)
    }
    
    @objc func reassessedBtnClicked(_ sender: ActionButton) {
        self.callSiteActionsPut(index: sender.tag, newStatus: .reassessed)
    }
    
    func callSiteActionsPut(index: Int, newStatus: ActionModel.Status) {
        if self.searchItemArray.count > index {
            let item = self.searchItemArray[index]
            item.status = newStatus
            
            let apiService = ApiService.siteActionsPUTapi(siteModel: item)
            
            self.loadingSCLAlertView.showLoading()
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single:
                        strongSelf.loadData(forNewStatus: newStatus)
                        break
                    case .array:
                        strongSelf.hideLoadingAndShowError(newStatus: newStatus)
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                    strongSelf.hideLoadingAndShowError(newStatus: newStatus)
                }
            }
        }
    }
    
    func hideLoadingAndShowError(newStatus: ActionModel.Status, message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle = message ?? "Failed to Mark as \(newStatus)!"
        SCLAlertView.showLoading(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
}

extension ActionsVC: CustomTextFieldDelegate {
    
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        if view == self.searchView {
            self.searchFilter(searchText: textField.text)
        }
    }
    
}

extension ActionsVC: UITextFieldDelegate {
    
}

extension ActionsVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            return self.searchItemArray.count+1
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let column = indexPath.section
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
            if self.headerColumnNames.count > column {
                let headerText = self.headerColumnNames[column]
                
                cell.backgroundColor = UIColor(appColor: .AppTint)
                cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor.white
                
                cell.mainLbl.text = headerText
            }
            return cell
        }else if !self.loadingStatus.hasData {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
            
            cell.backgroundColor = UIColor.white
            cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
            cell.mainLbl.textColor = UIColor.black
            
            cell.mainLbl.text = self.loadingStatus.rawValue
            return cell
        }else {
            let index = indexPath.row-1
            if self.searchItemArray.count > index {
                let item = self.searchItemArray[index]
                if column == 0 || column == 1 || column == 2 || column == 3 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    if column == 0 {
                        cell.mainLbl.text = item.type
                    }else if column == 1 {
                        cell.mainLbl.text = item.desc
                    }else if column == 2 {
                        cell.mainLbl.text = item.observation
                    }else if column == 3 {
                        cell.mainLbl.text = item.requiredAction
                    }
                    return cell
                }else if column == 4 || column == 5 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: BadgeLabelCell.className(), for: indexPath) as! BadgeLabelCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    
                    if column == 4 {
                        cell.badgeView.addCorner()
                        cell.mainLbl.textColor = UIColor.white
                        let riskScore = item.riskScore ?? 0
                        
                        if riskScore > 17 {
                            cell.badgeView.backgroundColor = UIColor(appColor: .RedStatus)
                        }else if riskScore > 10 {
                            cell.badgeView.backgroundColor = UIColor(appColor: .AmberStatus)
                        }else if riskScore > 5 {
                            cell.badgeView.backgroundColor = UIColor(appColor: .YellowRiskScore)
                        }else {
                            cell.badgeView.backgroundColor = UIColor(appColor: .GreenStatus)
                        }
                        
                        cell.mainLbl.text = "\(riskScore)"
                    }else if column == 5 {
                        cell.badgeView.addCorner(value: cell.badgeView.frame.height/2)
                        
                        cell.badgeView.backgroundColor = item.status?.textBGColor()
                        cell.mainLbl.textColor = item.status?.textColor()
                        
                        cell.mainLbl.text = item.status?.rawValue
                    }
                    return cell
                }else if column == 6 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    let refHeight = cell.stackView.frame.height
                    let completedBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "checkmark.square.fill"), target: self, action: #selector(self.completedBtnClicked(_:)))
                    let reassessedBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "xmark.square.fill"), target: self, action: #selector(self.reassessedBtnClicked(_:)))
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    cell.stackView.addArrangedSubview(completedBtn)
                    cell.stackView.addArrangedSubview(reassessedBtn)
                    return cell
                }
            }
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            return cell
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if !self.loadingStatus.hasData {
            let totalColumn = self.headerColumnNames.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }else {
            return []
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.headerColumnNames.count > column {
            let headerText = self.headerColumnNames[column]
            
            let refSize = CGSize(width: 12+30+12, height: 10+18+10)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerWidth = getLabelSize(text: headerText, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if !self.loadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.headerColumnNames.count))
            }else {
                if column == 0 || column == 1 || column == 2 || column == 3 {
                    var textArray: [String] = []
                    if column == 0 {
                        textArray = self.searchItemArray.compactMap({ $0.type })
                    }else if column == 1 {
                        textArray = self.searchItemArray.compactMap({ $0.desc })
                    }else if column == 2 {
                        textArray = self.searchItemArray.compactMap({ $0.observation })
                    }else if column == 3 {
                        textArray = self.searchItemArray.compactMap({ $0.requiredAction })
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }else if column == 4 || column == 5 {
                    let refSize = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                    let widthAddition: CGFloat = 12+8+8+12
                    let minWidth = refSize.width-widthAddition
                    
                    var textArray: [String] = []
                    if column == 4 {
                        textArray = self.searchItemArray.compactMap({ "\($0.riskScore ?? 0)" })
                    }else if column == 5 {
                        textArray = self.searchItemArray.compactMap({ $0.status?.rawValue })
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }else if column == 6 {
                    return max(headerWidth, 12+40+8+40+12)
                }
            }
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let refSize = CGSize(width: 12+30+12, height: 10+18+10)
        let heightAddition: CGFloat = 10+10
        let minHeight = refSize.height-heightAddition
        let maxWidth: CGFloat = isiPadDevice ? 300 : 200
        
        if row == 0 {
            let headerHeight = getMaxLabelSize(textArray: self.headerColumnNames, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else {
            if !self.loadingStatus.hasData {
                return getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
            }else {
                let refSize1 = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                let heightAddition1: CGFloat = 10+4+4+10
                let minHeight1 = refSize1.height-heightAddition1
                
                let index = row-1
                if self.searchItemArray.count > index {
                    let item = self.searchItemArray[index]
                    
                    let textArray = [
                        item.type,
                        item.desc,
                        item.observation,
                        item.requiredAction,
                    ]
                    let textArray1 = [
                        "\(item.riskScore ?? 0)",
                        item.status?.rawValue,
                    ]
                    
                    let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                    let maxHeight1 = getMaxLabelSize(textArray: textArray1, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight1, heightAddition: heightAddition1).height
                    return max(maxHeight, maxHeight1, 10+40+10)
                }
            }
        }
        return 0
    }
    
}
