//
//  AddSiteCheckVC.swift
//  cafm
//
//  Created by NS on 14/09/24.
//
//

import UIKit
import SCLAlertView

var globalKeyBoradHeight = 380.0

class AddSiteCheckVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleMainView: UIView!
    @IBOutlet weak var titleMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleBadgeXIB: TitleBadgeView!
    
    @IBOutlet weak var typeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var subTypeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var categoryXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var categoryXIBBottomToSubTypeXIB: NSLayoutConstraint!
    @IBOutlet weak var startDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var dueDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var leadXIB: TextFiledDataXib!
    @IBOutlet weak var assistantXIB: TextFiledDataXib!
    @IBOutlet weak var repeatsMainView: UIView!
    @IBOutlet weak var repeatsMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repeatsXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var disableUserInteractionView: UIView!
    
    @IBOutlet weak var printPDFReportBtn: ActionButton!
    @IBOutlet weak var saveContinueBtn: PrimaryButton!
    
    @IBOutlet weak var tableMainView: UIView!
    @IBOutlet weak var tableMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchTableView: CustomTableView?
    private var searchOverlayView: UIView!
    private var keyBoardHeight: CGFloat = 0.0
    
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
    
    weak var delegate: AddSiteCheckDelegate?
    var isForCreateNew: Bool = false
    var isViewModeEdit: Bool = false
    private var isFieldsEditable: Bool {
        return self.isForCreateNew
    }
    var siteCheckModel: SiteCheckModel?
    
    var userBySiteIdItemArray: [User] = []
    var SITE_CHECK_TYPE_ItemArray: [LOV_Model] = []
    var SITE_CHECK_SUB_TYPE_ItemDict: [String: [LOV_Model]] = [:]
    var SITE_CHECK_CATEGORY_ItemDict: [String: [LOV_Model]] = [:]
    var filterLeadUserItemArray: [User] = []
    var filterAssistantUserItemArray: [User] = []
    
    private var assetsItemArray: [AssetDetailsResponse] = []
    private var externalUserTypeUserItemArray: [User] = []
    private var siteLayoutItemArray: [SiteLayoutModel] = []
    
    private var inspectionFaultItemArray: [InspectionFaultModel] = []
    private var inspectionItemArray: [SiteCheckInspectionModel] = []
    
    private var assessmentQuestionItemArray: [SiteCheckAssessmentQuestions] = []
    private var assessmentResponseItemArray: [SiteCheckAssessmentResponse] = []
    
    private var auditItemArray: [InspectionFaultModel] = []
    
    private var asbestosLOVDict: [LOVTypeEnum: [LOV_Model]] = [:]
    private var asbestosSurveyItemArray: [SiteCheckAsbestosSurvey] = []
    private var asbestosSampleItemArray: [SiteCheckAsbestosSample] = []
    
    private var raSurveyRiskFactorsItemArray: [SiteCheckRASurveyRiskFactors] = []
    private var domesticRASurveyItemArray: [SiteCheckAssessmentResponse] = []
    
    private var waterOutletTempItemArray: [SiteCheckWaterOutletTemp] = []
    
    private var waterTankItemArray: [SiteCheckWaterTank] = []
    
    var tableItemArray: [FieldsItemData] = []
    var InspectionItemArray: [FieldsItemData] = [
        (field: .faultsIdentified, status: nil),
        (field: .certificate, status: nil),
    ]
    var AssessmentItemArray: [FieldsItemData] = [
        (field: .questions, status: nil),
    ]
    var AuditItemArray: [FieldsItemData] = [
        (field: .observations, status: nil),
    ]
    var MonthlyAuditItemArray: [FieldsItemData] = [
        (field: .questions, status: nil),
    ]
    var AnnualWinterAuditAuditItemArray: [FieldsItemData] = [
        (field: .questions, status: nil),
    ]
    var SurveyWaterOutletTemperatureItemArray: [FieldsItemData] = [
        (field: .waterOutletTemperatureTests, status: nil),
    ]
    var SurveyWaterDomesticRAItemArray: [FieldsItemData] = [
        (field: .riskFactors, status: nil),
    ]
    var SurveyAsbestosItemArray: [FieldsItemData] = [
        (field: .asbestosSurvey, status: nil),
        (field: .asbestosSamples, status: nil),
    ]
    var SurveyWaterTankItemArray: [FieldsItemData] = [
        (field: .tankDetails, status: nil),
    ]
    
    var selectedTypeId: Int?
    var selectedSubTypeId: Int?
    var selectedCategoryId: Int?
    var selectedLeadUser: User? {
        didSet {
            let textField: UITextField! = self.leadXIB.tfData
            let item = selectedLeadUser
            textField.text = getUserDisplayStr(item)
        }
    }
    var selectedAssistantUser: User? {
        didSet {
            let textField: UITextField! = self.assistantXIB.tfData
            let item = selectedAssistantUser
            textField.text = getUserDisplayStr(item)
        }
    }
    var selectedStartDate: Date? {
        didSet {
            self.startDateXIB.optionXIB.lblText.text = selectedStartDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        }
    }
    var selectedDueDate: Date? {
        didSet {
            self.dueDateXIB.optionXIB.lblText.text = selectedDueDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        }
    }
    var selectedRepeatFreq: SiteCheckModel.RepeatFrequency? {
        didSet {
            let view: OptionBtnWithTitleXIB = self.repeatsXIB
            let defaultStr = SiteCheckModel.RepeatFrequency.default.rawValue
            let item = selectedRepeatFreq
            view.optionXIB.lblText.text = item?.rawValue ?? defaultStr
        }
    }
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let siteCheckHasBeenAddedSuccessStr = "Site check has been added successully."
    private let failedToAddSiteCheckStr = "Failed to add site check."
    
    private let dueDateTag: Int = 1
    
    lazy var fieldBGColor: UIColor = {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        if isForCreateNew {
            self.title = "Site Check - New"
        }else {
            self.title = "Update Site Check"
        }
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        if self.leadXIB.tfData.isEditing {
            self.updateSearchTableView(for: self.leadXIB.tfData)
        }else if self.assistantXIB.tfData.isEditing {
            self.updateSearchTableView(for: self.assistantXIB.tfData)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyBoardHeight = 0.0
    }
    
    @IBAction func printPDFReportBtnClicked(_ sender: ActionButton) {
        
    }
    
    @IBAction func saveContinueBtnClicked(_ sender: PrimaryButton) {
        let model = SiteCheckModel()
        model.siteId = UserConstants.shared.selectedSiteID
        model.status = .open
        
        if let id = selectedTypeId, let value = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == id })?.lovValue {
            model.type = value
            if let id = selectedSubTypeId, let itemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[value], let value = itemArray.first(where: { $0.id == id })?.lovValue {
                model.subType = value
                if let id = selectedCategoryId, let itemArray = self.SITE_CHECK_CATEGORY_ItemDict[value], let value = itemArray.first(where: { $0.id == id })?.lovValue {
                    model.category = value
                }else {
                    if model.type != "Assessment" && model.type != "Audit" {
                        SCLAlertView.showErrorAlert(title: "Error", message: Fields.category.emptyErrorStr, cancelButtonTitle: "OK")
                        return
                    }
                }
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: Fields.subType.emptyErrorStr, cancelButtonTitle: "OK")
                return
            }
            
            if let selectedRepeatFreq, selectedRepeatFreq != .default {
                model.repeatFrequency = selectedRepeatFreq
            }
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.type.emptyErrorStr, cancelButtonTitle: "OK")
            return
        }
        
        if let selectedStartDate {
            model.startDate = selectedStartDate.transformToString(dateFormat: kRequestDateFormat)
        }
        if let selectedDueDate {
            model.dueDate = selectedDueDate.transformToString(dateFormat: kRequestDateFormat)
        }
        
        if let selectedLeadUser, let id = selectedLeadUser.id {
            model.leadUserID = "\(id)"
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.lead.emptyErrorStr, cancelButtonTitle: "OK")
            return
        }
        
        if let selectedAssistantUser, let id = selectedAssistantUser.id {
            model.assistantUserID = "\(id)"
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.assistant.emptyErrorStr, cancelButtonTitle: "OK")
            return
        }
        
        self.saveSiteCheck(model: model)
    }
    
    func hideLoadingAndShowError(message: String?) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
}

//MARK: - Fields enum
extension AddSiteCheckVC {
    
    enum Fields: String {
        case type = "Type"
        case subType = "Sub Type"
        case category = "Category"
        case startDate = "Start Date"
        case dueDate = "Due Date"
        case lead = "Lead"
        case assistant = "Assistant"
        case repeats = "Repeats"
        
        var selectStr: String {
            switch self {
            case .type: return "Select \(self.rawValue)"
            case .subType: return "Select \(self.rawValue)"
            case .category: return "Select \(self.rawValue)"
            case .startDate: return "Select \(self.rawValue)"
            case .dueDate: return "Select \(self.rawValue)"
            case .lead: return "Select \(self.rawValue)"
            case .assistant: return "Select \(self.rawValue)"
            case .repeats: return "None"
            }
        }
        
        var emptyErrorStr: String {
            switch self {
            case .type: return "Please select \(self.rawValue)"
            case .subType: return "Please select \(self.rawValue)"
            case .category: return "Please select \(self.rawValue)"
            case .startDate: return "Please select \(self.rawValue)"
            case .dueDate: return "Please select \(self.rawValue)"
            case .lead: return "Please enter \(self.rawValue)"
            case .assistant: return "Please enter \(self.rawValue)"
            case .repeats: return "Please select \(self.rawValue)"
            }
        }
    }
    
    enum TableFields: String {
        case faultsIdentified = "Faults Identified"
        case certificate = "Certificate"
        case questions = "Questions"
        case observations = "Observations"
        case waterOutletTemperatureTests = "Water - Outlet Temperature - Tests"
        case riskFactors = "Risk Factors"
        case asbestosSurvey = "Asbestos Survey"
        case asbestosSamples = "Asbestos Samples"
        case tankDetails = "Tank Details"
    }
    
    enum FieldsStatus: String {
        case open = "Open"
        case closed = "Closed"
        case inProgress = "In Progress"
        
        var textColor: UIColor {
            switch self {
            case .open, .inProgress: return UIColor(appColor: .AmberStatus)
            case .closed: return UIColor(appColor: .GreenStatus)
            }
        }
        
        var bgColor: UIColor {
            switch self {
            case .open, .inProgress: return UIColor(appColor: .AmberStatusBG)
            case .closed: return UIColor(appColor: .GreenStatusBG)
            }
        }
    }
    
    typealias FieldsItemData = (field: TableFields, status: FieldsStatus?)
    
}

//MARK: - EmptyViewDelegate
extension AddSiteCheckVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

//MARK: - setup views
extension AddSiteCheckVC {
    
    func setupViews() {
        // disabled text color: "#3C3C434C"
        // disabled bg color: "#7878801E"
        self.disableUserInteractionView.isHidden = self.isFieldsEditable
        let bgColor = self.fieldBGColor
        
        if !self.isForCreateNew, let model = self.siteCheckModel {
            let view: TitleBadgeView! = self.titleBadgeXIB
            view.titleLbl.text = getSiteCheckDisplayStr(model)
            
            if let status = model.status {
                view.setBadgeData(text: status.rawValue, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize+1), textColor: status.textColor(), bgColor: status.textBGColor())
            }else {
                view.setBadgeData(text: nil)
            }
        }else {
            self.titleMainViewHeight.priority = .required
            self.titleMainViewHeight.constant = 0
            self.titleMainView.frame.size.height = self.titleMainViewHeight.constant
            self.titleMainView.isHidden = true
        }
        
        self.typeXIB.title = Fields.type.rawValue
        self.typeXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.typeXIB.optionXIB.lblText.text = Fields.type.selectStr
        
        self.subTypeXIB.title = Fields.subType.rawValue
        self.subTypeXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.subTypeXIB.optionXIB.lblText.text = Fields.subType.selectStr
        
        self.categoryXIB.title = Fields.category.rawValue
        self.categoryXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.categoryXIB.optionXIB.lblText.text = Fields.category.selectStr
        
        self.dueDateXIB.title = Fields.dueDate.rawValue
        self.dueDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.dueDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.dueDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.dueDateXIB.optionXIB.btnDownClick.tag = self.dueDateTag
        self.dueDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.dueDateXIB.optionXIB.btnDownClick
            //let selectedDate = self.dueDateXIB.optionXIB.lblText.text?.transformToDate(dateFormat: self.ddMMyyyyStr)
            let selectedDate = self.selectedDueDate
            self.openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate, minDate: nil, maxDate: nil) { [weak self] date in
                guard let self else { return }
                self.selectedDueDate = date
            }
        }
        
        self.startDateXIB.title = Fields.startDate.rawValue
        self.startDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.startDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.startDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.startDateXIB.optionXIB.btnDownClick.tag = self.dueDateTag
        self.startDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.startDateXIB.optionXIB.btnDownClick
            //let selectedDate = self.startDateXIB.optionXIB.lblText.text?.transformToDate(dateFormat: self.ddMMyyyyStr)
            let selectedDate = self.selectedStartDate
            self.openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate, minDate: nil, maxDate: nil) { [weak self] date in
                guard let self else { return }
                self.selectedStartDate = date
            }
        }
        
        //self.leadXIB.tfData.shouldResignOnTouchOutsideMode = .enabled
        self.leadXIB.title = Fields.lead.rawValue
        self.leadXIB.tfData.backgroundColor = bgColor
        self.leadXIB.tfData.placeholder = Fields.lead.selectStr
        self.leadXIB.tfData.delegate = self
        self.leadXIB.tfData.textChanged { [weak self] in
            guard let self else { return }
            self.reloadFilteredLeadUserItemArray()
        }
        
        //self.assistantXIB.tfData.shouldResignOnTouchOutsideMode = .enabled
        self.assistantXIB.title = Fields.assistant.rawValue
        self.assistantXIB.tfData.backgroundColor = bgColor
        self.assistantXIB.tfData.placeholder = Fields.assistant.selectStr
        self.assistantXIB.tfData.delegate = self
        self.assistantXIB.tfData.textChanged { [weak self] in
            guard let self else { return }
            self.reloadFilteredAssistantUserItemArray()
        }
        
        self.repeatsXIB.title = Fields.repeats.rawValue
        self.repeatsXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.repeatsXIB.optionXIB.lblText.text = Fields.repeats.selectStr
        self.repeatsMainViewHeight.constant = CGFloat.zero
        self.repeatsMainView.frame.size.height = self.repeatsMainViewHeight.constant
        self.repeatsMainView.isHidden = true
        
        if self.isForCreateNew {
            self.printPDFReportBtn.isHidden = true
            self.saveContinueBtn.isHidden = false
        }else {
            self.printPDFReportBtn.isHidden = false
            self.saveContinueBtn.isHidden = true
        }
        
        self.setUpSearchOverlayImage()
        
        self.setupTypeMenu()
        self.setupSubTypeMenu()
        self.setupCategoryMenu()
        self.setupRepeatsMenu()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableMainViewHeight.constant = CGFloat.zero
        self.tableMainView.frame.size.width = self.tableMainViewHeight.constant
        self.tableMainView.isHidden = true
        
        self.reloadViews()
    }
    
    func reloadViews() {
        guard let model = self.siteCheckModel else { return }
        if let type = model.type, let lov = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.lovValue == type }) {
            self.selectedTypeId = lov.id
            self.typeXIB.optionXIB.lblText.text = lov.lovValue
            self.setupTypeMenu()
            self.get_lovSITE_CHECK_SUB_TYPE(filter1: type, fromReload: true)
        }
        if let startDate = model.startDate, let date = startDate.transformToDate(dateFormat: kResponseDateFormat) {
            self.selectedStartDate = date
        }
        if let dueDate = model.dueDate, let date = dueDate.transformToDate(dateFormat: kResponseDateFormat) {
            self.selectedDueDate = date
        }
        if let leadUserID = model.leadUserID, let leadUser = self.userBySiteIdItemArray.first(where: { $0.id == Int(leadUserID) }) {
            self.selectedLeadUser = leadUser
        }
        if let assistantUserID = model.assistantUserID, let assistantUser = self.userBySiteIdItemArray.first(where: { $0.id == Int(assistantUserID) }) {
            self.selectedAssistantUser = assistantUser
        }
        if let repeatFrequency = model.repeatFrequency {
            self.selectedRepeatFreq = repeatFrequency
        }
        self.reloadTableMainView()
    }
    
    func adjustCategoryMainView() {
        var shouldDisplay: Bool = true
        
        var type: String?
        if let selectedTypeId {
            type = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue
        }
        
        if type == "Assessment" {
            shouldDisplay = false
        }else if type == "Audit" {
            shouldDisplay = false
        }
        
        self.categoryXIB.isHidden = !shouldDisplay
        self.categoryXIBBottomToSubTypeXIB.constant = self.categoryXIB.isHidden ? 0 : 86
        self.categoryXIB.frame.origin.y = self.subTypeXIB.frame.origin.y
    }
    
    func adjustRepeatsMainView() {
        var shouldDisplay: Bool = false
        
        var type: String?
        var subType: String?
        
        if let selectedTypeId {
            type = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue
            if let type, let SITE_CHECK_SUB_TYPE_ItemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[type], let selectedSubTypeId {
                subType = SITE_CHECK_SUB_TYPE_ItemArray.first(where: { $0.id == selectedSubTypeId })?.lovValue
            }
        }
        
        if type == "Audit" {
            shouldDisplay = true
        }else if type == "Survey" && subType == "Water" {
            shouldDisplay = true
        }else if type == "Inspection" {
            shouldDisplay = true
        }
        
        self.repeatsMainView.isHidden = !shouldDisplay
        self.repeatsMainViewHeight.constant = self.repeatsMainView.isHidden ? 0 : 86
        self.repeatsMainView.frame.size.height = self.repeatsMainViewHeight.constant
    }
    
    func setupTypeMenu() {
        let view: OptionBtnWithTitleXIB = self.typeXIB
        let defaultStr = Fields.type.rawValue
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedTypeId = item?.id
            view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
            self.setupTypeMenu()
            if let value = item?.lovValue {
                self.get_lovSITE_CHECK_SUB_TYPE(filter1: value)
            }
            self.reloadSubTypeMenu()
            self.reloadCategoryMenu()
            self.adjustCategoryMainView()
            self.adjustRepeatsMainView()
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
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubTypeMenu() {
        self.subTypeXIB.optionXIB.lblText.text = Fields.subType.selectStr
        self.selectedSubTypeId = nil
        self.setupSubTypeMenu()
    }
    
    func setupSubTypeMenu() {
        let view: OptionBtnWithTitleXIB = self.subTypeXIB
        let defaultStr = Fields.subType.selectStr
        var actions: [UIMenuElement] = []
        
        if let selectedTypeId,
           let selectedType = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue,
           let itemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[selectedType] {
            view.optionXIB.dummyTF.backgroundColor = self.fieldBGColor
            
            let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
                guard let self else { return }
                self.selectedSubTypeId = item?.id
                view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
                self.setupSubTypeMenu()
                if let value = item?.lovValue {
                    self.get_lovSITE_CHECK_CATEGORY(filter1: value)
                }
                self.reloadCategoryMenu()
                self.adjustCategoryMainView()
                self.adjustRepeatsMainView()
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
            view.optionXIB.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadCategoryMenu() {
        self.categoryXIB.optionXIB.lblText.text = Fields.category.selectStr
        self.selectedCategoryId = nil
        self.setupCategoryMenu()
    }
    
    func setupCategoryMenu() {
        let view: OptionBtnWithTitleXIB = self.categoryXIB
        let defaultStr = Fields.category.selectStr
        var actions: [UIMenuElement] = []
        
        if let selectedTypeId,
           let selectedType = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue,
           let subTypeItemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[selectedType],
           let selectedSubTypeId,
           let selectedSubType = subTypeItemArray.first(where: { $0.id == selectedSubTypeId })?.lovValue,
           let itemArray = self.SITE_CHECK_CATEGORY_ItemDict[selectedSubType] {
            view.optionXIB.dummyTF.backgroundColor = self.fieldBGColor
            
            let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
                guard let self else { return }
                self.selectedCategoryId = item?.id
                view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
                self.setupCategoryMenu()
                self.adjustCategoryMainView()
                self.adjustRepeatsMainView()
            }
            
            let titleAction = UIAction(title: defaultStr, state: self.selectedCategoryId == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for item in itemArray {
                let action = UIAction(title: item.lovValue ?? "", state: self.selectedCategoryId == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
        }else {
            view.optionXIB.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupRepeatsMenu() {
        let view: OptionBtnWithTitleXIB = self.repeatsXIB
        let defaultStr = SiteCheckModel.RepeatFrequency.default.rawValue
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteCheckModel.RepeatFrequency?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedRepeatFreq = item
            self.setupRepeatsMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedRepeatFreq == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        var itemArray = SiteCheckModel.RepeatFrequency.allCases
        itemArray.removeAll { $0 == .default }
        for item in itemArray {
            let action = UIAction(title: item.rawValue, state: self.selectedRepeatFreq == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadTableMainView() {
        var shouldHide: Bool = true
        self.tableItemArray = []
        
        if !self.isForCreateNew {
            let type = self.siteCheckModel?.type
            let subType = self.siteCheckModel?.subType
            let category = self.siteCheckModel?.category
            
            if type == "Inspection" {
                shouldHide = false
                self.tableItemArray = self.InspectionItemArray
                if let index = self.tableItemArray.firstIndex(where: { $0.field == .faultsIdentified }) {
                    self.tableItemArray[index].status = .open
                }
                if let index = self.tableItemArray.firstIndex(where: { $0.field == .certificate }) {
                    if self.inspectionItemArray.first?.certificateId != nil {
                        self.tableItemArray[index].status = .closed
                    }else {
                        self.tableItemArray[index].status = .open
                    }
                }
            }else if type == "Assessment" {
                shouldHide = false
                self.tableItemArray = self.AssessmentItemArray
            }else if type == "Audit" && subType == "Monthly Audit" {
                shouldHide = false
                self.tableItemArray = self.MonthlyAuditItemArray
            }else if type == "Audit" && subType == "Annual Winter Audit" {
                shouldHide = false
                self.tableItemArray = self.AnnualWinterAuditAuditItemArray
            }else if type == "Audit" {
                shouldHide = false
                self.tableItemArray = self.AuditItemArray
            }else if type == "Survey" && subType == "Water" && category == "Water Temperature Monitoring" {
                shouldHide = false
                self.tableItemArray = self.SurveyWaterOutletTemperatureItemArray
                if let index = self.tableItemArray.firstIndex(where: { $0.field == .waterOutletTemperatureTests }) {
                    self.tableItemArray[index].status = .inProgress
                }
            }else if type == "Survey" && subType == "Water" && category == "Water Risk Assessment" {
                shouldHide = false
                self.tableItemArray = self.SurveyWaterDomesticRAItemArray
            }else if type == "Survey" && subType == "Asbestos" {
                shouldHide = false
                self.tableItemArray = self.SurveyAsbestosItemArray
            }else if type == "Survey" && subType == "Water" && category == "Tank" {
                shouldHide = false
                self.tableItemArray = self.SurveyWaterTankItemArray
            }
        }
        if self.isForCreateNew || shouldHide || self.tableItemArray.isEmpty {
            self.tableMainViewHeight.constant = CGFloat.zero
            self.tableMainView.frame.size.height = self.tableMainViewHeight.constant
            self.tableMainView.isHidden = true
        }else {
            self.tableMainViewHeight.constant = 10+1+20+70+10
            self.tableMainView.frame.size.height = self.tableMainViewHeight.constant
            self.tableMainView.isHidden = false
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableMainViewHeight.constant = 10+1+20+self.tableView.contentSize.height+10
            self.tableMainView.frame.size.height = self.tableMainViewHeight.constant
        }
    }
    
}

//MARK: - load data
extension AddSiteCheckVC {
    
    typealias SuccessCompletion = (() -> Void)
    
    func loadData() {
        if !self.isForCreateNew {
            self.getAllUserByUserTypeExternal()
        }
    }
    
    func get_lovSITE_CHECK_SUB_TYPE(filter1: String, fromReload: Bool = false) {
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
                    if fromReload {
                        if let model = self.siteCheckModel, let subType = model.subType, let lov = array.first(where: { $0.lovValue == subType }) {
                            self.selectedSubTypeId = lov.id
                            self.subTypeXIB.optionXIB.lblText.text = lov.lovValue
                            self.setupSubTypeMenu()
                            self.get_lovSITE_CHECK_CATEGORY(filter1: subType, fromReload: true)
                        }else {
                            self.reloadSubTypeMenu()
                            self.adjustCategoryMainView()
                            self.adjustRepeatsMainView()
                        }
                    }else {
                        self.setupSubTypeMenu()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func get_lovSITE_CHECK_CATEGORY(filter1: String, fromReload: Bool = false) {
        let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_CATEGORY, filter1: filter1)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    self.SITE_CHECK_CATEGORY_ItemDict[filter1] = array
                    if fromReload {
                        if let model = self.siteCheckModel, let category = model.category, let lov = array.first(where: { $0.lovValue == category }) {
                            self.categoryXIB.optionXIB.lblText.text = lov.lovValue
                            self.selectedCategoryId = lov.id
                            self.setupCategoryMenu()
                        }else {
                            self.reloadCategoryMenu()
                        }
                        self.adjustCategoryMainView()
                        self.adjustRepeatsMainView()
                        //self.reloadTableMainView()
                    }else {
                        self.setupCategoryMenu()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func saveSiteCheck(model: SiteCheckModel) {
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.post_siteCheckBy(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.checkId != nil {
                        self.saveUserCalendarOneByOne(model: single)
                    }else {
                        self.hideLoadingAndShowError(message: self.failedToAddSiteCheckStr)
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError(message: self.failedToAddSiteCheckStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: self.failedToAddSiteCheckStr)
            }
        }
    }
    
    func saveUserCalendarOneByOne(model: SiteCheckModel) {
        var userIds: [Int] = []
        if let leadUserID = model.leadUserID, let id = Int(leadUserID) {
            userIds.append(id)
        }
        if let assistantUserID = model.assistantUserID, let id = Int(assistantUserID) {
            userIds.append(id)
        }
        if let id = UserConstants.shared.currentUserID {
            userIds.append(id)
        }
        
        func startNext(index: Int) {
            if userIds.count > index {
                let reqDateStr = model.dueDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
                let eventType = "\(model.type ?? "") \(model.subType ?? "")"
                
                let calendarModel = CalendarEvent()
                calendarModel.siteId = UserConstants.shared.selectedSiteID
                calendarModel.startDate = reqDateStr
                calendarModel.endDate = reqDateStr
                calendarModel.shortText = "\(eventType) - \(model.category ?? "")"
                calendarModel.eventType = eventType
                calendarModel.userId = "\(userIds[index])"
                calendarModel.includeCompanyUsers = false
                
                self.saveUserCalendar(model: calendarModel) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.loadingSCLAlertView.hideView()
                SCLAlertView.showSuccessAlert(title: "", message: self.siteCheckHasBeenAddedSuccessStr, doneButtonTitle: "OK") { [weak self] in
                    guard let self else { return }
                    self.delegate?.addSiteCheckDidSaveContinue()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        startNext(index: 0)
    }
    
    func saveUserCalendar(model: CalendarEvent, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.putUserCalendarAPI(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CalendarEvent>, Error>) in
            guard self != nil else { return }
            successCompletion()
        }
    }
    
}

//MARK: - DatePickerVCDelegate
extension AddSiteCheckVC: DatePickerVCDelegate {
    
    func openDatePickerVC(sender: UIView, tag: Int, selectedDate: Date? = nil, minDate: Date? = nil, maxDate: Date? = nil, dateChangeHandler: ((Date?) -> Void)? = nil) {
        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        if let dateChangeHandler {
            vc.dateChangeHandler = dateChangeHandler
        }else {
            vc.delegate = self
        }
        vc.selectedDate = selectedDate
        vc.minimumDate = minDate
        vc.maximumDate = maxDate
        vc.preferredContentSize = CGSize(width: 10+320+10, height: 10+324+40+10)
        vc.modalPresentationStyle = .popover
        vc.presentationController?.delegate = self
        vc.popoverPresentationController?.permittedArrowDirections = .any
        //vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        vc.popoverPresentationController?.sourceView = sender
        vc.popoverPresentationController?.sourceRect = sender.bounds
        vc.view.tag = tag
        self.present(vc, animated: true)
    }
    
    func datePickerVCDidSelectDate(vc: UIViewController, date: Date?) {
        
    }
    
}

//MARK: - UIPopoverPresentationControllerDelegate
extension AddSiteCheckVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
}

extension AddSiteCheckVC {
    
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
        self.searchTableView?.type = switch textField {
        case self.leadXIB.tfData:
                .leadUser
        case self.assistantXIB.tfData:
                .assistantUser
        default:
                .leadUser
        }
        
        // Safely find the cell containing the text field
        let textFieldFrame = textField.convert(textField.bounds, to: view)
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - topSafeArea - navigationHeight - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        let desiredTableViewHeight: CGFloat = switch textField {
        case self.leadXIB.tfData:
            CGFloat(min(filterLeadUserItemArray.count, 3)*75)
        case self.assistantXIB.tfData:
            CGFloat(min(filterAssistantUserItemArray.count, 3)*75)
        default:
            CGFloat.zero
        }
        
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
        
        let itemArray: [User] = switch textField {
        case self.leadXIB.tfData:
            self.filterLeadUserItemArray
        case self.assistantXIB.tfData:
            self.filterAssistantUserItemArray
        default:
            []
        }
        self.searchTableView?.isHidden = itemArray.isEmpty
        switch textField {
        case self.leadXIB.tfData:
            self.searchTableView?.leadUserItemArray = self.filterLeadUserItemArray
        case self.assistantXIB.tfData:
            self.searchTableView?.assistantUserItemArray = self.filterAssistantUserItemArray
        default:
            self.searchTableView?.leadUserItemArray = []
        }
        self.searchTableView?.showTableView(with: itemArray)
        view.addSubview(self.searchTableView!)
        
        self.searchTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? User {
                    switch textField {
                    case self.leadXIB.tfData:
                        self.selectedLeadUser = item
                    case self.assistantXIB.tfData:
                        self.selectedAssistantUser = item
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func reloadFilteredLeadUserItemArray() {
        let textField: UITextField = self.leadXIB.tfData
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filterLeadUserItemArray = self.userBySiteIdItemArray.filter { user in
                return (text.isEmpty || getUserDisplayStr(user)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
    func reloadFilteredAssistantUserItemArray() {
        let textField: UITextField = self.assistantXIB.tfData
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filterAssistantUserItemArray = self.userBySiteIdItemArray.filter { user in
                return (text.isEmpty || getUserDisplayStr(user)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension AddSiteCheckVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.leadXIB.tfData:
            self.reloadFilteredLeadUserItemArray()
        case self.assistantXIB.tfData:
            self.reloadFilteredAssistantUserItemArray()
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.leadXIB.tfData:
            if textField.text?.trimmingSpacesAndLines().isEmpty ?? false {
                self.selectedLeadUser = nil
            }
            textField.text = getUserDisplayStr(self.selectedLeadUser) ?? ""
            self.hideSearchTableView()
        case self.assistantXIB.tfData:
            if textField.text?.trimmingSpacesAndLines().isEmpty ?? false {
                self.selectedAssistantUser = nil
            }
            textField.text = getUserDisplayStr(self.selectedAssistantUser) ?? ""
            self.hideSearchTableView()
        default:
            break
        }
    }
}

extension AddSiteCheckVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleBadgeTableCell", for: indexPath) as! TitleBadgeTableCell
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        if self.tableItemArray.count > indexPath.row {
            let item = self.tableItemArray[indexPath.row]
            cell.titleLbl.font = UIFont(name: .MontserratMedium, size: 17)
            cell.titleLbl.text = item.field.rawValue
            cell.setBadgeData(
                text: item.status?.rawValue,
                font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize+1),
                textColor: item.status?.textColor,
                bgColor: item.status?.bgColor
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableItemArray.count > indexPath.row {
            let item = self.tableItemArray[indexPath.row]
            switch item.field {
            case .faultsIdentified:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "FaultsIdentifiedVC") as! FaultsIdentifiedVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.inspectionFaultItemArray
                vc.assetsItemArray = self.assetsItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .certificate:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "InspectionCertificateVC") as! InspectionCertificateVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.inspectionItemArray
                vc.externalUserTypeUserItemArray = self.externalUserTypeUserItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .questions:
                let type = self.siteCheckModel?.type
                let subType = self.siteCheckModel?.subType
                var questionsCategory: AssessmentQuestionsCategoryEnum?
                if type == "Assessment" {
                    let vc = siteCheckSB.instantiateViewController(withIdentifier: "AssessmentQuestionsVC") as! AssessmentQuestionsVC
                    vc.addSiteCheckVC = self
                    vc.siteCheckModel = self.siteCheckModel
                    vc.questionItemArray = self.assessmentQuestionItemArray
                    vc.responseItemArray = self.assessmentResponseItemArray
                    vc.siteLayoutItemArray = self.siteLayoutItemArray
                    vc.assetsItemArray = self.assetsItemArray
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }else if type == "Audit" && subType == "Monthly Audit" {
                    let vc = siteCheckSB.instantiateViewController(withIdentifier: "MonthlyAuditQuestionsVC") as! MonthlyAuditQuestionsVC
                    vc.addSiteCheckVC = self
                    vc.siteCheckModel = self.siteCheckModel
                    vc.questionItemArray = self.assessmentQuestionItemArray
                    vc.responseItemArray = self.assessmentResponseItemArray
                    vc.assetsItemArray = self.assetsItemArray
                    vc.SITE_CHECK_AUDIT_HEADER_ItemArray = self.asbestosLOVDict[.SITE_CHECK_AUDIT_HEADER] ?? []
                    vc.questionCat = "monthly-inspection"
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }else if type == "Audit" && subType == "Annual Winter Audit" {
                    let vc = siteCheckSB.instantiateViewController(withIdentifier: "MonthlyAuditQuestionsVC") as! MonthlyAuditQuestionsVC
                    vc.addSiteCheckVC = self
                    vc.siteCheckModel = self.siteCheckModel
                    vc.questionItemArray = self.assessmentQuestionItemArray
                    vc.responseItemArray = self.assessmentResponseItemArray
                    vc.assetsItemArray = self.assetsItemArray
                    vc.SITE_CHECK_AUDIT_HEADER_ItemArray = self.asbestosLOVDict[.SITE_CHECK_AUDIT_HEADER] ?? []
                    vc.questionCat = "annual-winter-audit"
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }
                break
            case .observations:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "FaultsIdentifiedVC") as! FaultsIdentifiedVC
                vc.isForAuditObservations = true
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.auditItemArray
                vc.assetsItemArray = self.assetsItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .waterOutletTemperatureTests:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterOutletTempVC") as! WaterOutletTempVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.waterOutletTempItemArray = self.waterOutletTempItemArray
                vc.asbestosLOVDict = self.asbestosLOVDict
                vc.siteLayoutItemArray = self.siteLayoutItemArray
                vc.assetsItemArray = self.assetsItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .riskFactors:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterDomecsticRAVC") as! WaterDomecsticRAVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.raSurveyRiskFactorsItemArray = self.raSurveyRiskFactorsItemArray
                vc.domesticRASurveyItemArray = self.domesticRASurveyItemArray
                vc.SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray = self.asbestosLOVDict[.SITE_CHECK_DOMESTIC_RA_SCORES] ?? []
                vc.assetsItemArray = self.assetsItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .asbestosSurvey:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "AsbestosSurveyVC") as! AsbestosSurveyVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.asbestosSurveyItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .asbestosSamples:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "AsbestosSampleVC") as! AsbestosSampleVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.asbestosSampleItemArray
                vc.asbestosLOVDict = self.asbestosLOVDict
                vc.siteLayoutItemArray = self.siteLayoutItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            case .tankDetails:
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterTankDetailsVC") as! WaterTankDetailsVC
                vc.addSiteCheckVC = self
                vc.siteCheckModel = self.siteCheckModel
                vc.itemArray = self.waterTankItemArray
                vc.assetsItemArray = self.assetsItemArray
                vc.siteLayoutItemArray = self.siteLayoutItemArray
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - Common API
extension AddSiteCheckVC {
    
    // loading start
    func getAllUserByUserTypeExternal() {
        self.loadingStatus = .loading
        
        let apiService = ApiService.getAllUserByUserType(userType: "External")
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if let array = single.users {
                        self.externalUserTypeUserItemArray = array
                        self.getSiteCheckByCheckId()
                    }else {
                        self.loadingStatus = .failed
                    }
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
    
    func getSiteCheckByCheckId() {
        guard let checkId = self.siteCheckModel?.checkId else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.get_siteCheckBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.checkId != nil {
                        self.siteCheckModel = single
                        self.getSiteCheckFileSASToken()
                    }else {
                        self.loadingStatus = .failed
                    }
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
    
    func getSiteCheckFileSASToken() {
        let apiService = ApiService.getSiteCheckFileSASToken
        APIClient.requestString(apiService) { [weak self] (result: Result<String, Error>) in
            guard let self else { return }
            switch result {
            case .success(let success):
                UserConstants.shared.sasToken = success
                self.getSiteAssetsBySiteId()
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getSiteAssetsBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.siteAssetsAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if let array = single.assets {
                        self.assetsItemArray = array
                        
                        let type = self.siteCheckModel?.type
                        let subType = self.siteCheckModel?.subType
                        //let category = self.siteCheckModel?.category
                        if type == "Inspection" {
                            self.getSiteCheckInspectionFaultBySiteId()
                        }else if type == "Assessment" {
                            self.getSiteLayoutBySiteId()
                        }else if type == "Audit" && subType == "Monthly Audit" {
                            self.getSiteLayoutBySiteId()
                        }else if type == "Audit" && subType == "Annual Winter Audit" {
                            self.getSiteLayoutBySiteId()
                        }else if type == "Audit" {
                            self.getSiteCheckAuditByCheckId()
                        }else if type == "Survey" {
                            self.getSiteLayoutBySiteId()
                        }else {
                            self.loadingStatus = .default
                        }
                    }else {
                        self.loadingStatus = .failed
                    }
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
    
    func getSiteLayoutBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.siteLayoutAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteLayoutModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.siteLayoutItemArray = array
                    let type = self.siteCheckModel?.type
                    let subType = self.siteCheckModel?.subType
                    let category = self.siteCheckModel?.category
                    if type == "Assessment" {
                        self.getSiteCheckAssessmentQuestionsAssessmentFireRisk()
                    }else if type == "Audit" && subType == "Monthly Audit" {
                        self.get_lov_SITE_CHECK_AUDIT_HEADER()
                    }else if type == "Audit" && subType == "Annual Winter Audit" {
                        self.get_lov_SITE_CHECK_AUDIT_HEADER()
                    }else if type == "Survey" && subType == "Water" && category == "Water Temperature Monitoring" {
                        self.getSiteCheckWaterOutletTempByCheckId()
                    }else if type == "Survey" && subType == "Water" && category == "Water Risk Assessment" {
                        self.getSiteCheckRASurveyRiskFactors()
                    }else if type == "Survey" && subType == "Asbestos" {
                        self.getSiteCheckAsbestosSurveyByCheckId()
                    }else if type == "Survey" && subType == "Water" && category == "Tank" {
                        self.getSiteCheckTank()
                    }else {
                        self.loadingStatus = .default
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func saveSiteCheckByCheckId(assessmentQuestionResponseVC: AssessmentQuestionResponseVC? = nil, monthlyAuditQuestionResponseVC: MonthlyAuditQuestionResponseVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc = assessmentQuestionResponseVC {
                vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
            }else if let vc1 = monthlyAuditQuestionResponseVC {
                vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let itemArray = self.assessmentResponseItemArray
        let model = SiteCheckModel()
        model.riskScoreGreen = itemArray.filter { [Int](1...4).contains($0.totalRiskScore ?? 0) }.count
        model.riskScoreYellow = itemArray.filter { [Int](5...9).contains($0.totalRiskScore ?? 0) }.count
        model.riskScoreAmber = itemArray.filter { [Int](10...16).contains($0.totalRiskScore ?? 0) }.count
        model.riskScoreRed = itemArray.filter { [Int](17...25).contains($0.totalRiskScore ?? 0) }.count
        
        let apiService = ApiService.put_siteCheckBy(checkId: checkId, model: model)
        APIClient.requestResponse(apiService) { [weak self] isSucess in
            guard let self else { return }
            if isSucess {
                let type = self.siteCheckModel?.type
                let subType = self.siteCheckModel?.subType
                let category = self.siteCheckModel?.category
                if type == "Assessment" {
                    if let vc = assessmentQuestionResponseVC {
                        vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
                    }else {
                        self.loadingStatus = .default
                    }
                }else if type == "Survey" && subType == "Water" && category == "Water Risk Assessment" {
                    self.loadingStatus = .default
                }else if type == "Audit" && subType == "Monthly Audit" {
                    if let vc1 = monthlyAuditQuestionResponseVC {
                        vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
                    }else {
                        self.loadingStatus = .default
                    }
                }else if type == "Audit" && subType == "Annual Winter Audit" {
                    if let vc1 = monthlyAuditQuestionResponseVC {
                        vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
                    }else {
                        self.loadingStatus = .default
                    }
                }else {
                    self.loadingStatus = .default
                }
            }else {
                if let vc = assessmentQuestionResponseVC {
                    vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
                }else if let vc1 = monthlyAuditQuestionResponseVC {
                    vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: self.assessmentQuestionItemArray, responseItemArray: self.assessmentResponseItemArray)
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

//MARK: - Inspection
extension AddSiteCheckVC {
    
    func getSiteCheckInspectionFaultBySiteId(vc: FaultsIdentifiedVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckInspectionFaultBySiteId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckInspectionFaultBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<InspectionFaultModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckInspectionFaultBySiteId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.inspectionFaultItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckInspectionFaultBySiteId(array: array)
                    }else {
                        self.getSiteCheckInspectionBySiteId()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckInspectionFaultBySiteId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getSiteCheckInspectionBySiteId(vc: InspectionCertificateVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckInspectionBySiteId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckInspectionBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckInspectionModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckInspectionBySiteId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.inspectionItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckInspectionBySiteId(array: array)
                    }else {
                        self.loadingStatus = .default
                        self.reloadTableMainView()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckInspectionBySiteId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

//MARK: - Assessment
extension AddSiteCheckVC {
    
    func getSiteCheckAssessmentQuestionsAssessmentFireRisk(vc: AssessmentQuestionResponseVC? = nil, vc1: MonthlyAuditQuestionResponseVC? = nil) {
        self.getSiteCheckAssessmentQuestionsFromCategory(category: .fireRiskAssessment) { [weak self] isSuccess, questions in
            guard let self else { return }
            if isSuccess {
                self.assessmentQuestionItemArray = questions
                self.getSiteCheckAssessmentResponseByCheckId(vc: vc, vc1: vc1)
            }else {
                if let vc {
                    vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                }else if let vc1 {
                    vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getSiteCheckAssessmentQuestionsFromCategory(category: AssessmentQuestionsCategoryEnum, completion: @escaping (_ isSuccess: Bool, _ questions: [SiteCheckAssessmentQuestions]) -> Void) {
        let apiService = ApiService.getSiteCheckAssessmentQuestions(category: category)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAssessmentQuestions>, Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    completion(false, [])
                    break
                case .array(let array):
                    completion(true, array)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                completion(false, [])
            }
        }
    }
    
    func getSiteCheckAssessmentResponseByCheckId(vc: AssessmentQuestionResponseVC? = nil, vc1: MonthlyAuditQuestionResponseVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
            }else if let vc1 {
                vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckAssessmentResponseBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAssessmentResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                    }else if let vc1 {
                        vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.assessmentResponseItemArray = array
                    self.saveSiteCheckByCheckId(assessmentQuestionResponseVC: vc, monthlyAuditQuestionResponseVC: vc1)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                }else if let vc1 {
                    vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

//MARK: - Audit
extension AddSiteCheckVC {
    
    func getSiteCheckAuditByCheckId(vc: FaultsIdentifiedVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckAuditByCheckId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckAuditBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<InspectionFaultModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckAuditByCheckId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.auditItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckAuditByCheckId(array: array)
                    }else {
                        self.loadingStatus = .default
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckAuditByCheckId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

//MARK: - Survey - Asbestos
extension AddSiteCheckVC {
    
    func getSiteCheckAsbestosSurveyByCheckId(vc: AsbestosSurveyVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckAsbestosSurveyByCheckId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckAsbestosSurveyBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAsbestosSurvey>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckAsbestosSurveyByCheckId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.asbestosSurveyItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckAsbestosSurveyByCheckId(array: array)
                    }else {
                        self.getSiteCheckAsbestosSampleByCheckId()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckAsbestosSurveyByCheckId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getSiteCheckAsbestosSampleByCheckId(vc: AsbestosSampleDetailVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckAsbestosSampleBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAsbestosSample>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.asbestosSampleItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: array)
                    }else {
                        self.getSurveyAsbestosLOVs()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getSurveyAsbestosLOVs() {
        let lovItemArray: [LOVTypeEnum] = [
            .ASBESTOS_MATERIAL_ASSESSMENT_PRODUCT_TYPE,
            .ASBESTOS_MATERIAL_DAMAGE,
            .ASBESTOS_MATERIAL_SURFACE,
            .ASBESTOS_MATERIAL_ASBESTOS_TYPE,
            .ASBESTOS_PA_MAIN_ACTIVITY,
            .ASBESTOS_PA_SECONDARY_ACTIVITY,
            .ASBESTOS_PA_LOCATION,
            .ASBESTOS_PA_ACCESSIBILITY,
            .ASBESTOS_PA_EXTENT_AMOUNT,
            .ASBESTOS_PA_FREQUENCY_OF_USE,
            .ASBESTOS_PA_AVERAGE_USE,
            .ASBESTOS_PA_MAINTENANCE_ACTIVITY_TYPE,
            .ASBESTOS_PA_MAINTENANCE_ACTIVITY_FREQ,
        ]
        
        func startNext(index: Int) {
            if lovItemArray.count > index {
                self.getLOVBy(lovItemArray[index]) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.loadingStatus = .default
            }
        }
        
        startNext(index: 0)
    }
    
    func getLOVBy(_ lovType: LOVTypeEnum, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.lovAPI(lovType: lovType)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.asbestosLOVDict[lovType] = array
                    successCompletion()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
}

//MARK: - Survey - Water - Outlet Temperature
extension AddSiteCheckVC {
    
    func getSiteCheckWaterOutletTempByCheckId(vc: WaterOutletTempVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckWaterOutletTempByCheckId(array: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckWaterOutletTempBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckWaterOutletTemp>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckWaterOutletTempByCheckId(array: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.waterOutletTempItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckWaterOutletTempByCheckId(array: self.waterOutletTempItemArray)
                    }else {
                        self.getWaterOutletTempLOVs()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckWaterOutletTempByCheckId(array: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getWaterOutletTempLOVs() {
        let lovItemArray: [LOVTypeEnum] = [
            .SITE_CHECK_SURVEY_OUTLET_TYPE,
            .SITE_CHECK_SURVEY_TEMPRATURE,
            .SITE_CHECK_SURVEY_NORM_RUN_TIME,
        ]
        
        func startNext(index: Int) {
            if lovItemArray.count > index {
                self.getLOVBy(lovItemArray[index]) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.loadingStatus = .default
            }
        }
        
        startNext(index: 0)
    }
    
}

//MARK: - Survey - Water - Domestic RA
extension AddSiteCheckVC {
    
    func getSiteCheckRASurveyRiskFactors(vc: WaterDomecsticRAResponseVC? = nil) {
        let apiService = ApiService.getSiteCheckRASurveyRiskFactors
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckRASurveyRiskFactors>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [], domesticRASurveyItemArray: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.raSurveyRiskFactorsItemArray = array
                    self.getSiteCheckDomesticRASurveyByCheckId(vc: vc)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [], domesticRASurveyItemArray: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getSiteCheckDomesticRASurveyByCheckId(vc: WaterDomecsticRAResponseVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [], domesticRASurveyItemArray: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckDomesticRASurveyBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAssessmentResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [], domesticRASurveyItemArray: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.domesticRASurveyItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: self.raSurveyRiskFactorsItemArray, domesticRASurveyItemArray: self.domesticRASurveyItemArray)
                    }else {
                        self.get_lov_SITE_CHECK_DOMESTIC_RA_SCORES()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: self.raSurveyRiskFactorsItemArray, domesticRASurveyItemArray: self.domesticRASurveyItemArray)
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func get_lov_SITE_CHECK_DOMESTIC_RA_SCORES() {
        let lovType: LOVTypeEnum = .SITE_CHECK_DOMESTIC_RA_SCORES
        self.getLOVBy(lovType) { [weak self] in
            guard let self else { return }
            self.saveSiteCheckByCheckId()
        }
    }
    
}

//MARK: - Survey - Water - Tank
extension AddSiteCheckVC {
    
    func getSiteCheckTank(vc: WaterTankDetailsVC? = nil) {
        guard let checkId = self.siteCheckModel?.checkId else {
            if let vc {
                vc.reloadAfterGetSiteCheckTankByCheckId(itemArray: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        
        let apiService = ApiService.getSiteCheckTankBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckWaterTank>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if let vc {
                        vc.reloadAfterGetSiteCheckTankByCheckId(itemArray: [])
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.waterTankItemArray = array
                    if let vc {
                        vc.reloadAfterGetSiteCheckTankByCheckId(itemArray: self.waterTankItemArray)
                    }else {
                        self.loadingStatus = .default
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if let vc {
                    vc.reloadAfterGetSiteCheckTankByCheckId(itemArray: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

//MARK: - Audit - Monthly Audit
extension AddSiteCheckVC {
    
    func get_lov_SITE_CHECK_AUDIT_HEADER(vc1: MonthlyAuditQuestionResponseVC? = nil) {
        let lovType: LOVTypeEnum = .SITE_CHECK_AUDIT_HEADER
        self.getLOVBy(lovType) { [weak self] in
            guard let self else { return }
            self.getSiteCheckAssessmentQuestionsForMonthlyInspection(vc1: vc1)
        }
    }
    
    func getSiteCheckAssessmentQuestionsForMonthlyInspection(vc1: MonthlyAuditQuestionResponseVC? = nil) {
        let type = self.siteCheckModel?.type
        let subType = self.siteCheckModel?.subType
        var questionsCategory: AssessmentQuestionsCategoryEnum?
        if type == "Audit" && subType == "Monthly Audit" {
            questionsCategory = .monthlyInspection
        }else if type == "Audit" && subType == "Annual Winter Audit" {
            questionsCategory = .annualWinterAudit
        }
        guard let questionsCategory else {
            if let vc1 {
                vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        self.getSiteCheckAssessmentQuestionsFromCategory(category: questionsCategory) { [weak self] isSuccess, questions in
            guard let self else { return }
            if isSuccess {
                self.assessmentQuestionItemArray = questions
                self.getSiteCheckAssessmentResponseByCheckId(vc1: vc1)
            }else {
                if let vc1 {
                    vc1.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [], responseItemArray: [])
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
}

protocol AddSiteCheckDelegate: AnyObject {
    func addSiteCheckDidSaveContinue()
}
