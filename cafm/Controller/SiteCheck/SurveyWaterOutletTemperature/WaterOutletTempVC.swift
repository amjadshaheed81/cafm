//
//  WaterOutletTempVC.swift
//  cafm
//
//  Created by NS on 12/10/24.
//
//

import UIKit
import SCLAlertView
import SpreadsheetView

class WaterOutletTempVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var recordNewBtn: ActionButton!
    @IBOutlet weak var saveBtn: PrimaryButton!
    
    @IBOutlet weak var spreadsheetContainerView: DesignableView!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var spreadsheetViewWidth: NSLayoutConstraint!
    @IBOutlet weak var spreadsheetViewHeight: NSLayoutConstraint!
    
    private var searchTableView: CustomTableView?
    private var searchOverlayView: UIView!
    private var keyBoardHeight: CGFloat = 0.0
    private weak var selectedTextField: UITextField?
    
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
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    var waterOutletTempItemArray: [SiteCheckWaterOutletTemp] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    var asbestosLOVDict: [LOVTypeEnum: [LOV_Model]] = [:]
    var siteLayoutItemArray: [SiteLayoutModel] = []
    private var itemArray: [SiteCheckWaterOutletTemp] = []
    
    private var headerColumnNames: [Fields] = Fields.allCases
    
    private var filterAssestsItemArray: [AssetDetailsResponse] = []
    private var selectedLOVIds: [LOVTypeEnum: Int?] = [:]
    private lazy var selectedFloorItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .floor }
    }()
    private lazy var selectedRoomItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .room }
    }()
    
    var action: Bool = false
    var action2: Bool = false
    var selectedIndex: Int?
    var actionModel: ActionModel?
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Water outlet temperature data saved."
    private let pleaseFillInAllFieldsStr = "Please fill in all fields"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureNavigationBar() {
        let title = "Water - Outlet Temperature - Tests"
        self.title = title
        
        let fontSize = min(screenWidth, 450)*0.041
        let navTitleTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont(name: .MontserratSemiBold, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor(appColor: .AppTint)
        ]
        let label = UILabel()
        label.attributedText = NSAttributedString(string: title, attributes: navTitleTextAttributes)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        self.navigationItem.titleView = label
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func recordNewBtnClicked(_ sender: ActionButton) {
        let item = SiteCheckWaterOutletTemp()
        item.isEditing = true
        item.isForAddNew = true
        self.itemArray.append(item)
        self.reloadSpreadsheetView()
        self.spreadsheetView.contentOffset = CGPoint.zero
    }
    
    func getValue<T>(_ model: SiteCheckWaterOutletTemp, keyPath: AnyKeyPath) -> T? {
        if let keyPath = keyPath as? KeyPath<SiteCheckWaterOutletTemp, T?> {
            return model[keyPath: keyPath]
        }
        return nil
    }
    
    @IBAction private func saveBtnClicked(_ sender: PrimaryButton) {
        let toBeAdded = self.itemArray.filter { $0.isForAddNew == true || $0.isEditing == true }
        
        if toBeAdded.isEmpty {
            return
        }
        
        for response in toBeAdded {
            for fields in Fields.compulsoryFields {
                if let keyPath = fields.keyPath {
                    let valueString: String? = getValue(response, keyPath: keyPath)
                    let valueInt: Int? = getValue(response, keyPath: keyPath)
                    let valueUsageFrequency: SiteCheckWaterOutletTemp.UsageFrequency? = getValue(response, keyPath: keyPath)
                    if (valueString != nil && !(valueString?.isEmpty ?? true)) || valueInt != nil || valueUsageFrequency != nil {
                        //model[keyPath: fields.keyPath] = value
                    }else {
                        SCLAlertView.showErrorAlert(title: "Error", message: pleaseFillInAllFieldsStr, cancelButtonTitle: "OK")
                        return
                    }
                }
            }
        }
        
        self.continueSave(toBeAdded: toBeAdded)
    }
    
    private func continueSave(toBeAdded: [SiteCheckWaterOutletTemp]) {
        func startNext(index: Int) {
            if toBeAdded.count > index {
                let response = toBeAdded[index]
                let model = SiteCheckWaterOutletTemp()
                
                model.assetId = response.assetId
                model.outletType = response.outletType
                model.update = true
                model.temperature = response.temperature
                model.normalRunTime = response.normalRunTime
                model.usageFrequency = response.usageFrequency
                model.floor = response.floor
                model.room = response.room
                model.checkId = self.siteCheckModel?.checkId
                model.status = "Open"
                
                model.reading1 = response.reading1
                model.r1Date = response.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                model.reading2 = response.reading2
                model.r2Date = response.r2Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                model.reading3 = response.reading3
                model.r3Date = response.r3Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                
                self.saveSiteCheckWaterOutletTemp(model: model) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.addSiteCheckVC?.getSiteCheckWaterOutletTempByCheckId(vc: self)
            }
        }
        
        startNext(index: 0)
    }
    
    func continueSaveFromAddReading() {
        if let selectedIndex, self.itemArray.count > selectedIndex {
            let response = self.itemArray[selectedIndex]
            let temp = response.temperature
            let reading1 = response.reading1 ?? 0
            let reading2 = response.reading2 ?? 0
            let reading3 = response.reading3 ?? 0
            let isReading1ok = (temp == "Hot" && reading1 < 50) || (temp == "Cold" && reading1 > 20)
            let isReading2ok = (temp == "Hot" && reading2 < 50) || (temp == "Cold" && reading2 > 20)
            let isReading3ok = (temp == "Hot" && reading3 < 50) || (temp == "Cold" && reading3 > 20)
            
            if (!isReading1ok && !isReading2ok && !isReading3ok) {
                self.selectedIndex = nil
                self.action = false
                self.action2 = false
                self.continueSave(toBeAdded: [response])
                return
            }
            
            if self.action2, let actionModel {
                self.selectedIndex = nil
                self.action = false
                self.action2 = false
                self.continueSave(toBeAdded: [response])
                self.saveSiteAction(model: actionModel)
            }else if action && !action2 {
                self.selectedIndex = nil
                self.action = false
                self.action2 = false
                self.continueSave(toBeAdded: [response])
            }else {
                self.action = true
                self.action2 = false
            }
        }
    }
    
    @objc func readingBtnAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            
            action = false
            action2 = false
            selectedIndex = index
            actionModel = nil
            
            let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterOutletTempAddReadingVC") as! WaterOutletTempAddReadingVC
            vc.addSiteCheckVC = self.addSiteCheckVC
            vc.waterOutletTempVC = self
            vc.siteCheckModel = self.siteCheckModel
            vc.siteCheckWaterOutletTemp = item
            vc.assetsItemArray = self.assetsItemArray
            vc.siteLayoutItemArray = self.siteLayoutItemArray
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
    @objc func historyBtnAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterOutletTempReadingHistoryVC") as! WaterOutletTempReadingHistoryVC
            vc.addSiteCheckVC = self.addSiteCheckVC
            vc.waterOutletTempVC = self
            vc.itemArray = self.waterOutletTempItemArray.filter {
                return $0.assetId == item.assetId &&
                $0.temperature == item.temperature &&
                $0.normalRunTime == item.normalRunTime &&
                $0.outletType == item.outletType &&
                $0.usageFrequency == item.usageFrequency &&
                $0.floor == item.floor &&
                $0.room == item.room
            }
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
    @objc func deleteItemBtnAction(_ sender: ActionButton) {
        if self.itemArray.count == 1 {
            return
        }
        let index = sender.tag
        if self.itemArray.count > index {
            self.itemArray.remove(at: index)
            self.reloadSpreadsheetView()
        }
    }
    
    func removeDuplicates(from array: [SiteCheckWaterOutletTemp]) -> [SiteCheckWaterOutletTemp] {
        var seen = Set<String>()
        return array.filter { item in
            if let assetId = item.assetId, let outletType = item.outletType, let temperature = item.temperature, let normalRunTime = item.normalRunTime, let floor = item.floor, let room = item.room {
                let key = "\(assetId)-\(outletType)-\(temperature)-\(normalRunTime)-\(floor)-\(room)"
                if !seen.contains(key) {
                    seen.insert(key)
                    return true
                }
            }
            return false
        }
    }

}

//MARK: - Fields enum
extension WaterOutletTempVC {
    enum Fields: String, CaseIterable {
        case Asset = "Asset"
        case OutletType = "Outlet Type"
        case Temperature = "Temperature"
        case NormRunTime = "Norm Run Time"
        case UsageFrequency = "Usage Frequency"
        case Floor = "Floor"
        case Room = "Room"
        case Readings = "Readings"
        case Empty = ""
        
        static var compulsoryFields: [Fields] {
            var allFields: [Fields] = Fields.allCases
            allFields.removeAll { $0 == .Readings || $0 == .Empty }
            return allFields
        }
        
        var placeholder: String {
            switch self {
            case .Asset, .OutletType, .Temperature, .NormRunTime, .UsageFrequency, .Floor, .Room:
                return "Select \(self.rawValue)"
            case .Readings, .Empty:
                return ""
            }
        }
        
        var errorMessage: String {
            switch self {
            case .Asset, .OutletType, .Temperature, .NormRunTime, .UsageFrequency, .Floor, .Room:
                return "Please select \(self.rawValue)"
            case .Readings, .Empty:
                return ""
            }
        }
        
        var lovType: LOVTypeEnum? {
            switch self {
            case .OutletType: return .SITE_CHECK_SURVEY_OUTLET_TYPE
            case .Temperature: return .SITE_CHECK_SURVEY_TEMPRATURE
            case .NormRunTime: return .SITE_CHECK_SURVEY_NORM_RUN_TIME
            default: return nil
            }
        }
        
        var keyPath: AnyKeyPath? {
            switch self {
            case .Asset: return \SiteCheckWaterOutletTemp.assetId
            case .OutletType: return \SiteCheckWaterOutletTemp.outletType
            case .Temperature: return \SiteCheckWaterOutletTemp.temperature
            case .NormRunTime: return \SiteCheckWaterOutletTemp.normalRunTime
            case .UsageFrequency: return \SiteCheckWaterOutletTemp.usageFrequency
            case .Floor: return \SiteCheckWaterOutletTemp.floor
            case .Room: return \SiteCheckWaterOutletTemp.room
            case .Readings: return nil
            case .Empty: return nil
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension WaterOutletTempVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
    
    func hideLoadingAndShowError(message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
}

//MARK: - load data
extension WaterOutletTempVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func saveSiteCheckWaterOutletTemp(model: SiteCheckWaterOutletTemp, successCompletion: @escaping SuccessCompletion) {
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckWaterOutletTemp(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckWaterOutletTemp>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.id != nil {
                        successCompletion()
                        //self.saveSiteAction(model: single, successCompletion: successCompletion)
                    }else {
                        self.hideLoadingAndShowError()
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func reloadAfterGetSiteCheckWaterOutletTempByCheckId(array: [SiteCheckWaterOutletTemp]) {
        if array.isEmpty {
            self.hideLoadingAndShowError()
        }else {
            self.waterOutletTempItemArray = array
            self.reloadViews()
            self.reloadSpreadsheetView()
            self.loadingSCLAlertView.hideView()
            SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
        }
    }
    
    func saveSiteAction(model: ActionModel) {
        let apiService = ApiService.siteActionsPUTapi(siteModel: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                break
            }
        }
    }
    
}

extension WaterOutletTempVC {
    
    func setupViews() {
        self.setUpSearchOverlayImage()
        
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: CustomTextFieldCell.className(), bundle: nil), forCellWithReuseIdentifier: CustomTextFieldCell.className())
        self.spreadsheetView.register(UINib(nibName: OptionBtnXibCell.className(), bundle: nil), forCellWithReuseIdentifier: OptionBtnXibCell.className())
        self.spreadsheetView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadViews()
        self.reloadSpreadsheetView()
    }
    
    func reloadViews() {
        if self.waterOutletTempItemArray.isEmpty {
            let item = SiteCheckWaterOutletTemp()
            item.isEditing = true
            item.isForAddNew = true
            self.itemArray.append(item)
        }else {
            self.waterOutletTempItemArray.reverse()
            self.itemArray = self.removeDuplicates(from: self.waterOutletTempItemArray)
        }
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
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
    
    func setupLOVMenu(view: OptionBtnXib, field: Fields, index: Int) {
        if self.itemArray.count > index {
            let response = self.itemArray[index]
            
            guard let lovType = field.lovType else { return }
            let defaultStr = field.placeholder
            
            let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
                guard let self else { return }
                self.selectedLOVIds[lovType] = item?.id
                let stringValue = item?.lovValue
                switch lovType {
                case .SITE_CHECK_SURVEY_OUTLET_TYPE:
                    response.outletType = stringValue
                    break
                case .SITE_CHECK_SURVEY_TEMPRATURE:
                    response.temperature = stringValue
                    break
                case .SITE_CHECK_SURVEY_NORM_RUN_TIME:
                    response.normalRunTime = stringValue
                    break
                default:
                    break
                }
                view.lblText.text = item?.lovValue ?? defaultStr
                self.setupLOVMenu(view: view, field: field, index: index)
                self.reloadSpreadsheetView()
            }
            
            var actions: [UIMenuElement] = []
            let selectedId = self.selectedLOVIds[lovType]
            let titleAction = UIAction(title: defaultStr, state: selectedId == nil ? .on : .off) { [weak self] _ in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            if let itemArray = self.asbestosLOVDict[lovType] {
                for item in itemArray {
                    let action = UIAction(title: item.lovValue ?? "", state: selectedId == item.id ? .on : .off) { [weak self] action in
                        guard self != nil else { return }
                        performAction(item)
                    }
                    actions.append(action)
                }
            }
            
            view.btnDownClick.menu = UIMenu(children: actions)
            view.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
    func setupUsageFrequencyMenu(view: OptionBtnXib, index: Int) {
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            let defaultStr = Fields.UsageFrequency.rawValue
            
            let performAction: ((SiteCheckWaterOutletTemp.UsageFrequency?) -> Void) = { [weak self] value in
                guard let self else { return }
                item.usageFrequency = value
                if let value {
                    view.lblText.text = "\(value)"
                }else {
                    view.lblText.text = defaultStr
                }
                self.setupUsageFrequencyMenu(view: view, index: index)
                self.reloadSpreadsheetView()
            }
            
            var actions: [UIMenuElement] = []
            let titleAction = UIAction(title: defaultStr, state: item.usageFrequency == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for value in SiteCheckWaterOutletTemp.UsageFrequency.allCases {
                let action = UIAction(title: "\(value.rawValue)", state: item.usageFrequency == value ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(value)
                }
                actions.append(action)
            }
            view.btnDownClick.menu = UIMenu(children: actions)
            view.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
    func setupFloorMenu(view: OptionBtnXib, index: Int) {
        if self.itemArray.count > index {
            let response = self.itemArray[index]
            let defaultStr = Fields.Floor.placeholder
            
            let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
                guard let self else { return }
                response.floor = item?.id?.stringValue
                view.lblText.text = item?.nodeName ?? defaultStr
                self.setupFloorMenu(view: view, index: index)
                self.reloadSpreadsheetView()
            }
            
            var actions: [UIMenuElement] = []
            let titleAction = UIAction(title: defaultStr, state: response.floor?.intValue == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for item in self.selectedFloorItemArray {
                let action = UIAction(title: item.nodeName ?? "", state: response.floor?.intValue == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
            view.btnDownClick.menu = UIMenu(children: actions)
            view.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
    func setupRoomMenu(view: OptionBtnXib, index: Int) {
        if self.itemArray.count > index {
            let response = self.itemArray[index]
            let defaultStr = Fields.Room.placeholder
            
            let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
                guard let self else { return }
                response.room = item?.id?.stringValue
                view.lblText.text = item?.nodeName ?? defaultStr
                self.setupRoomMenu(view: view, index: index)
                self.reloadSpreadsheetView()
            }
            
            var actions: [UIMenuElement] = []
            let titleAction = UIAction(title: defaultStr, state: response.room?.intValue == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for item in self.selectedRoomItemArray {
                let action = UIAction(title: item.nodeName ?? "", state: response.room?.intValue == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
            view.btnDownClick.menu = UIMenu(children: actions)
            view.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension WaterOutletTempVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if self.loadingStatus.hasData {
            return 1+self.itemArray.count
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
        guard self.headerColumnNames.count > column else { return nil }
        let headerText = self.headerColumnNames[column]
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
            
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
            cell.mainLbl.textColor = UIColor.white
            
            cell.mainLbl.text = headerText.rawValue
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
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let isEditing = item.isEditing ?? false
                let isForAddNew = item.isForAddNew ?? false
                let bgColor = isForAddNew ? UIColor.white : UIColor(appColor: .GrayStatusBG)
                
                switch headerText {
                case .Asset:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: CustomTextFieldCell.className(), for: indexPath) as! CustomTextFieldCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.isUserInteractionEnabled = isEditing
                    cell.xib.textField.backgroundColor = bgColor
                    
                    cell.xib.textField.placeholder = ""
                    if let assetId = item.assetId, let asset = self.assetsItemArray.first(where: { $0.assetId == Int(assetId) }) {
                        cell.xib.textField.text = getAssetDisplayStrForSiteCheck(asset)
                    }else {
                        cell.xib.textField.text = ""
                    }
                    if isEditing {
                        cell.xib.textField.tag = index
                        cell.xib.textField.delegate = self
                        cell.xib.textField.textChanged { [weak self] in
                            guard let self else { return }
                            self.reloadFilterAssestsItemArray(textField: cell.xib.textField)
                        }
                    }else {
                        cell.xib.textField.tag = -1
                        cell.xib.textField.delegate = nil
                    }
                    
                    return cell
                case .OutletType, .Temperature, .NormRunTime, .UsageFrequency, .Floor, .Room:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: OptionBtnXibCell.className(), for: indexPath) as! OptionBtnXibCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.isUserInteractionEnabled = isEditing
                    cell.optionXIB.dummyTF.backgroundColor = bgColor
                    
                    cell.optionXIB.btnDownClick.menu = nil
                    cell.optionXIB.btnDownClick.showsMenuAsPrimaryAction = false
                    cell.optionXIB.btnDownClick.removeAction()
                    
                    let placeholder = headerText.placeholder
                    if headerText == .OutletType {
                        cell.optionXIB.lblText.text = item.outletType ?? placeholder
                        if isEditing {
                            self.setupLOVMenu(view: cell.optionXIB, field: headerText, index: index)
                        }
                    }else if headerText == .Temperature {
                        cell.optionXIB.lblText.text = item.temperature ?? placeholder
                        if isEditing {
                            self.setupLOVMenu(view: cell.optionXIB, field: headerText, index: index)
                        }
                    }else if headerText == .NormRunTime {
                        cell.optionXIB.lblText.text = item.normalRunTime ?? placeholder
                        if isEditing {
                            self.setupLOVMenu(view: cell.optionXIB, field: headerText, index: index)
                        }
                    }else if headerText == .UsageFrequency {
                        cell.optionXIB.lblText.text = item.usageFrequency?.rawValue ?? placeholder
                        if isEditing {
                            self.setupUsageFrequencyMenu(view: cell.optionXIB, index: index)
                        }
                    }else if headerText == .Floor {
                        cell.optionXIB.lblText.text = self.selectedFloorItemArray.first(where: { $0.id == item.floor?.intValue })?.nodeName ?? placeholder
                        if isEditing {
                            self.setupFloorMenu(view: cell.optionXIB, index: index)
                        }
                    }else if headerText == .Room {
                        cell.optionXIB.lblText.text = self.selectedRoomItemArray.first(where: { $0.id == item.room?.intValue })?.nodeName ?? placeholder
                        if isEditing {
                            self.setupRoomMenu(view: cell.optionXIB, index: index)
                        }
                    }
                    return cell
                case .Readings:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    cell.mainLbl.text = getReadingForWaterOutletTemp(item) ?? ""
                    return cell
                case .Empty:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    
                    cell.isCenterHorizontally = true
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    
                    let refHeight = cell.stackView.frame.height
                    if isAllFilledForWaterOutletTemp(item) {
                        let btn1 = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "chart.line.uptrend.xyaxis"), target: self, action: #selector(self.readingBtnAction(_:)))
                        cell.stackView.addArrangedSubview(btn1)
                        let btn2 = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "clock.fill"), target: self, action: #selector(self.historyBtnAction(_:)))
                        cell.stackView.addArrangedSubview(btn2)
                    }
                    if isForAddNew || isEditing {
                        let btn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "trash.fill"), target: self, action: #selector(self.deleteItemBtnAction(_:)))
                        cell.stackView.addArrangedSubview(btn)
                    }
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
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerWidth = getLabelSize(text: headerText.rawValue, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if !self.loadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.headerColumnNames.count))
            }else {
                switch headerText {
                case .Asset, .OutletType, .Temperature, .NormRunTime, .UsageFrequency, .Floor, .Room:
                    return max(headerWidth, 12+200+12)
                case .Readings:
                    let textArray = self.itemArray.compactMap { getReadingForWaterOutletTemp($0) ?? "" }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                case .Empty:
                    var totalItem: CGFloat = 0
                    let itemWidth: CGFloat = 40
                    let spacing: CGFloat = 8
                    let padding: CGFloat = 12
                    
                    if self.itemArray.contains(where: { isAllFilledForWaterOutletTemp($0) && ($0.isEditing ?? false || $0.isForAddNew ?? false) }) {
                        totalItem += 3
                    }else if self.itemArray.contains(where: { isAllFilledForWaterOutletTemp($0) }) {
                        totalItem += 2
                    }else if self.itemArray.contains(where: { $0.isEditing ?? false || $0.isForAddNew ?? false }) {
                        totalItem += 1
                    }
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
        let maxWidth: CGFloat = isiPadDevice ? 300 : 200
        
        if row == 0 {
            let headerHeight = getMaxLabelSize(textArray: self.headerColumnNames.compactMap({ $0.rawValue }), font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else if !self.loadingStatus.hasData {
            return getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
        }else {
            let index = row-1
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let textArray = [getReadingForWaterOutletTemp(item) ?? ""]
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight, 10+40+10)
            }
            return 0
        }
    }
    
}

//MARK: - Search Table View
extension WaterOutletTempVC {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        if let selectedTextField, selectedTextField.isEditing {
            self.updateSearchTableView(for: selectedTextField)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyBoardHeight = 0.0
    }
    
    func setUpSearchOverlayImage() {
        self.searchOverlayView = UIView(frame: self.view.bounds)
        self.searchOverlayView.backgroundColor = .clear
        self.searchOverlayView.isHidden = true // Initially hidden
        self.view.addSubview(self.searchOverlayView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSearchTableView))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hideSearchTableView))
        self.searchOverlayView.addGestureRecognizer(panGesture)
        self.searchOverlayView.addGestureRecognizer(tapGesture)
    }
    
    func showSearchTableView() {
        self.searchOverlayView.isHidden = false
        self.searchTableView?.isHidden = false
    }
    
    @objc func hideSearchTableView() {
        self.searchOverlayView.isHidden = true
        self.searchTableView?.isHidden = true
        self.searchTableView?.hideTableView()
    }
    
    func updateSearchTableView(for textField: UITextField) {
        guard textField.isEditing else { return }
        showSearchTableView()
        if self.searchTableView == nil {
            self.searchTableView = CustomTableView()
        }
        self.searchTableView?.type = .faultsIdentifiedTag
        
        // Safely find the cell containing the text field
        var textFieldFrame = textField.convert(textField.bounds, to: view)
        textFieldFrame.origin.x = 20
        textFieldFrame.size.width = view.frame.width-(20+20)
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - topSafeArea - navigationHeight - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        let desiredTableViewHeight: CGFloat = CGFloat(min(filterAssestsItemArray.count, 5)*50)
        
        // Determine whether to show the table view below or above the text field
        if desiredTableViewHeight <= availableSpaceBelowTextField {
            // Show the tableView below the text field
            self.searchTableView?.frame = CGRect(
                x: textFieldFrame.minX,
                y: textFieldFrame.maxY + 5,
                // Small gap below the text field
                width: textFieldFrame.width,
                height: desiredTableViewHeight
            )
        } else if desiredTableViewHeight <= availableSpaceAboveTextField {
            // Show the tableView above the text field
            self.searchTableView?.frame = CGRect(
                x: textFieldFrame.minX,
                y: textFieldFrame.minY - desiredTableViewHeight - 5,
                // Small gap above the text field
                width: textFieldFrame.width,
                height: desiredTableViewHeight
            )
        } else {
            // Show the tableView with maximum available space below or above
            if availableSpaceBelowTextField >= availableSpaceAboveTextField {
                // Show the tableView below, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceBelowTextField)
                self.searchTableView?.frame = CGRect(
                    x: textFieldFrame.minX,
                    y: textFieldFrame.maxY + 5,
                    width: textFieldFrame.width,
                    height: tableViewHeight
                )
            } else {
                // Show the tableView above, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceAboveTextField)
                self.searchTableView?.frame = CGRect(
                    x: textFieldFrame.minX,
                    y: textFieldFrame.minY - tableViewHeight - 5,
                    width: textFieldFrame.width,
                    height: tableViewHeight
                )
            }
        }
        
        let itemArray: [AssetDetailsResponse] = self.filterAssestsItemArray
        self.searchTableView?.isHidden = itemArray.isEmpty
        self.searchTableView?.tagAssetItemArray = itemArray
        self.searchTableView?.showTableView(with: itemArray)
        view.addSubview(self.searchTableView!)
        
        self.searchTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? AssetDetailsResponse, let id = item.assetId {
                    textField.text = getAssetDisplayStrForSiteCheck(item)
                    let index = textField.tag
                    guard index >= 0 else { return }
                    if self.itemArray.count > index {
                        let item = self.itemArray[index]
                        item.assetId = id
                    }
                    self.reloadSpreadsheetView()
                }
            }
        }
    }
    
    func reloadFilterAssestsItemArray(textField: UITextField) {
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filterAssestsItemArray = self.assetsItemArray.filter { item in
                return (text.isEmpty || getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension WaterOutletTempVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let index = textField.tag
        guard index >= 0 else { return }
        self.selectedTextField = textField
        self.reloadFilterAssestsItemArray(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        guard index >= 0 else { return }
        self.selectedTextField = nil
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            if textField.text?.trimmingSpacesAndLines().isEmpty ?? false {
                item.assetId = nil
            }
            if let assetId = item.assetId, let asset = self.assetsItemArray.first(where: { $0.assetId == Int(assetId) }) {
                textField.text = getAssetDisplayStrForSiteCheck(asset)
            }else {
                textField.text = ""
            }
            self.hideSearchTableView()
        }
    }
}
