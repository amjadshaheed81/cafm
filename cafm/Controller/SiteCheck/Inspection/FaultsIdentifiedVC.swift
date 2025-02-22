//
//  FaultsIdentifiedVC.swift
//  cafm
//
//  Created by NS on 21/09/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class FaultsIdentifiedVC: UIViewController {
    
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
    
    var isForAuditObservations: Bool = false
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    var itemArray: [InspectionFaultModel] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    private var filterAssestsItemArray: [AssetDetailsResponse] = []
    
    private var headerColumnNames: [Fields] = []
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let selectRatingStr = "Select Rating"
    private let faultDataSavedStr = "Fault data saved"
    private let auditDataSavedStr = "Audit data saved"
    private let pleaseFillInAllFieldsStr = "Please fill in all fields"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustSpreadsheetView()
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
        self.title = self.isForAuditObservations ? "Observations" : "Faults Identified"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func recordNewBtnClicked(_ sender: ActionButton) {
        let item = InspectionFaultModel()
        item.isEditing = true
        item.isForAddNew = true
        self.itemArray.append(item)
        self.reloadSpreadsheetView()
    }
    
    @IBAction func saveBtnClicked(_ sender: PrimaryButton) {
        if self.isForAuditObservations {
            self.saveAuditObservationAction()
        }else {
            self.saveFaultsIdentifiedAction()
        }
    }
    
    func saveFaultsIdentifiedAction() {
        let toBeAdded = self.itemArray.filter { $0.isForAddNew == true }
        
        if toBeAdded.isEmpty {
            return
        }
        
        if toBeAdded.contains(where: { model in
            if model.assetId == nil || model.faultDescription == nil || model.dateRaised == nil || model.rating == nil || model.selectedFile == nil || model.action == nil {
                return true
            }else if model.assetId?.isEmpty ?? false || model.faultDescription?.isEmpty ?? false || model.dateRaised?.isEmpty ?? false || model.action?.isEmpty ?? false {
                return true
            }
            return false
        }) {
            SCLAlertView.showErrorAlert(title: "Error", message: pleaseFillInAllFieldsStr, cancelButtonTitle: "OK")
            return
        }
        
        func startNext(index: Int) {
            if toBeAdded.count > index {
                let model = toBeAdded[index]
                model.add = true
                model.dateRaised = model.dateRaised?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                model.siteId = UserConstants.shared.selectedSiteID
                model.checkId = self.siteCheckModel?.checkId
                model.status = .open
                self.uploadSiteCheckFile(model: toBeAdded[index]) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.addSiteCheckVC?.getSiteCheckInspectionFaultBySiteId(vc: self)
            }
        }
        
        startNext(index: 0)
    }
    
    func saveAuditObservationAction() {
        let toBeAdded = self.itemArray.filter { $0.isForAddNew == true }
        
        if toBeAdded.isEmpty {
            return
        }
        
        if toBeAdded.contains(where: { model in
            if model.assetId == nil || model.summary == nil || model.dateRaised == nil || model.rating == nil || model.selectedFile == nil || model.action == nil {
                return true
            }else if model.assetId?.isEmpty ?? false || model.summary?.isEmpty ?? false || model.dateRaised?.isEmpty ?? false || model.action?.isEmpty ?? false {
                return true
            }
            return false
        }) {
            SCLAlertView.showErrorAlert(title: "Error", message: pleaseFillInAllFieldsStr, cancelButtonTitle: "OK")
            return
        }

        func startNext(index: Int) {
            if toBeAdded.count > index {
                let model = toBeAdded[index]
                //model.add = true
                model.dateRaised = model.dateRaised?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                model.siteId = UserConstants.shared.selectedSiteID
                model.checkId = self.siteCheckModel?.checkId
                model.status = .open
                self.uploadSiteCheckFile(model: toBeAdded[index]) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.addSiteCheckVC?.getSiteCheckAuditByCheckId(vc: self)
            }
        }
        
        startNext(index: 0)
    }
    
    @objc func downloadImageBtnAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            if var url = item.imageUrl {
                if let sasToken = UserConstants.shared.sasToken {
                    url = url+"?"+sasToken
                }
                CAFMFileUtils.shared.downloadAndShareFile(url, from: self, sender: sender, shouldDeleteAfterSharing: true)
            }
        }
    }
    
    @objc func editItemBtnAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            item.isEditing = true
            self.reloadSpreadsheetView()
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
    
}

//MARK: - Fields enum
extension FaultsIdentifiedVC {
    enum Fields: String {
        case fault = "Fault"
        case observationSummary = "Observation Summary"
        case asset = "Asset"
        case dateRaised = "Date Raised"
        case rating = "Rating"
        case image = "Image"
        case suggestedAction = "Suggested Action"
        case empty = ""
    }
}

//MARK: - EmptyViewDelegate
extension FaultsIdentifiedVC: EmptyViewDelegate {
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
extension FaultsIdentifiedVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func uploadSiteCheckFile(model: InspectionFaultModel, successCompletion: @escaping SuccessCompletion) {
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckFileUpload
        APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
            if let fileName = model.selectedFile?.fileName {
                if let image = model.selectedFile?.image {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: "image/jpeg")
                    }
                }else if let fileURL = model.selectedFile?.fileURL {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: APIClient.mimeType(for: fileURL))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let data = fileName.data(using: .utf8) {
                    multipartFormData.append(data, withName: "fileName")
                }
            }
            if let data = "\(siteId)".data(using: .utf8) {
                multipartFormData.append(data, withName: "siteId")
            }
        }) { [weak self] (result: Result<String, Error>) in
            guard let self else { return }
            switch result {
            case .success(let success):
                model.imageUrl = success
                if self.isForAuditObservations {
                    self.saveSiteCheckAudit(model: model, successCompletion: successCompletion)
                }else {
                    self.saveSiteCheckInspectionFault(model: model, successCompletion: successCompletion)
                }
                break
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func saveSiteCheckInspectionFault(model: InspectionFaultModel, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckInspectionFault(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<InspectionFaultModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.faultId != nil {
                        successCompletion()
                        self.saveSiteAction(model: single)
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
    
    func saveSiteCheckAudit(model: InspectionFaultModel, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckAudit(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<InspectionFaultModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.auditId != nil {
                        successCompletion()
                        self.saveSiteAction(model: single)
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
    
    func saveSiteAction(model: InspectionFaultModel) {
        guard let siteCheckModel else {
            //self.hideLoadingAndShowError()
            return
        }
        
        let now = Date()
        let type = siteCheckModel.type ?? ""
        let subType = siteCheckModel.subType ?? ""
        let category = siteCheckModel.category ?? ""
        let dateStr = now.transformToString(dateFormat: ddMMyyyyStr)
        let dateReqStr = now.transformToString(dateFormat: kRequestDateFormat)
        
        let actionModel = ActionModel()
        actionModel.type = type
        actionModel.status = .reported
        actionModel.createdAt = dateReqStr
        actionModel.siteId = UserConstants.shared.selectedSiteID
        actionModel.userId = UserConstants.shared.currentUserID
        actionModel.actionImage = model.imageUrl
        actionModel.taggedAsset = model.assetId
        if self.isForAuditObservations {
            let observation = model.summary ?? ""
            actionModel.observation = observation
            actionModel.desc = "\(observation) - \(dateStr)"
        }else {
            actionModel.observation = model.faultDescription
            actionModel.desc = "\(type) - \(subType) - \(category) - \(dateStr)"
            actionModel.requiredAction = model.action
            actionModel.riskScore = (model.rating ?? 0)*5
            actionModel.dueDate = dateReqStr
        }
        
        let apiService = ApiService.siteActionsPUTapi(siteModel: actionModel)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    //successCompletion()
                    break
                case .array:
                    //self.hideLoadingAndShowError()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                //self.hideLoadingAndShowError()
                break
            }
        }
    }
    
    func reloadAfterGetSiteCheckInspectionFaultBySiteId(array: [InspectionFaultModel]) {
        if array.isEmpty {
            self.hideLoadingAndShowError()
        }else {
            self.itemArray = array
            self.reloadSpreadsheetView()
            self.loadingSCLAlertView.hideView()
            SCLAlertView().showSuccess("", subTitle: self.faultDataSavedStr)
        }
    }
    
    func reloadAfterGetSiteCheckAuditByCheckId(array: [InspectionFaultModel]) {
        if array.isEmpty {
            self.hideLoadingAndShowError()
        }else {
            self.itemArray = array
            self.reloadViews()
            self.reloadSpreadsheetView()
            self.loadingSCLAlertView.hideView()
            SCLAlertView().showSuccess("", subTitle: self.auditDataSavedStr)
        }
    }
    
}

//MARK: - setup views
extension FaultsIdentifiedVC {
    
    func setupViews() {
        if self.isForAuditObservations {
            self.headerColumnNames = [
                .observationSummary,
                .asset,
                .dateRaised,
                .rating,
                .image,
                .suggestedAction,
                .empty
            ]
        }else {
            self.headerColumnNames = [
                .asset,
                .fault,
                .dateRaised,
                .rating,
                .image,
                .suggestedAction,
                .empty
            ]
        }
        
        if self.itemArray.isEmpty {
            let item = InspectionFaultModel()
            item.isEditing = true
            item.isForAddNew = true
            self.itemArray.append(item)
        }
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
        self.spreadsheetView.register(UINib(nibName: ChooseImageCell.className(), bundle: nil), forCellWithReuseIdentifier: ChooseImageCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadViews()
        self.reloadSpreadsheetView()
    }
    
    func reloadViews() {
        if !self.itemArray.filter({ $0.isEditing != true && $0.isForAddNew != true }).isEmpty && self.isForAuditObservations {
            self.buttonsViewHeight.constant = .zero
            self.buttonsView.frame.size.height = self.buttonsViewHeight.constant
            self.buttonsView.isHidden = true
        }
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
    
    func setupRatingMenu(view: OptionBtnXib, index: Int) {
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            let defaultStr = selectRatingStr
            
            let performAction: ((Int?) -> Void) = { [weak self] value in
                guard let self else { return }
                item.rating = value
                if let value {
                    view.lblText.text = "\(value)"
                }else {
                    view.lblText.text = defaultStr
                }
                self.setupRatingMenu(view: view, index: index)
                //self.reloadSpreadsheetView()
            }
            
            var actions: [UIMenuElement] = []
            let titleAction = UIAction(title: defaultStr, state: item.rating == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for value in 1...5 {
                let action = UIAction(title: "\(value)", state: item.rating == value ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(value)
                }
                actions.append(action)
            }
            view.btnDownClick.menu = UIMenu(children: actions)
            view.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension FaultsIdentifiedVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
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
                let bgColor = isEditing ? UIColor.white : UIColor(appColor: .GrayStatusBG)
                
                switch headerText {
                case .fault, .observationSummary, .asset, .suggestedAction:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: CustomTextFieldCell.className(), for: indexPath) as! CustomTextFieldCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.isUserInteractionEnabled = isEditing
                    cell.xib.textField.backgroundColor = bgColor
                    
                    if headerText == .asset {
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
                    }else if headerText == .fault {
                        cell.xib.textField.placeholder = ""
                        cell.xib.textField.text = item.faultDescription ?? ""
                        cell.xib.textField.tag = -1
                        cell.xib.textField.delegate = nil
                        cell.xib.textField.textChanged { [weak self] in
                            guard self != nil else { return }
                            let tf: UITextField! = cell.xib.textField
                            item.faultDescription = tf.text
                        }
                    }else if headerText == .suggestedAction {
                        cell.xib.textField.placeholder = ""
                        cell.xib.textField.text = item.action ?? ""
                        cell.xib.textField.tag = -1
                        cell.xib.textField.delegate = nil
                        cell.xib.textField.textChanged { [weak self] in
                            guard self != nil else { return }
                            let tf: UITextField! = cell.xib.textField
                            item.action = tf.text
                        }
                    }else if headerText == .observationSummary {
                        cell.xib.textField.placeholder = ""
                        cell.xib.textField.text = item.summary ?? ""
                        cell.xib.textField.tag = -1
                        cell.xib.textField.delegate = nil
                        cell.xib.textField.textChanged { [weak self] in
                            guard self != nil else { return }
                            let tf: UITextField! = cell.xib.textField
                            item.summary = tf.text
                        }
                    }
                    return cell
                case .dateRaised, .rating:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: OptionBtnXibCell.className(), for: indexPath) as! OptionBtnXibCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.isUserInteractionEnabled = isEditing
                    cell.optionXIB.dummyTF.backgroundColor = bgColor
                    
                    cell.optionXIB.btnDownClick.menu = nil
                    cell.optionXIB.btnDownClick.showsMenuAsPrimaryAction = false
                    cell.optionXIB.btnDownClick.removeAction()
                    
                    if headerText == .dateRaised {
                        cell.optionXIB.imageView.image = UIImage(systemName: "calendar")
                        cell.optionXIB.lblText.text = item.dateRaised?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                        cell.optionXIB.btnDownClick.tag = index
                        if isEditing {
                            cell.optionXIB.btnDownClick.addAction { [weak self] in
                                guard let self else { return }
                                self.openDatePickerForDateRaised(cell.optionXIB.btnDownClick, view: cell.optionXIB)
                            }
                        }
                    }else if headerText == .rating {
                        cell.optionXIB.imageView.image = UIImage(systemName: "chevron.down")
                        if let rating = item.rating {
                            cell.optionXIB.lblText.text = "\(rating)"
                        }else {
                            cell.optionXIB.lblText.text = selectRatingStr
                        }
                        if isEditing {
                            self.setupRatingMenu(view: cell.optionXIB, index: index)
                        }
                    }
                    return cell
                case .image:
                    if isEditing {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ChooseImageCell.className(), for: indexPath) as! ChooseImageCell
                        cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        cell.backgroundColor = UIColor.white
                        
                        cell.xib.fileNameLbl.text = item.selectedFile?.fileName ?? "No file chosen"
                        CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: cell.xib.chooseFileBtn, tag: index, allowPhotos: true, supportedTypes: [.image, .pdf])
                        return cell
                    }else {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                        cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        cell.backgroundColor = UIColor.white
                        
                        cell.isCenterHorizontally = true
                        cell.stackView.arrangedSubviews.forEach { view in
                            cell.stackView.removeArrangedSubview(view)
                            view.removeFromSuperview()
                        }
                        
                        let refHeight = cell.stackView.frame.height
                        let btn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "arrow.down.to.line.alt"), target: self, action: #selector(self.downloadImageBtnAction(_:)))
                        cell.stackView.addArrangedSubview(btn)
                        return cell
                    }
                    
                case .empty:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    
                    cell.isCenterHorizontally = true
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    
                    let refHeight = cell.stackView.frame.height
                    if isForAddNew {
                        let btn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "trash.fill"), target: self, action: #selector(self.deleteItemBtnAction(_:)))
                        cell.stackView.addArrangedSubview(btn)
                    }else if !self.isForAuditObservations && !isEditing {
                        let btn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "square.and.pencil"), target: self, action: #selector(self.editItemBtnAction(_:)))
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
                case .fault, .observationSummary, .asset, .dateRaised, .rating, .suggestedAction:
                    return max(headerWidth, 12+200+12)
                case .image:
                    if self.itemArray.contains(where: { $0.isEditing == true }) {
                        return max(headerWidth, 12+120+15+100+15+12)
                    }else {
                        return max(headerWidth, 12+40+12)
                    }
                case .empty:
                    return max(headerWidth, 12+40+12)
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
            return 10+40+10
        }
    }
    
}

//MARK: - CAFMDatePickerDelegate
extension FaultsIdentifiedVC: CAFMDatePickerDelegate {
    
    func openDatePickerForDateRaised(_ sender: UIButton, view: OptionBtnXib) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            var selectedDate: Date?
            if let dateString = item.dateRaised, let date = dateString.transformToDate(dateFormat: kResponseDateFormat) {
                selectedDate = date
            }
            
            CAFMDatePicker(delegate: self).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: selectedDate, hideButton: true) { [weak self] date in
                guard let self else { return }
                item.dateRaised = date?.transformToString(dateFormat: kResponseDateFormat)
                view.lblText.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                //self.reloadSpreadsheetView()
            }
        }
    }
    
    func datePickerDidSelectDate(_ date: Date?, tag: Int) {
        
    }
    
    func datePickerDidClose(tag: Int) {
        
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension FaultsIdentifiedVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        let index = tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            item.selectedFile = fileData
            if let cell = self.spreadsheetView.cellForItem(at: IndexPath(row: index+1, section: 4)) as? ChooseImageCell {
                cell.xib.fileNameLbl.text = fileData.fileName
            }
            //self.reloadSpreadsheetView()
        }
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}

//MARK: - Search Table View
extension FaultsIdentifiedVC {
    
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
                        item.assetId = "\(id)"
                    }
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
extension FaultsIdentifiedVC: UITextFieldDelegate {
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
