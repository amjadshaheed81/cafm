//
//  SiteCheckVC.swift
//  cafm
//
//  Created by NS on 13/09/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class SiteCheckVC: AllOrientationsViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var filterMainView: DesignableView!
    @IBOutlet weak var filterMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterSubView: UIView!
    @IBOutlet weak var filterSubViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filtersDropDownXIB: OptionBtnXib!
    @IBOutlet weak var searchXIB: CustomTextField!
    @IBOutlet weak var typeXIB: OptionBtnXib!
    @IBOutlet weak var subTypeXIB: OptionBtnXib!
    @IBOutlet weak var statusXIB: OptionBtnXib!
    @IBOutlet weak var startNewBtn: PrimaryButton!
    @IBOutlet weak var exportXIB: ExportBtnXib!
    
    @IBOutlet weak var spreadsheetContainerView: DesignableView!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var spreadsheetViewWidth: NSLayoutConstraint!
    @IBOutlet weak var spreadsheetViewHeight: NSLayoutConstraint!
    
    private let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    private var loadingStatus: LoadingStatus = .default {
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
    
    private var headerColumnNames: [String] = []
    
    private var userBySiteIdItemArray: [User] = []
    private var SITE_CHECK_TYPE_ItemArray: [LOV_Model] = []
    private var SITE_CHECK_SUB_TYPE_ItemDict: [String: [LOV_Model]] = [:]
    private var itemArray: [SiteCheckModel] = []
    private var filteredItemArray: [SiteCheckModel] = []
    
    var selectedTypeId: Int?
    var selectedSubTypeId: Int?
    var selectedStatus: SiteCheckModel.Status = .default
    
    private let typeStr = "Type"
    private let subTypeStr = "Sub Type"
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd HH:mm:ss"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let failedToCloseInspectionStr = "Failed to close Inspection."
    private let failedToDeleteInspectionStr = "Failed to delete Inspection."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBackButton()
        self.headerColumnNames = [
            "Type",
            "Sub-Type",
            "Summary",
            "Lead",
            "Risk Score",
            "Date",
            "Status",
            "Actions",
        ]
        
        self.emptyView.delegate = self
        
        self.setupViews()
        //self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    @IBAction func startNewBtnClicked(_ sender: PrimaryButton) {
        let vc = siteCheckSB.instantiateViewController(withIdentifier: "AddSiteCheckVC") as! AddSiteCheckVC
        vc.delegate = self
        vc.isForCreateNew = true
        vc.userBySiteIdItemArray = self.userBySiteIdItemArray
        vc.SITE_CHECK_TYPE_ItemArray = self.SITE_CHECK_TYPE_ItemArray
        vc.SITE_CHECK_SUB_TYPE_ItemDict = self.SITE_CHECK_SUB_TYPE_ItemDict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getLeadDisplayStrByUserId(_ leadUserID: String?) -> String? {
        if let leadUserID, let id = Int(leadUserID), let user = self.userBySiteIdItemArray.first(where: { $0.id == id }) {
            let role = user.role ?? ""
            let name = user.name ?? ""
            let email = user.email ?? ""
            return "\(role) - \(name)\n(\(email))"
        }
        return nil
    }
    
    @objc func viewInspectionAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.filteredItemArray.count > index {
            let item = self.filteredItemArray[index]
            let vc = siteCheckSB.instantiateViewController(withIdentifier: "AddSiteCheckVC") as! AddSiteCheckVC
            vc.delegate = self
            vc.isForCreateNew = false
            vc.isViewModeEdit = true
            vc.siteCheckModel = item
            vc.userBySiteIdItemArray = self.userBySiteIdItemArray
            vc.SITE_CHECK_TYPE_ItemArray = self.SITE_CHECK_TYPE_ItemArray
            vc.SITE_CHECK_SUB_TYPE_ItemDict = self.SITE_CHECK_SUB_TYPE_ItemDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func inspectionCopyAsAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.filteredItemArray.count > index {
            let item = self.filteredItemArray[index]
            let vc = siteCheckSB.instantiateViewController(withIdentifier: "AddSiteCheckVC") as! AddSiteCheckVC
            vc.delegate = self
            vc.isForCreateNew = true
            vc.siteCheckModel = item
            vc.userBySiteIdItemArray = self.userBySiteIdItemArray
            vc.SITE_CHECK_TYPE_ItemArray = self.SITE_CHECK_TYPE_ItemArray
            vc.SITE_CHECK_SUB_TYPE_ItemDict = self.SITE_CHECK_SUB_TYPE_ItemDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func inspectionMarkAsClosedAction(_ sender: ActionButton) {
        self.openMarkAsCloseAlert(for: sender.tag)
    }
    
    @objc func deleteInspectionAction(_ sender: ActionButton) {
        self.openDeleteAlert(for: sender.tag)
    }
    
    func openMarkAsCloseAlert(for index: Int) {
        let alert = UIAlertController(title: "Do you want to close Inspection?", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            if self.filteredItemArray.count > index {
                let item = self.filteredItemArray[index]
                item.status = .done
                self.putSiteCheck(model: item)
            }
        })
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.preferredAction = confirmAction
        alert.view.tintColor = UIColor(appColor: .AppTint)
        self.present(alert, animated: true)
    }
    
    func openDeleteAlert(for index: Int) {
        let alert = UIAlertController(title: "Do you want to delete Inspection site check?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            if self.filteredItemArray.count > index {
                let item = self.filteredItemArray[index]
                if let checkId = item.checkId {
                    self.deleteSiteCheck(checkId: checkId)
                }
            }
        })
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.preferredAction = deleteAction
        alert.view.tintColor = UIColor(appColor: .AppTint)
        self.present(alert, animated: true)
    }
    
    func searchFilter(searchText: String?) {
        guard let text = searchText?.trimmingSpacesAndLinesLowercased() else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if text.isEmpty {
                self.filteredItemArray = self.itemArray
            }else {
                self.filteredItemArray = self.itemArray.filter({ item in
                    if item.type?.lowercased().contains(text) ?? false {
                        return true
                    }else if item.subType?.lowercased().contains(text) ?? false {
                        return true
                    }else if item.category?.lowercased().contains(text) ?? false {
                        return true
                    }else if self.getLeadDisplayStrByUserId(item.leadUserID)?.lowercased().contains(text) ?? false {
                        return true
                    }
                    return false
                })
            }
            
            if let selectedTypeId, let type = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue {
                self.filteredItemArray = self.filteredItemArray.filter({ $0.type == type })
                
                if let selectedSubTypeId, let subTypeItemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[type], let subType = subTypeItemArray.first(where: { $0.id == selectedSubTypeId })?.lovValue {
                    self.filteredItemArray = self.filteredItemArray.filter({ $0.subType == subType })
                }
            }
            
            if self.selectedStatus != .default {
                self.filteredItemArray = self.filteredItemArray.filter({ $0.status == self.selectedStatus })
            }
            
            self.loadingStatus = self.filteredItemArray.isEmpty ? .noResponse : .default
            self.reloadSpreadsheetView()
        }
    }
    
}

//MARK: - setup views
extension SiteCheckVC {
    
    func setupViews() {
        self.filtersDropDownXIB.lblText.text = "Filter"
        self.filtersDropDownXIB.imageView.image = UIImage(systemName: "chevron.down")?.withAlignmentRectInsets(UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2))
        self.filtersDropDownXIB.dummyTF.backgroundColor = UIColor(hexString: "#E5EBF3") //UIColor(appColor: .BG1)
        self.filtersDropDownXIB.dummyTF.addCorner()
        self.filtersDropDownXIB.dummyTF.addBorder(color: UIColor.white)
        self.filtersDropDownXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            self.searchXIB.textField.hideEditing()
            self.adjustFilterSubView(!self.filterSubView.isHidden, animated: true)
        }
        self.adjustFilterSubView(true, animated: false)
        self.searchXIB.textField.placeholder = "Search"
        self.searchXIB.delegate = self
        self.searchXIB.textField.delegate = self
        self.typeXIB.lblText.text = "Type"
        self.subTypeXIB.lblText.text = "Sub Type"
        self.statusXIB.lblText.text = "Status"
        self.setupStatusMenu()
        self.exportXIB.btnExport.addTarget(self, action: #selector(self.exportBtnClicked(_:)), for: .touchUpInside)
        
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: RiskViewXIB.className(), bundle: nil), forCellWithReuseIdentifier: RiskViewXIB.className())
        self.spreadsheetView.register(UINib(nibName: BadgeLabelCell.className(), bundle: nil), forCellWithReuseIdentifier: BadgeLabelCell.className())
        self.spreadsheetView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadSpreadsheetView()
    }
    
    func adjustFilterSubView(_ isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        let duration: TimeInterval = 0.25
        let view: UIView! = self.filterSubView
        let constraint: NSLayoutConstraint! = self.filterSubViewHeight
        let mainView: UIView! = self.filterMainView
        let mainConstraint: NSLayoutConstraint! = self.filterMainViewHeight
        let dropDownView: UIView! = self.filtersDropDownXIB.imageView
        
        var sizeChange: ((CGFloat) -> Void) = { [weak self] height in
            guard let self else { return }
            constraint.constant = height
            view.frame.size.height = height
            mainConstraint.constant = 8+40+height+8
            mainView.frame.size.height = 8+40+height+8
            self.view.layoutIfNeeded()
        }
        
        if isHidden {
            if !view.isHidden {
                let height: CGFloat = CGFloat.zero
                if animated {
                    UIView.animate(withDuration: duration) { [weak self] in
                        guard self != nil else { return }
                        sizeChange(height)
                        dropDownView.transform = .identity
                    } completion: { [weak self] _ in
                        guard let self else { return }
                        view.isHidden = true
                        self.adjustSpreadsheetView()
                        completion?()
                    }
                }else {
                    sizeChange(height)
                    dropDownView.transform = .identity
                    view.isHidden = true
                    self.adjustSpreadsheetView()
                    completion?()
                }
            }
        }else {
            if view.isHidden {
                view.isHidden = false
                let height: CGFloat = 10+40+10+40+10+40
                if animated {
                    UIView.animate(withDuration: duration) { [weak self] in
                        guard self != nil else { return }
                        sizeChange(height)
                        dropDownView.transform = CGAffineTransform(rotationAngle: .pi)
                    } completion: { [weak self] _ in
                        guard let self else { return }
                        self.adjustSpreadsheetView()
                        completion?()
                    }
                }else {
                    sizeChange(height)
                    dropDownView.transform = CGAffineTransform(rotationAngle: .pi)
                    self.adjustSpreadsheetView()
                    completion?()
                }
            }
        }
    }
    
    func setupTypeMenu() {
        let view: OptionBtnXib = self.typeXIB
        let defaultStr = typeStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedTypeId = item?.id
            view.lblText.text = item?.lovValue ?? defaultStr
            self.searchFilter(searchText: self.searchXIB.textField.text)
            self.setupTypeMenu()
            if let value = item?.lovValue {
                self.get_lovSITE_CHECK_SUB_TYPE(filter1: value)
            }
            self.reloadSubTypeMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedTypeId == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.SITE_CHECK_TYPE_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedTypeId == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubTypeMenu() {
        self.subTypeXIB.lblText.text = subTypeStr
        self.selectedSubTypeId = nil
        self.setupSubTypeMenu()
    }
    
    func setupSubTypeMenu() {
        let view: OptionBtnXib = self.subTypeXIB
        let defaultStr = subTypeStr
        var actions: [UIMenuElement] = []
        
        if let selectedTypeId, let selectedType = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue, let itemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[selectedType] {
            view.dummyTF.backgroundColor = UIColor.white
            
            let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
                guard let self else { return }
                self.selectedSubTypeId = item?.id
                view.lblText.text = item?.lovValue ?? defaultStr
                self.searchFilter(searchText: self.searchXIB.textField.text)
                self.setupSubTypeMenu()
            }
            
            let titleAction = UIAction(title: defaultStr, state: self.selectedSubTypeId == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for item in itemArray {
                let action = UIAction(title: item.lovValue ?? "", state: self.selectedSubTypeId == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
        }else {
            view.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        }
        
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupStatusMenu() {
        let view: OptionBtnXib = self.statusXIB
        var actions: [UIMenuElement] = []
        for status in SiteCheckModel.Status.allCases {
            let action = UIAction(title: status.rawValue, state: self.selectedStatus == status ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedStatus = status
                view.lblText.text = status.rawValue
                self.searchFilter(searchText: self.searchXIB.textField.text)
                self.setupStatusMenu()
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
        self.spreadsheetView.contentOffset = CGPoint.zero
        self.adjustSpreadsheetView()
    }
    
    func adjustSpreadsheetView() {
        let spreadsheetSize = self.spreadsheetView.contentSize
        let width = min(self.spreadsheetContainerView.frame.width, spreadsheetSize.width)
        self.spreadsheetViewWidth.constant = width
        self.spreadsheetView.frame.size.width = width
        let height = min(self.spreadsheetContainerView.frame.height, spreadsheetSize.height)
        self.spreadsheetViewHeight.constant = height
        self.spreadsheetView.frame.size.height = height
    }
    
    @objc func exportBtnClicked(_ sender: UIButton) {
        guard !self.filteredItemArray.isEmpty else { return }
        var csvString = "checkId,siteId,type,subType,category,dueDate,leadUserID,assistantUserID,status,riskScoreRed,riskScoreAmber,riskScoreYellow,riskScoreGreen,repeatFrequency\n"
        for item in self.filteredItemArray {
            csvString += "\(item.checkId ?? 0),\(item.siteId ?? 0),\(item.type ?? ""),\(item.subType ?? ""),\(item.category ?? ""),\(item.dueDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat) ?? ""),\(item.leadUserID ?? ""),\(item.assistantUserID ?? ""),\(item.status?.rawValue ?? ""),\(item.riskScoreRed ?? 0),\(item.riskScoreAmber ?? 0),\(item.riskScoreYellow ?? 0),\(item.riskScoreGreen ?? 0),\(item.repeatFrequency?.rawValue ?? "")\n"
        }
        
        let fileName = "site-checks-list_\(Date().transformToString(dateFormat: "dd-MM-yyyy")).csv"
        let fileURL = documentDirectory().appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            CAFMFileUtils.shared.shareFile(from: self, fileURL: fileURL, sender: sender)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }
    
}

//MARK: - load data
extension SiteCheckVC {
    
    func loadData() {
        self.getAllUserBySiteId()
    }
    
    func getAllUserBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        self.loadingStatus = .loading
        let apiService = ApiService.getAllUserBy(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.userBySiteIdItemArray = single.users ?? []
                    self.get_lovSITE_CHECK_TYPE()
                    break
                case .array:
                    self.loadingStatus = .failed
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovSITE_CHECK_TYPE() {
        let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_TYPE)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.SITE_CHECK_TYPE_ItemArray = array
                    self.setupTypeMenu()
                    self.setupSubTypeMenu()
                    self.getSiteCheckDataBySiteId()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovSITE_CHECK_SUB_TYPE(filter1: String) {
        let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_SUB_TYPE, filter1: filter1)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    self.SITE_CHECK_SUB_TYPE_ItemDict[filter1] = array
                    //self.reloadSubTypeMenu()
                    self.setupSubTypeMenu()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func getSiteCheckDataBySiteId(fromUpdateSiteCheck: Bool = false, fromDeleteSiteCheck: Bool = false) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            if fromUpdateSiteCheck {
                self.hideLoadingAndShowError(message: failedToCloseInspectionStr)
            }else if fromDeleteSiteCheck {
                self.hideLoadingAndShowError(message: failedToDeleteInspectionStr)
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.siteCheckSiteAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if fromUpdateSiteCheck {
                        self.hideLoadingAndShowError(message: failedToCloseInspectionStr)
                    }else if fromDeleteSiteCheck {
                        self.hideLoadingAndShowError(message: failedToDeleteInspectionStr)
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.itemArray = array
                    if fromUpdateSiteCheck || fromDeleteSiteCheck {
                        self.loadingSCLAlertView.hideView()
                    }else {
                        self.loadingStatus = .default
                        self.filteredItemArray = self.itemArray
                    }
                    self.searchFilter(searchText: self.searchXIB.textField.text)
                    self.reloadSpreadsheetView()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if fromUpdateSiteCheck {
                    self.hideLoadingAndShowError(message: failedToCloseInspectionStr)
                }else if fromDeleteSiteCheck {
                    self.hideLoadingAndShowError(message: failedToDeleteInspectionStr)
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func putSiteCheck(model: SiteCheckModel) {
        guard let checkId = model.checkId else {
            return
        }
        
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.put_siteCheckBy(checkId: checkId, model: model)
        APIClient.requestResponse(apiService) { [weak self] isSucess in
            guard let self else { return }
            if isSucess {
                self.getSiteCheckDataBySiteId(fromUpdateSiteCheck: true)
            }else {
                self.hideLoadingAndShowError(message: failedToCloseInspectionStr)
            }
        }
    }
    
    func deleteSiteCheck(checkId: Int) {
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.delete_siteCheckBy(checkId: checkId)
        APIClient.requestDelete(apiService) { [weak self] isSucess in
            guard let self else { return }
            if isSucess {
                self.getSiteCheckDataBySiteId(fromUpdateSiteCheck: true)
            }else {
                self.hideLoadingAndShowError(message: failedToDeleteInspectionStr)
            }
        }
    }
    
    func hideLoadingAndShowError(message: String?) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
}

//MARK: - EmptyViewDelegate
extension SiteCheckVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

//MARK: - CustomTextFieldDelegate
extension SiteCheckVC: CustomTextFieldDelegate {
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        if view == self.searchXIB {
            self.searchFilter(searchText: textField.text)
        }
    }
}

//MARK: - UITextFieldDelegate
extension SiteCheckVC: UITextFieldDelegate {
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension SiteCheckVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if self.loadingStatus.hasData {
            return self.filteredItemArray.count+1
        }else {
            return 1+1
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
            if self.filteredItemArray.count > index {
                let item = self.filteredItemArray[index]
                
                if column == 0 || column == 1 || column == 2 || column == 3 || column == 5 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    if column == 0 {
                        cell.mainLbl.text = item.type
                    }else if column == 1 {
                        cell.mainLbl.text = item.subType
                    }else if column == 2 {
                        cell.mainLbl.text = item.category
                    }else if column == 3 {
                        cell.mainLbl.text = self.getLeadDisplayStrByUserId(item.leadUserID)
                    }else if column == 5 {
                        cell.mainLbl.text = item.dueDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr)
                    }
                    return cell
                }else if column == 4 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: RiskViewXIB.className(), for: indexPath) as! RiskViewXIB
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.redRiskLbl.text = "\(item.riskScoreRed ?? 0)"
                    cell.amberRiskLbl.text = "\(item.riskScoreAmber ?? 0)"
                    cell.yelloriskLbl.text = "\(item.riskScoreYellow ?? 0)"
                    cell.greenRiskLbl.text = "\(item.riskScoreGreen ?? 0)"
                    return cell
                }else if column == 6 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: BadgeLabelCell.className(), for: indexPath) as! BadgeLabelCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    cell.badgeView.addCorner(value: cell.badgeView.frame.height/2)
                    cell.badgeView.backgroundColor = item.status?.textBGColor()
                    cell.mainLbl.textColor = item.status?.textColor()
                    
                    cell.mainLbl.text = item.status?.rawValue
                    return cell
                }else if column == 7 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    let refHeight = cell.stackView.frame.height
                    let viewBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "eye.fill"), target: self, action: #selector(self.viewInspectionAction(_:)))
                    let copyBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "doc.on.doc.fill"), target: self, action: #selector(self.inspectionCopyAsAction(_:)))
                    let likeBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "hand.thumbsup.fill"), target: self, action: #selector(self.inspectionMarkAsClosedAction(_:)))
                    likeBtn.isEnabled = item.status == .open
                    let deleteBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "trash.fill"), target: self, action: #selector(self.deleteInspectionAction(_:)))
                    deleteBtn.tintColor = UIColor(appColor: .RedRiskScore)
                    
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    [viewBtn, copyBtn, likeBtn, deleteBtn].forEach { cell.stackView.addArrangedSubview($0) }
                    return cell
                }
            }
        }
        return nil
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.headerColumnNames.count > column {
            let headerText = self.headerColumnNames[column]
            
            let refSize = CGSize(width: 12+30+12, height: 10+18+10)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 300
            
            let headerWidth = getLabelSize(text: headerText, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if !self.loadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.headerColumnNames.count))
            }else {
                let itemArray = self.filteredItemArray
                if column == 0 || column == 1 || column == 2 || column == 3 || column == 5 {
                    var textArray: [String] = []
                    if column == 0 {
                        textArray = itemArray.compactMap({ $0.type ?? "" })
                    }else if column == 1 {
                        textArray = itemArray.compactMap({ $0.subType ?? "" })
                    }else if column == 2 {
                        textArray = itemArray.compactMap({ $0.category ?? "" })
                    }else if column == 3 {
                        textArray = itemArray.compactMap({ self.getLeadDisplayStrByUserId($0.leadUserID) ?? "" })
                    }else if column == 5 {
                        textArray = self.itemArray.compactMap({ $0.dueDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? "" })
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }else if column == 4 {
                    let totalItem: CGFloat = 4
                    let itemWidth: CGFloat = 40
                    let spacing: CGFloat = 5
                    let padding: CGFloat = 10
                    let refWidth = (padding*2)+(itemWidth*totalItem)+(spacing*(totalItem-1))
                    return max(headerWidth, refWidth)
                }else if column == 6 {
                    let refSize = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                    let widthAddition: CGFloat = 12+8+8+12
                    let minWidth = refSize.width-widthAddition
                    
                    let textArray: [String] = itemArray.compactMap { $0.status?.rawValue ?? "" }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }else if column == 7 {
                    let totalItem: CGFloat = 4
                    let itemWidth: CGFloat = 40
                    let spacing: CGFloat = 8
                    let padding: CGFloat = 12
                    let refWidth = (padding*2)+(itemWidth*totalItem)+(spacing*(totalItem-1))
                    return max(headerWidth, refWidth)
                }
            }
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let refSize = CGSize(width: 12+30+12, height: 10+18+10)
        let heightAddition: CGFloat = 10+10
        let minHeight = refSize.height-heightAddition
        let maxWidth: CGFloat = isiPadDevice ? 300 : 300
        
        if row == 0 {
            let headerHeight = getMaxLabelSize(textArray: self.headerColumnNames, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else if !self.loadingStatus.hasData {
            return getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
        }else {
            let index = row-1
            if self.filteredItemArray.count > index {
                let item = self.filteredItemArray[index]
                
                let refSize1 = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                let heightAddition1: CGFloat = 10+4+4+10
                let minHeight1 = refSize1.height-heightAddition1
                
                let minHeight2: CGFloat = 10+40+10
                
                let textArray = [
                    item.type ?? "",
                    item.subType ?? "",
                    item.category ?? "",
                    self.getLeadDisplayStrByUserId(item.leadUserID) ?? "",
                    item.dueDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? "",
                ]
                let textArray1 = [
                    item.status?.rawValue ?? ""
                ]
                
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                let maxHeight1 = getMaxLabelSize(textArray: textArray1, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight1, heightAddition: heightAddition1).height
                return max(maxHeight, maxHeight1, minHeight2)
            }
        }
        return 0
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
}

extension SiteCheckVC: AddSiteCheckDelegate {
    
    func addSiteCheckDidSaveContinue() {
        //self.getSiteCheckDataBySiteId()
    }
    
}
