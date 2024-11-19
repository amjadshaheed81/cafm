//
//  CreateContractsVC.swift
//  cafm
//
//  Created by Savan Lakhani on 14/09/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

enum ContractQuotationType: String {
    case awarded = "Awarded"
    case rejected = "Rejected"
    case delete
}

class CreateContractsVC: UIViewController {

    @IBOutlet weak var budgetTxField: TextFiledDataXib!
    @IBOutlet weak var summaryTxField: TextFiledDataXib!
    
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
        
    @IBOutlet weak var addContracterQuoteMainView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var addNotesTextView: UITextView!
    
    @IBOutlet weak var frequencyOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var endDateOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var startDateOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var managerOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var companyOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var subCategoryOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var categoryOptionBtn: OptionBtnWithTitleXIB!
    @IBOutlet weak var scheduleVisitBtn: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var addAssetSpreedSheetView: SpreadsheetView!
    @IBOutlet weak var scheduleVisitSpreedSheetView: SpreadsheetView!
    @IBOutlet weak var contractSpreedSheetView: SpreadsheetView!
    @IBOutlet weak var showfolderSpreedSheetView: SpreadsheetView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var increaseLbl: UILabel!
    @IBOutlet weak var decreaseLbl: UILabel!
    
    @IBOutlet weak var addMoreBtn: UIButton!
    @IBOutlet weak var selectFolderBtn: UIButton!
    
    @IBOutlet weak var addAssetsMainView: UIView!
    
    @IBOutlet weak var folderCVHeight: NSLayoutConstraint!
    @IBOutlet weak var addAssetsMVHeight: NSLayoutConstraint!
    @IBOutlet weak var scheduleVisitBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var scheduleVisitTop: NSLayoutConstraint!
    @IBOutlet weak var assetMainViewTop: NSLayoutConstraint!
    @IBOutlet weak var selectFolderHeightCons: NSLayoutConstraint!
    @IBOutlet weak var showFolderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scheduleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contratDetailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewContractHeight: NSLayoutConstraint!
    @IBOutlet weak var addNewVisitHeight: NSLayoutConstraint!
    @IBOutlet weak var addContractorQuoteHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addNewVisitBtnTop: NSLayoutConstraint!
    
    @IBOutlet weak var addContracterQuoteTx2: TextFiledDataXib!
    @IBOutlet weak var addContracterQuoteTx1: TextFiledDataXib!
    
    @IBOutlet weak var addNewVisitBtn: UIButton!
    
    @IBOutlet weak var viewContractcCompanyDetailLbl: UILabel!
    @IBOutlet weak var viewContractStatusView: UIView!
    @IBOutlet weak var viewContractLbl: UILabel!
    @IBOutlet weak var viewContractTitle: UILabel!
    @IBOutlet weak var viewContractView: UIView!
    
    @IBOutlet weak var actionBtnSubView: UIView!
    @IBOutlet weak var terminateContractBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var terminateContractWidth: NSLayoutConstraint!
    @IBOutlet weak var actionBtnSubViewWidth: NSLayoutConstraint!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let kAssetsDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    var isForViewOnly = false
    var projectContractId: Int?
    
    var addAssetsTag = 10000

    // Date Picker Tag
    private let startDateTag = 1
    private let endDateTag = 2
    private let scheduleDateTag = 3
    
    private var parentFolderItemArray: [ParentFolder] = []
    private var assetsItemArray: [AssetDetailsResponse] = []
    
    var siteContractsCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var siteContractsSubCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var allCompanyResponseArray: [CompanyDetails] = []
    var managerRole: [User] = []
    var selectedAssetsItemArray: [[String: Int]] = []
    
    var assetDetailsResponse: [AssetDetailsResponse] = []
    var assetItemArray: [String] = []
    var filterItemArray: [String] = []
    var selectedAssetItemArrayIndex: [Int] = []
    var responseArrayOfStatus: [String] = []
    
    //request model
    let contractRequest = ContractDetailsModel()
    let folderRequest = FolderRequest()
    let assetRequest = AssetRequest()
    let visitRequest = ScheduleRequest()
    
    //response model
    var contractResponse = ContractDetailsModel()
    let visitResponse = ScheduleRequest()
    var projectContractResponse: ProjectContractResponse?
    var projectContractScheduleVisits: [ProjectContractScheduleVisit] = []
    var contractQuotationResponse: [ContractorQuote] = []
    var projectContractFolderResponseModel: [ProjectContractFolderModel] = [] {
        didSet {
            if self.projectContractFolderResponseModel.isEmpty {
                self.showFolderViewHeight.constant = 95.0
            }
        }
    }
    
    var isContracterSetup = UserDefaults.standard.userRole == .contractor
    
    var selectedImageFile: URL?

    //search asset name setup
    var tableView: CustomTableView?
    var overlayView: UIView!
    
    var numberOfAddAssetsArray: Int = 1
    
    var keyBoardHeight: CGFloat = 0.0
    
    var selectedStartDate: String?
    var selectedEndDate: String?
    var selectedScheduleDate: String?
    
    var addAssetsHeaderRow = ["Asset Name","Asset ID", "Location","Category","Actions"]
    var folderHeaderRow = ["Mandatory Folders", "Files"]
    var scheduleVisitHeaderRow = ["Visit Date", "Status", "Action"]
    var contractQuotationHeaderRow = ["Contractor", "Company", "Quote", "Quote Date", "Contractor Note", "Manager Note", "Status", "Action"]
    var uploadFolderHeaderRow = ["Mandatory Folders", "File (PDF < 1 MB)", "Files"]
    
    var dataRows: [[String]] = [["", "", "", "", ""]] {
        didSet {
            if self.dataRows.isEmpty {
                self.addAssetsMVHeight.constant = 180.00
            }else {
                self.self.addAssetsMVHeight.constant = CGFloat(110 + (self.dataRows.count * 70))
            }
        }
    }
    
    var managerNotesRows: [String] = []
    
    var removedAssets: [Int] = []

    enum Frequency: String {
        case frequency = "Select Frequency"
        case daily = "Daily"
        case weekly = "Weekly"
        case quarterly = "Quarterly"
        case yearly = "Yearly"
    }
    
    var selectFrequency: Frequency = .frequency

    private var isFieldsEditable: Bool {
        return true
    }
    
    var value: Int = 0 {
        didSet {
            if self.isForViewOnly && self.isContracterSetup {
                self.addContracterQuoteTx1.tfData.text = "\(value)"
            }else {
                self.budgetTxField.tfData.text = "\(value)"
            }
        }
    }
    
    var searchCategotyInd = 0 {
        didSet {
            if searchCategotyInd != 0 {
                self.searchSubCategotyInd = 0
                self.subCategoryOptionBtn.optionXIB.lblText.text = "Sub Category"
                self.setSubContractsCategoryXib()
                self.hideBottomViews(isHide: false)
                self.setScrollViewScrolling()
                self.addAssetSpreedSheetView.reloadData()
            }else {
                self.searchSubCategotyInd = 0
                self.subCategoryOptionBtn.optionXIB.lblText.text = "Sub Category"
                self.setSubContractsCategoryXib()
                self.hideBottomViews(isHide: true)
                self.setScrollViewScrolling()
            }
        }
    }

    var searchSubCategotyInd = 0
    var searchCompanyInd = 0
    var searchManagerInd = 0
    
    private var oldOffsetY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setScrollViewScrolling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setScrollViewScrolling()
    }
    
    func initialSetup() {
        self.title = "New Contract"
        
        let buttonsWithTitles: [(OptionBtnWithTitleXIB?, String)] = [
            (self.frequencyOptionBtn, "Frequency"),
            (self.endDateOptionBtn, "End Date"),
            (self.startDateOptionBtn, "Start Date"),
            (self.managerOptionBtn, "Manager"),
            (self.companyOptionBtn, "Company"),
            (self.subCategoryOptionBtn, "Sub Category"),
            (self.categoryOptionBtn, "Category"),
            (self.scheduleVisitBtn, "Schedule Visit")
        ]
        
        buttonsWithTitles.forEach { button, title in
            button?.titleLbl.text = title
            button?.titleLbl.font = UIFont(name: .MontserratMedium, size: 16)
            button?.optionXIB.lblText.font = UIFont(name: .MontserratSemiBold, size: 16)
        }
        
        self.summaryTxField.title = "Summary"
        self.budgetTxField.title = "Budget (GBP)"
        self.budgetTxField.tfData.keyboardType = .numberPad
        
        if !self.isForViewOnly {
            self.viewContractHeight.priority = .required
            self.viewContractView.frame.size.height = 0.0
            self.viewContractHeight.constant = 0.0
            self.viewContractView.clipsToBounds = true
            self.showFolderViewHeight.priority = .required
            self.showfolderSpreedSheetView.frame.size.height = 0.0
            self.showFolderViewHeight.constant = 0.0
            self.contratDetailViewHeight.constant = 0.0
            self.scheduleViewHeight.constant = 0.0
            self.addNewVisitHeight.constant = 0.0
        }
        
        self.addContracterQuoteMainView.isHidden = true
        self.addContractorQuoteHeight.constant = 0.0
        
        if UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers || !self.isForViewOnly || self.isContracterSetup {
            self.terminateContractWidth.constant = 0.0
            self.actionBtnSubViewWidth.constant = 94.0
        }
        
        if self.isContracterSetup {
            self.actionBtnSubViewWidth.constant = 94.0
            self.addContractorQuoteHeight.constant = 230.0
            self.scheduleVisitBtnHeight.constant = 0.0
            self.addNewVisitHeight.constant = 0.0
            self.addNewVisitBtnTop.constant = 0.0
            self.addNewVisitBtn.isHidden = true
            self.scheduleVisitBtn.isHidden = true
            self.addMoreBtn.isHidden = true
            self.addContracterQuoteMainView.isHidden = false
            self.contractQuotationHeaderRow.removeLast()
            self.addContracterQuoteSetUp()
            self.addContracterQuoteMainView.addCorner()
            self.addContracterQuoteMainView.addShadow()
        }
        
        addCornerToView(self.saveBtn)
        addCornerToView(self.terminateContractBtn)
        self.saveBtn.titleLabel?.font = UIFont(name: .MontserratSemiBold, size: 16)
        self.terminateContractBtn.titleLabel?.font = UIFont(name: .MontserratSemiBold, size: 14)
        
        self.addNotesTextView.text = "Enter Notes..."
        self.addNotesTextView.addBorder(color: .gray.withAlphaComponent(0.6))
        self.addNotesTextView.addCorner()
        
        [self.selectFolderBtn, self.addMoreBtn, self.addNewVisitBtn].forEach {
            $0?.addBorder(color: .gray.withAlphaComponent(0.2))
            $0?.addShadow()
            $0?.addCorner()
        }
        
        self.addAssetsMainView.addBorder(color: .gray.withAlphaComponent(0.2))
        
        self.self.addAssetsMVHeight.constant = CGFloat(94 + (self.dataRows.count * 70))
        
        self.folderCollectionView.delegate = self
        self.folderCollectionView.dataSource = self
        self.addNotesTextView.delegate = self
        
//        self.addAssetsMainView.addShadow()
//        self.showfolderSpreedSheetView.addShadow()
//        self.scheduleVisitSpreedSheetView.addShadow()
//        self.contractSpreedSheetView.addShadow()
        
        self.frequencyOptionBtn.optionXIB.lblText.text = selectFrequency.rawValue
        
        self.saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.terminateContractBtn.addTarget(self, action: #selector(terminateContractBtnTapped), for: .touchUpInside)
        
        self.setStackView()
        self.folderCVHeight.constant = 0.0
        self.initialDatePicketSetup()
        self.setFrequencyXib()
        
        self.setUpSpreedSheetView()
        self.setUpOverlayImage()
        
        if !self.isForViewOnly {
            self.setUpCreateContractsAPI()
        }else {
            self.setUpViewContracts()
        }
    }
    
    func setUpViewContracts() {
        if !self.isContracterSetup {
            self.loadCategoryDetail()
            self.loadSubCategoryDetail()
            self.getAllCompanies()
        }
        self.getAllManagerUser()
        self.getParentFoldersFromSiteId()
        self.getSiteAssetsBySiteId()
        self.loadAssetDetail()
        if let projectContractId = self.projectContractId {
            self.getContractDetails(by: projectContractId)
        }
    }
    
    func setUpCreateContractsAPI() {
        self.loadCategoryDetail()
        self.loadSubCategoryDetail()
        self.getAllCompanies()
        self.getManagerDetails()
        self.loadAssetDetail()
    }
    
    func addContracterQuoteSetUp() {
        self.addContracterQuoteTx1.lblTFName.text = "Quote"
        self.addContracterQuoteTx2.lblTFName.text = "Note"
        self.addContracterQuoteTx1.tfData.keyboardType = .numberPad
        self.addContracterQuoteTx2.tfData.keyboardType = .numberPad
    }
    
    func setUpSpreedSheetView() {
        self.addAssetSpreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        self.addAssetSpreedSheetView.register(UINib(nibName: String(describing: DeleteActionXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DeleteActionXIB.self))
        self.addAssetSpreedSheetView.register(UINib(nibName: String(describing: SelectAssetXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SelectAssetXIB.self))
        self.addAssetSpreedSheetView.register(UINib(nibName: String(describing: ViewActionBtnXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ViewActionBtnXIB.self))
        self.addAssetSpreedSheetView.bounces = false
        self.addAssetSpreedSheetView.dataSource = self
        self.addAssetSpreedSheetView.delegate = self
        self.addAssetSpreedSheetView.showsHorizontalScrollIndicator = false
        self.addAssetSpreedSheetView.showsVerticalScrollIndicator = false
        
        if self.isForViewOnly {
            self.showfolderSpreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
            self.showfolderSpreedSheetView.register(UINib(nibName: String(describing: ViewActionBtnXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ViewActionBtnXIB.self))
            if self.isContracterSetup {
                self.showfolderSpreedSheetView.register(UINib(nibName: String(describing: ChooseImageCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ChooseImageCell.self))
            }
            self.showfolderSpreedSheetView.bounces = false
            self.showfolderSpreedSheetView.dataSource = self
            self.showfolderSpreedSheetView.delegate = self
            self.showfolderSpreedSheetView.showsHorizontalScrollIndicator = false
            self.showfolderSpreedSheetView.showsVerticalScrollIndicator = false
            
            self.scheduleVisitSpreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
            self.scheduleVisitSpreedSheetView.register(UINib(nibName: String(describing: DeleteActionXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DeleteActionXIB.self))
            self.scheduleVisitSpreedSheetView.bounces = false
            self.scheduleVisitSpreedSheetView.dataSource = self
            self.scheduleVisitSpreedSheetView.delegate = self
            self.scheduleVisitSpreedSheetView.showsHorizontalScrollIndicator = false
            self.scheduleVisitSpreedSheetView.showsVerticalScrollIndicator = false
            
            self.contractSpreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
            self.contractSpreedSheetView.register(UINib(nibName: String(describing: StatusXIb.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StatusXIb.self))
            self.contractSpreedSheetView.register(UINib(nibName: String(describing: CustomTextFieldCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CustomTextFieldCell.self))
            self.contractSpreedSheetView.register(UINib(nibName: String(describing: ContractQuotationActionXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ContractQuotationActionXIB.self))
            self.contractSpreedSheetView.bounces = false
            self.contractSpreedSheetView.dataSource = self
            self.contractSpreedSheetView.delegate = self
            self.contractSpreedSheetView.showsHorizontalScrollIndicator = false
            self.contractSpreedSheetView.showsVerticalScrollIndicator = false
        }
    }
    
    func setUpOverlayImage() {
        self.overlayView = UIView(frame: self.view.bounds)
        self.overlayView.backgroundColor = .clear
        self.overlayView.isHidden = true // Initially hidden
        self.view.addSubview(self.overlayView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTableView))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hideTableView))
        self.overlayView.addGestureRecognizer(panGesture)
        self.overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyBoardHeight = 0.0
    }
    
    func showTableView() {
        self.overlayView.isHidden = false
        self.tableView?.isHidden = false
    }
    
    @objc func hideTableView() {
        self.overlayView.isHidden = true
        self.tableView?.isHidden = true
        self.tableView?.hideTableView()
    }
    
    func setScrollViewScrolling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.actionBtnSubView.layoutIfNeeded()
            self.mainView.frame.size.height = self.actionBtnSubView.frame.maxY + 10
            self.scrollView.contentSize.height = self.actionBtnSubView.frame.maxY + 10
        }
    }
        
    func hideBottomViews(isHide: Bool = false) {
        guard !self.isForViewOnly else { return  }
        if isHide {
            self.addAssetsMVHeight.constant = 0.0
            self.scheduleVisitBtnHeight.constant = 0.0
            self.scheduleVisitTop.constant = 0.0
            self.assetMainViewTop.constant = 0.0
            
            self.scheduleVisitBtn.isHidden = true
            self.addAssetsMainView.isHidden = true
        }else {
            self.addAssetsMVHeight.constant = 200.0
            self.scheduleVisitBtnHeight.constant = 76.0
            self.scheduleVisitTop.constant = 7.0
            self.assetMainViewTop.constant = 10.0
            self.scheduleVisitBtn.isHidden = false
            self.addAssetsMainView.isHidden = false
        }
    }
    
    func initialDatePicketSetup() {
        let bgColor = self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        self.startDateOptionBtn.optionXIB.dummyTF.backgroundColor = bgColor
        self.startDateOptionBtn.optionXIB.lblText.text = ddMMyyyyStr
        self.startDateOptionBtn.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.startDateOptionBtn.optionXIB.btnDownClick.tag = self.startDateTag
        self.startDateOptionBtn.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
        
        self.endDateOptionBtn.optionXIB.dummyTF.backgroundColor = bgColor
        self.endDateOptionBtn.optionXIB.lblText.text = ddMMyyyyStr
        self.endDateOptionBtn.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.endDateOptionBtn.optionXIB.btnDownClick.tag = self.endDateTag
        self.endDateOptionBtn.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
        
        self.scheduleVisitBtn.optionXIB.dummyTF.backgroundColor = bgColor
        self.scheduleVisitBtn.optionXIB.lblText.text = ddMMyyyyStr
        self.scheduleVisitBtn.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.scheduleVisitBtn.optionXIB.btnDownClick.tag = self.scheduleDateTag
        self.scheduleVisitBtn.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
    }
    
    func setStackView() {
        self.stackView.frame.size.width = 15.0
        self.stackView.addCorner(value: 3)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let increaseTap = UITapGestureRecognizer(target: self, action: #selector(increaseValue))
        increaseTap.numberOfTapsRequired = 1
        self.increaseLbl.addGestureRecognizer(increaseTap)
        
        let decreaseTap = UITapGestureRecognizer(target: self, action: #selector(decreaseValue))
        decreaseTap.numberOfTapsRequired = 1
        self.decreaseLbl.addGestureRecognizer(decreaseTap)
        
        if self.isContracterSetup {
            NSLayoutConstraint.activate([
                self.stackView.leadingAnchor.constraint(equalTo: self.addContracterQuoteTx1.tfData.trailingAnchor, constant: -30),
                self.stackView.centerYAnchor.constraint(equalTo: self.addContracterQuoteTx1.tfData.centerYAnchor),
                self.stackView.widthAnchor.constraint(equalToConstant: 20),
                self.stackView.heightAnchor.constraint(equalToConstant: 30)
            ])
        }else {
            NSLayoutConstraint.activate([
                self.stackView.leadingAnchor.constraint(equalTo: self.budgetTxField.tfData.trailingAnchor, constant: -30),
                self.stackView.centerYAnchor.constraint(equalTo: self.budgetTxField.tfData.centerYAnchor),
                self.stackView.widthAnchor.constraint(equalToConstant: 20),
                self.stackView.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
    }
    
    // Method to increase the value
    @objc func increaseValue() {
        self.value += 1
    }
    
    // Method to decrease the value
    @objc func decreaseValue() {
        self.value -= 1
    }
    
    @IBAction func addNewVisitClicked(_ sender: Any) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }
        if self.scheduleVisitBtn.optionXIB.lblText.text == ddMMyyyyStr {
            SCLAlertView().showInfo("", subTitle: "Please select date to schedule visit.")
        }else {
            if let projectContractId = self.projectContractId {
                self.updateVisitsdetail(projectContractId: projectContractId)
            }
        }
    }
    
    @IBAction func selectFolderClicked(_ sender: Any) {
        let vc = documnetSB.instantiateViewController(withIdentifier: "FileCopyMoveActionVC") as! FileCopyMoveActionVC
        vc.actionType = .select
        vc.addFolderToContractsDelegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func addMoreBtnClicked(_ sender: Any) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }
        self.numberOfAddAssetsArray += 1
        self.dataRows.append(["", "", "", "", ""])
        self.addAssetSpreedSheetView.reloadData()
    }
        
    @objc func openDatePickerVC(_ sender: UIButton) {
        guard !self.isForViewOnly || sender.tag == self.scheduleDateTag || self.isContracterSetup else { return }
        if self.isContracterSetup {
            self.openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: nil)
            return
        }
        var dateString: String?
        var selectedDate: Date?
        switch sender.tag {
        case self.startDateTag:
            dateString = self.selectedStartDate
            break
        case self.endDateTag:
            dateString = self.selectedEndDate
            break
        case self.scheduleDateTag:
            dateString = self.selectedScheduleDate
            break
        default:
            break
        }
        if let dateString, let date = dateString.transformToDate(dateFormat: kAssetsDateFormat) {
            selectedDate = date
        }
        self.openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate)
    }

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
    
    func updateTableView(below textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            guard let self else {return}
            showTableView()
            if self.tableView == nil {
                self.tableView = CustomTableView()
            }
            self.tableView?.type = .createContracts
            if let cell = textField.superview?.superview?.superview {
                let cellFrame = self.addAssetSpreedSheetView.convert(cell.frame, to: view)
                let textFieldFrame = textField.convert(textField.bounds, to: view)
                
                let availableSpaceBelowTextField = view.frame.height - globalKeyBoradHeight - textFieldFrame.maxY - 10
                let availableSpaceAboveTextField = textFieldFrame.minY - 10 - navigationHeight
                
                // Calculate the desired height for the tableView
                let desiredTableViewHeight = CGFloat(assetItemArray.count > 5 ? (5 * 40) + 20 : assetItemArray.count * 40)
                
                if desiredTableViewHeight <= availableSpaceBelowTextField {
                    self.tableView?.frame = CGRect(x: textFieldFrame.minX, y: textFieldFrame.maxY + 5, width: textFieldFrame.width + 30, height: desiredTableViewHeight)
                } else if desiredTableViewHeight <= availableSpaceAboveTextField {
                    self.tableView?.frame = CGRect(x: textFieldFrame.minX, y: textFieldFrame.minY - desiredTableViewHeight - 5, width: textFieldFrame.width + 30, height: desiredTableViewHeight)
                } else {
                    if availableSpaceBelowTextField >= availableSpaceAboveTextField {
                        let tableViewHeight = min(desiredTableViewHeight, availableSpaceBelowTextField)
                        self.tableView?.frame = CGRect(x: textFieldFrame.minX,  y: textFieldFrame.maxY + 5, width: textFieldFrame.width + 30, height: tableViewHeight)
                    } else {
                        let tableViewHeight = min(desiredTableViewHeight, availableSpaceAboveTextField)
                        self.tableView?.frame = CGRect(x: textFieldFrame.minX, y: textFieldFrame.minY - tableViewHeight - 5, width: textFieldFrame.width + 30, height: tableViewHeight)
                    }
                }
                
                self.tableView?.isHidden = self.assetItemArray.isEmpty
                self.tableView?.filteredArray = self.assetItemArray
                self.tableView?.showTableView(with: self.assetItemArray)
                view.addSubview(self.tableView!)
                
                self.tableView?.didSelectItem = { selectedItem in
                    print("Selected item: \(selectedItem)")
                    if let tuple = selectedItem as? (String, Int) {
                        
                        let (itemName, itemId) = tuple
                        self.selectedAssetItemArrayIndex.append(itemId)
                        textField.text = itemName
                        var tagIndex = textField.tag - self.addAssetsTag
                        if !self.assetDetailsResponse.indices.contains(tagIndex) {
                            tagIndex = 0
                        }
                        if self.dataRows.indices.contains(textField.tag - self.addAssetsTag) {
                            self.dataRows[textField.tag - self.addAssetsTag][0] = itemName
                        }
                        if let assetId = self.assetDetailsResponse[tagIndex].assetId {
                            self.dataRows[textField.tag - self.addAssetsTag][1] = "\(assetId)"
                        }
                        
                        let position: String? = (self.assetDetailsResponse[tagIndex].position)
                        let floor: String? = (self.assetDetailsResponse[tagIndex].floor)
                        let room: String? = (self.assetDetailsResponse[tagIndex].room)
                        
                        let location = [position, floor, room]
                        
                        let locationResult = location
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        self.dataRows[textField.tag - self.addAssetsTag][2] = locationResult.isEmpty ? "NA > NA > NA" : locationResult
                        
                        let category: String? = (self.assetDetailsResponse[tagIndex].category)
                        let subCategory: String? = (self.assetDetailsResponse[tagIndex].subCategory)
                        let subCategory2: String? = (self.assetDetailsResponse[tagIndex].subCategory2)
                        let subCategory3: String? = (self.assetDetailsResponse[tagIndex].subCategory3)
                        
                        let categories = [category, subCategory, subCategory2, subCategory3]
                        
                        let categoriesResult = categories
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        self.dataRows[textField.tag - self.addAssetsTag][3] = categoriesResult.isEmpty ? "NA > NA > NA" : categoriesResult
                        self.addAssetSpreedSheetView.reloadData()
                    }
                }
            } else {
                print("Error: Could not find the UICollectionViewCell containing the text field.")
            }
        }
    }
    
    func createNewContract() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")

        self.contractRequest.projectContractId = nil
        self.contractRequest.summary = self.summaryTxField.tfData.text
        self.contractRequest.siteId = UserConstants.shared.selectedSiteID
        
        self.contractRequest.status = "Active"
        self.contractRequest.budget = self.budgetTxField.tfData.text
        self.contractRequest.description = self.addNotesTextView.text
        self.contractRequest.contractorQuotes = []
        
        let apiService = ApiService.contractsManageAPI(model: self.contractRequest)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ContractDetailsModel>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let scheduleRequest) = responseResult {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.contractResponse = scheduleRequest
                        if let projectContractId = self.contractResponse.projectContractId {
                            if !self.selectedAssetsItemArray.isEmpty {
                                self.updateFolderDetail(projectContractId: projectContractId)
                            }
                            self.updateAssetsDetail(projectContractId: projectContractId)
                            if self.scheduleVisitBtn.optionXIB.lblText.text != "" {
                                self.updateVisitsdetail(projectContractId: projectContractId)
                            }
                            self.updateCalenderDetail()
                            scl.hideView()
                            SCLAlertView().showSuccess("", subTitle: "Successully added contract.")
                        }else {
                            scl.hideView()
                        }
                    }
                }else {
                    scl.hideView()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                scl.hideView()
                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
            }
        }
    }
    
    func updateCreatedContract(ContractQuotationType: ContractQuotationType? = nil, Index: Int?, managerNotes: String?) {
        
        guard let projectContractResponse = self.projectContractResponse else { return }
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        self.contractRequest.projectContractId = self.projectContractId
        self.contractRequest.summary = self.summaryTxField.tfData.text
        self.contractRequest.category = projectContractResponse.category
        self.contractRequest.subCategory = projectContractResponse.subCategory
        self.contractRequest.status = projectContractResponse.status
        self.contractRequest.budget = projectContractResponse.budget
        self.contractRequest.startDate = projectContractResponse.startDate?.replacingOccurrences(of: "T", with: " ") ?? ""
        self.contractRequest.endDate = projectContractResponse.endDate?.replacingOccurrences(of: "T", with: " ") ?? ""
        self.contractRequest.projectManagerUserId = projectContractResponse.projectManagerUserId
        self.contractRequest.description = projectContractResponse.description
        self.contractRequest.siteId = projectContractResponse.siteId
        self.contractRequest.contractorCompanyId = Int(projectContractResponse.contractorCompanyId ?? "0")
        self.contractRequest.frequency = projectContractResponse.frequency
        self.contractRequest.contractorQuotes = projectContractResponse.contractorQuotes
        
        if let contractorQuotes = self.projectContractResponse?.contractorQuotes, let index = Index {
            self.contractRequest.contractorQuotes = contractorQuotes
            contractorQuotes[index].status = ContractQuotationType?.rawValue
            if let managerNotes = managerNotes {
                contractorQuotes[index].managerNotes = managerNotes
            }
        }
        
        if self.isContracterSetup {
            let contractorQuote = ContractorQuote()
            contractorQuote.quoteId = nil
            contractorQuote.projectContractId = self.projectContractId
            contractorQuote.status = "Recieved"
            if self.addContracterQuoteTx1.tfData.text == "" {
                SCLAlertView().showError("Error", subTitle: "Please enter quote")
            }else if self.addContracterQuoteTx2.tfData.text == "" {
                SCLAlertView().showError("Error", subTitle: "Please enter quote note")
            }
            if let quote = Double(self.addContracterQuoteTx1.tfData.text ?? "") {
                contractorQuote.quote = quote
            }else {
                return
            }
            contractorQuote.contractor = UserConstants.shared.userDetail?.name
            contractorQuote.company = UserConstants.shared.userDetail?.companyName
            contractorQuote.quoteDate = Date().transformToString(dateFormat: kAssetsDateFormat)
            contractorQuote.notes = self.addContracterQuoteTx2.tfData.text
            self.contractRequest.contractorQuotes?.append(contractorQuote)
            
            self.contractRequest.contractorCompanyId = UserConstants.shared.userDetail?.companyId
            self.contractRequest.siteId = UserConstants.shared.selectedSiteID
        }
        
        let apiService  = ApiService.contractsManageAPI(model: self.contractRequest)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let reScheduleRequest) = responseResult {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        scl.hideView()
                        SCLAlertView().showSuccess("", subTitle: "Successully updated contract.")
                        if let projectContractId = self.projectContractId {
                            self.getContractDetails(by: projectContractId)
                        }
                        if let projectContractId = self.projectContractId, !self.isContracterSetup {
                            self.updateAssetsDetail(projectContractId: projectContractId)
                        }
                        self.addContracterQuoteTx1.tfData.text = ""
                        self.addContracterQuoteTx2.tfData.text = ""
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                scl.hideView()
                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
            }
        }
    }
    
    func updateFolderDetail(projectContractId: Int) {
        let extractedValues = self.selectedAssetsItemArray.compactMap { $0.values.first }
        self.folderRequest.mandatoryFolders = extractedValues
        self.folderRequest.removeMandatoryFolders = nil
        let apiService = ApiService.contractsFolderAPI(projectContractId: projectContractId, model: self.folderRequest)
        APIClient.requestWithCode(apiService){ [weak self] isSuccess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if code == 200 {
                    print("Folder updated successfully")
                }
            }
        }
    }
    
    func updateAssetsDetail(projectContractId: Int) {
        let assets = self.dataRows.map { Int($0[1]) }.compactMap({$0})
        self.assetRequest.addAssets = []
        self.assetRequest.addAssets?.append(contentsOf: assets)
        
        self.assetRequest.removeAssets = removedAssets.filter { !assets.contains($0) }
        
        let apiService = ApiService.contractsAssetsAPI(projectContractId: projectContractId, model: self.assetRequest)
        APIClient.requestWithCode(apiService){ [weak self] isSuccess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if code == 200 {
                    print("Assets updated successfully")
                }
            }
        }
    }
    
    func updateVisitsdetail(projectContractId: Int, scheduleRequest: ScheduleRequest? = nil) {
        if scheduleRequest == nil {
            self.visitRequest.scheduleId = nil
            self.visitRequest.projectContractId = projectContractId
            self.visitRequest.visitPurpose = "Inspection"
            self.visitRequest.status = "Scheduled"
            self.visitRequest.rescheduleDate = ""
            
            let apiService = ApiService.contractsVisitAPI(model: self.visitRequest)
            self.updateVisiteDetailsAPI(apiService: apiService) { _ in
                
            }
        }else if let scheduleRequest = scheduleRequest {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let scl = SCLAlertView(appearance: appearance)
            scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
            let apiService = ApiService.contractsVisitAPI(model: scheduleRequest)
            self.updateVisiteDetailsAPI(apiService: apiService) { _ in
                scl.hideView()
            }
        }
    }
    
    func updateVisiteDetailsAPI(apiService: ApiService, completion: @escaping (Bool) -> Void) {
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ScheduleRequest>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let scheduleRequest) = responseResult {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.isForViewOnly {
                            if let projectContractId = self.projectContractId {
                                self.getContractDetails(by: projectContractId)
                                SCLAlertView().showSuccess("", subTitle: "Visit has been successfully scheduled.")
                            }
                        }
                    }
                }
                completion(true) // Completion called after success
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false) // Completion called after failure
            }
        }
    }
    
    func updateCalenderDetail() {
        let calendarRequest = CalenderEventRequest()
        calendarRequest.siteId = UserConstants.shared.selectedSiteID
        calendarRequest.userId = UserConstants.shared.userDetail?.userId ?? 0
        calendarRequest.eventType = "Contract"
        calendarRequest.startDate = self.selectedStartDate
        calendarRequest.endDate = self.selectedEndDate
        calendarRequest.shortText = "Contract : \(self.summaryTxField.tfData.text ?? "")"
        calendarRequest.includeCompanyUsers = true
        
        let apiService = ApiService.contractsCalenderAPI(model: calendarRequest)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CalendarEventResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let scheduleRequest) = responseResult {
                    print("Calender Event Updated Successfully")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func saveBtnTapped() {
        
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }
        
        guard self.summaryTxField.tfData.text != "" else {
            SCLAlertView().showError("Error", subTitle: "Please enter summary.")
            return
        }
        
        guard !(self.categoryOptionBtn.optionXIB.lblText.text == "Category") else {
            SCLAlertView().showError("Error", subTitle: "Please enter category.")
            return
        }
        
        guard !(self.subCategoryOptionBtn.optionXIB.lblText.text == "Sub Category") else {
            SCLAlertView().showError("Error", subTitle: "Please select sub category.")
            return
        }
        
        guard !(self.companyOptionBtn.optionXIB.lblText.text == "Company") else {
            SCLAlertView().showError("Error", subTitle: "Please select company.")
            return
        }
        
        guard self.budgetTxField.tfData.text != "" else {
            SCLAlertView().showError("Error", subTitle: "Please enter budget.")
            return
        }
        
        guard !(self.startDateOptionBtn.optionXIB.lblText.text == ddMMyyyyStr) else {
            SCLAlertView().showError("Error", subTitle: "Please enter start date.")
            return
        }

        guard !(self.endDateOptionBtn.optionXIB.lblText.text == ddMMyyyyStr) else {
            SCLAlertView().showError("Error", subTitle: "Please enter end date.")
            return
        }
        
        if !self.isForViewOnly, self.compareDates() {
            self.createNewContract()
        }else {
            self.updateCreatedContract(ContractQuotationType: nil, Index: nil, managerNotes: nil)
        }
    }
    
    @objc func terminateContractBtnTapped() {
        self.showTerminateContractDetailAlert()
    }
    
    func showTerminateContractDetailAlert() {
        guard let contractName = self.summaryTxField.tfData.text else { return }
        let alert = UIAlertController(title: nil, message: "Do you want to delete \(contractName) contract?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let scl = SCLAlertView(appearance: appearance)
                scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                if let projectContractId = self.projectContractId {
                    let apiService = ApiService.terminateContract(projectId: projectContractId)
                    APIClient.requestWithCode(apiService){ [weak self] isSuccess, code in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            scl.hideView()
                            if code == 200 {
                                SCLAlertView().showSuccess("", subTitle: "\(contractName) Contract has been successfully terminated")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
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
    
    func compareDates() -> Bool {
        guard let startDateString = self.startDateOptionBtn.optionXIB.lblText.text,
                let endDateString = self.endDateOptionBtn.optionXIB.lblText.text,
                let startDate = dateFormatter.date(from: startDateString),
                let endDate = dateFormatter.date(from: endDateString) else {
              return false
          }
          
          if startDate > endDate {
              SCLAlertView().showError("Error", subTitle: "Start date should be in past or earlier than the end date.")
              return false
          } else {
              return true
          }
      }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}

//MARK: - CollectionView
extension CreateContractsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedAssetsItemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        if self.selectedAssetsItemArray.count > indexPath.row {
            if let tag = self.selectedAssetsItemArray[indexPath.row].keys.first {
                cell.lblSiteName.text = tag
            }
            if self.isFieldsEditable {
                cell.btnRemoveSite.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        self.selectedAssetsItemArray.remove(at: indexPath.row)
                        self.folderCollectionView.reloadData()
                        if self.selectedAssetsItemArray.isEmpty {
                            self.folderCVHeight.constant = 0.0
                        }
                    }
                }
            }else {
                let width = CGFloat.zero
                cell.closeImageViewWidth.constant = width
                cell.closeImageView.frame.size.width = width
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.selectedAssetsItemArray.count > indexPath.row {
            if let text = self.selectedAssetsItemArray[indexPath.row].keys.first {
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: self.isFieldsEditable ? 10+5+22+5 : 10+5+5).width
                return CGSize(width: width, height: 40)
            }else {
                return .zero
            }
        }
        return .zero
    }
    
}

//MARK: - DatePickerVCDelegate
extension CreateContractsVC: DatePickerVCDelegate {
    func datePickerVCDidSelectDate(vc: UIViewController, date: Date?) {
        let assetDateString = date?.transformToString(dateFormat: kAssetsDateFormat)
        let dateString: String
        if let date {
            dateString = date.transformToString(dateFormat: ddMMyyyyStr)
        }else {
            dateString = ddMMyyyyStr
        }
        if self.isContracterSetup {
            let scheduleRequest = ScheduleRequest()
            scheduleRequest.scheduleId = self.projectContractScheduleVisits[vc.view.tag].scheduleId
            scheduleRequest.visitPurpose = "Inspection"
            scheduleRequest.status = "Reschedule Requested"
            scheduleRequest.projectContractId = self.projectContractId
            scheduleRequest.visitDate = self.projectContractScheduleVisits[vc.view.tag].visitDate?.replacingOccurrences(of: "T", with: " ")
            scheduleRequest.rescheduleDate = date?.transformToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            if let assetDateString = formatDateString(assetDateString ?? "") {
                self.showRecheduleAlert(visitDate: assetDateString, schedule: scheduleRequest)
            }
            return
        }
        switch vc.view.tag {
        case self.startDateTag:
            self.selectedStartDate = assetDateString
            self.contractRequest.startDate = assetDateString?.replacingOccurrences(of: "T", with: " ") ?? ""
            self.startDateOptionBtn.optionXIB.lblText.text = dateString
            break
        case self.endDateTag:
            self.selectedEndDate = assetDateString
            self.contractRequest.endDate = assetDateString?.replacingOccurrences(of: "T", with: " ") ?? ""
            self.endDateOptionBtn.optionXIB.lblText.text = dateString
            break
        case self.scheduleDateTag:
            self.selectedScheduleDate = assetDateString
            self.visitRequest.visitDate = assetDateString?.replacingOccurrences(of: "T", with: " ") ?? ""
            self.scheduleVisitBtn.optionXIB.lblText.text = dateString
            break
        default:
            break
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension CreateContractsVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
}

extension CreateContractsVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == self.addAssetSpreedSheetView {
            return self.addAssetsHeaderRow.count
        }else if spreadsheetView == self.showfolderSpreedSheetView {
            return self.isContracterSetup ? self.uploadFolderHeaderRow.count : self.folderHeaderRow.count
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView {
            return self.scheduleVisitHeaderRow.count
        }else if spreadsheetView == self.contractSpreedSheetView {
            return self.contractQuotationHeaderRow.count
        }
        return 0
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == self.addAssetSpreedSheetView {
            if self.dataRows.isEmpty {
                return 1 + 1
            }
            return self.dataRows.count + 1
        }else if spreadsheetView == self.showfolderSpreedSheetView {
            if self.projectContractFolderResponseModel.isEmpty {
                return 1 + 1
            }
            return self.projectContractFolderResponseModel.count + 1
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView {
            if self.projectContractScheduleVisits.isEmpty {
                return 1 + 1
            }
            return self.projectContractScheduleVisits.count + 1
        }else if spreadsheetView == self.contractSpreedSheetView {
            if self.contractQuotationResponse.isEmpty {
                return 1 + 1
            }
            return self.contractQuotationResponse.count + 1
        }
        return 0
    }
        
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if spreadsheetView == self.contractSpreedSheetView {
            if self.contractQuotationResponse.isEmpty {
                let maxColumnWidth = getMaxLabelSize(textArray: ["No Contractor Quotation are available"], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else {
                var stringsArray = [String]()
                if column == 0 {
                    stringsArray = self.contractQuotationResponse.compactMap({$0.contractor})
                }else if column == 1 {
                    stringsArray = self.contractQuotationResponse.compactMap({$0.company})
                }else if column == 2 {
                    stringsArray = self.contractQuotationResponse.compactMap({"\(String(describing: $0.quote))"})
                }else if column == 3 {
                    stringsArray = self.contractQuotationResponse.compactMap({$0.quoteDate})
                }else if column == 4 {
                    stringsArray = self.contractQuotationResponse.compactMap({$0.notes})
                }else if column == 6 {
                    stringsArray = self.contractQuotationResponse.compactMap({$0.status})
                }else if column == 5  {
                    return 180.0
                }else if column == 7 {
                    return 150.0
                }
                stringsArray.append(self.contractQuotationHeaderRow[column])
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 300).width
                return maxColumnWidth
            }
        }else if spreadsheetView == self.showfolderSpreedSheetView {
            if !self.isContracterSetup {
                if self.projectContractFolderResponseModel.isEmpty {
                    let maxColumnWidth = getMaxLabelSize(textArray: ["No Folders are available to view"], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else {
                    var stringsArray = [String]()
                    if column == 0 {
                        stringsArray = self.projectContractFolderResponseModel.compactMap({$0.name})
                        stringsArray.append(self.folderHeaderRow[0])
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }
            }else {
                if self.projectContractFolderResponseModel.isEmpty {
                    let maxColumnWidth = getMaxLabelSize(textArray: ["No Folders are available to upload file"], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else {
                    var stringsArray = [String]()
                    if column == 1 {
                        return 300.0
                    }
                    if column == 0 {
                        stringsArray = self.projectContractFolderResponseModel.compactMap({$0.name})
                        stringsArray.append(self.uploadFolderHeaderRow[0])
                    }else {
                        stringsArray.append(self.uploadFolderHeaderRow[column])
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }
            }
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView {
            if self.projectContractScheduleVisits.isEmpty {
                let maxColumnWidth = getMaxLabelSize(textArray: ["No Visits are available"], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else if column == 0 {
                var stringsArray = [String]()
                stringsArray = self.projectContractScheduleVisits.compactMap({formatDateString($0.visitDate ?? "")})
                stringsArray.append(self.scheduleVisitHeaderRow[0])
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 300).width
                return maxColumnWidth
            }else {
                var stringsArray = [String]()
                if column == 1 {
                    stringsArray = self.projectContractScheduleVisits.compactMap({$0.status})
                    stringsArray.append(self.scheduleVisitHeaderRow[1])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
               }else {
                    stringsArray.append(self.scheduleVisitHeaderRow[2])
                   let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 60, widthAddition: 40, maxWidth: 200).width
                   return maxColumnWidth
                }
            }
        }else if spreadsheetView == self.addAssetSpreedSheetView {
            var stringsArray = [String]()
            if self.dataRows.isEmpty {
                let maxColumnWidth = getMaxLabelSize(textArray: ["No Assets are added. Please click on Add more button to add assets in this contract."], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else {
                if column == 0 {
                    return 230
                }else if column == 1 {
                    stringsArray = dataRows.map { $0[1] }
                    stringsArray.append(self.addAssetsHeaderRow[1])
                }else if column == 2 {
                    stringsArray = dataRows.map { $0[2] }
                    stringsArray.append(self.addAssetsHeaderRow[2])
                }else if column == 3 {
                    stringsArray = dataRows.map { $0[3] }
                    stringsArray.append(self.addAssetsHeaderRow[3])
                }
                if column != 4 {
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 300).width
                    return maxColumnWidth
                } else {
                    return 150
                }
            }
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if spreadsheetView == self.contractSpreedSheetView {
            if row == 0 {
                let textArray = self.contractQuotationHeaderRow
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else if self.contractQuotationHeaderRow.isEmpty {
                return 50
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({$0.contractor}))
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({$0.company}))
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({"\(String(describing: $0.quote))"}))
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({$0.quoteDate}))
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({$0.notes}))
                optionArray.append(contentsOf: self.contractQuotationResponse.compactMap({$0.status}))
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                let count = self.contractQuotationResponse.count == 0 ? 1 : self.contractQuotationResponse.count
                let height = headerHeight * CGFloat(count) + 45.0
                if self.contratDetailViewHeight.constant != height {
                    self.contratDetailViewHeight.constant = height
                }
                return headerHeight
            }
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView {
            if row == 0 {
                let textArray = self.scheduleVisitHeaderRow
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else if self.projectContractScheduleVisits.isEmpty {
                return 50
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: self.projectContractScheduleVisits.compactMap({"\(String(describing: formatDateString($0.visitDate ?? "")))\n\n\(String(describing: formatDateString($0.rescheduleDate ?? "")))"}))
                optionArray.append(contentsOf: self.projectContractScheduleVisits.compactMap({$0.status}))
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                
                let count = self.projectContractScheduleVisits.count == 0 ? 1 : self.projectContractScheduleVisits.count
                let height = headerHeight * CGFloat(count) + 45.0
                if self.scheduleViewHeight.constant != height {
                    self.scheduleViewHeight.constant = height
                }
                return headerHeight
            }
        }else if spreadsheetView == self.showfolderSpreedSheetView {
            if !self.isContracterSetup {
                if row == 0 {
                    let textArray = self.folderHeaderRow
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 10+10
                    let minHeight = refSize.height-heightAddition
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }else if self.projectContractFolderResponseModel.isEmpty {
                    return 50
                }else {
                    let refSize = CGSize(width: 100, height: 50)
                    let heightAddition: CGFloat = 10+10
                    let minHeight = refSize.height-heightAddition
                    var optionArray = [String?]()
                    optionArray.append(contentsOf: self.projectContractFolderResponseModel.compactMap({$0.name}))
                    let textArray = optionArray.compactMap{$0}
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                    
                    let count = self.projectContractFolderResponseModel.count == 0 ? 1 : self.projectContractFolderResponseModel.count
                    let height = headerHeight * CGFloat(count) + 45.0
                    if self.showFolderViewHeight.constant != height {
                        self.showFolderViewHeight.constant = height
                    }
                    return headerHeight
                }
            }else {
                if row == 0 {
                    let textArray = self.uploadFolderHeaderRow
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 10+10
                    let minHeight = refSize.height-heightAddition
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }else if self.projectContractFolderResponseModel.isEmpty {
                    return 50
                }else {
                    let refSize = CGSize(width: 100, height: 50)
                    let heightAddition: CGFloat = 10+10
                    let minHeight = refSize.height-heightAddition
                    var optionArray = [String?]()
                    optionArray.append(contentsOf: self.projectContractFolderResponseModel.compactMap({$0.name}))
                    let textArray = optionArray.compactMap{$0}
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                    
                    let count = self.projectContractFolderResponseModel.count == 0 ? 1 : self.projectContractFolderResponseModel.count
                    let height = headerHeight * CGFloat(count) + 45.0
                    if self.showFolderViewHeight.constant != height {
                        self.showFolderViewHeight.constant = height
                    }
                    return headerHeight
                }
            }
        }else if spreadsheetView == self.addAssetSpreedSheetView {
            if row == 0 {
                let textArray = self.addAssetsHeaderRow
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                return 70
            }
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if spreadsheetView == self.contractSpreedSheetView {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            if indexPath.row == 0 {
                self.cellBorderSetUp(cell: cell, isHeader: true)
                cell.lblText.text = self.contractQuotationHeaderRow[indexPath.section]
                cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                return cell
            }else if self.contractQuotationResponse.isEmpty {
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.lblText.text = "No Contractor Quotation are available"
                self.cellBorderSetUp(cell: cell, isHeader: false)
                return cell
            }else {
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: false)
                if indexPath.section == 0 {
                    cell.lblText.text = self.contractQuotationResponse[indexPath.row - 1].contractor
                }else if indexPath.section == 1 {
                    cell.lblText.text = self.contractQuotationResponse[indexPath.row - 1].company
                }else if indexPath.section == 2 {
                    if let quote = self.contractQuotationResponse[indexPath.row - 1].quote {
                        cell.lblText.text = "\(quote)"
                    }
                }else if indexPath.section == 3 {
                    cell.lblText.text = self.contractQuotationResponse[indexPath.row - 1].quoteDate
                }else if indexPath.section == 4 {
                    cell.lblText.text = self.contractQuotationResponse[indexPath.row - 1].notes
                }else if indexPath.section == 5 {
                    if !self.isContracterSetup {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CustomTextFieldCell", for: indexPath) as! CustomTextFieldCell
                        self.cellBorderSetUp(cell: cell, isHeader: false)
                        if cell.xib.textField.text == "" {
                            cell.xib.textField.placeholder = "Enter Notes..."
                        }
                        cell.xib.textField.tag = indexPath.row
                        cell.xib.textField.addCorner()
                        cell.xib.textField.addBorder(color: .gray)
                        cell.xib.textField.delegate = self
                        return cell
                    }else {
                        cell.lblText.text = self.contractQuotationResponse[indexPath.row - 1].managerNotes
                    }
                }else if indexPath.section == 6 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
                    self.cellBorderSetUp(cell: cell, isHeader: false)
                    cell.setUp(string: self.contractQuotationResponse[indexPath.row - 1].status ?? "")
                    cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    return cell
                }else if indexPath.section == 7 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ContractQuotationActionXIB", for: indexPath) as! ContractQuotationActionXIB
                    self.cellBorderSetUp(cell: cell, isHeader: false)
                    cell.thumbsDownImage.tintColor = .black
                    cell.thumbsUpImage.tintColor = .black
                    if self.responseArrayOfStatus.indices.contains(indexPath.row - 1) {
                       if self.responseArrayOfStatus[indexPath.row - 1] == ContractQuotationType.awarded.rawValue {
                            cell.thumbsUpImage.tintColor = .greenStatus
                           cell.thumbsDownImage.tintColor = .black
                       }else if self.responseArrayOfStatus[indexPath.row - 1] == ContractQuotationType.rejected.rawValue {
                           cell.thumbsDownImage.tintColor = .red
                           cell.thumbsUpImage.tintColor = .black
                       }
                    }
                    
                    cell.btnThumbsUp.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let row = indexPath.row-1
                            self.updateCreatedContract(ContractQuotationType: .awarded, Index: row, managerNotes: self.managerNotesRows[row])
                        }
                    }
                    cell.btnThumbsDown.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let row = indexPath.row-1
                            self.updateCreatedContract(ContractQuotationType: .rejected, Index: row, managerNotes: self.managerNotesRows[row])
                        }
                    }
                    cell.btnDelete.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let row = indexPath.row-1
                            //blank
                            //website not working
                        }
                    }
                    return cell
                }
                return cell
            }
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            if indexPath.row == 0 {
                self.cellBorderSetUp(cell: cell, isHeader: true)
                cell.lblText.text = self.scheduleVisitHeaderRow[indexPath.section]
                cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                return cell
            }else if self.projectContractScheduleVisits.isEmpty {
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.lblText.text = "No Visits are available"
                self.cellBorderSetUp(cell: cell, isHeader: false)
                self.cellBorderSetUp(cell: cell, isHeader: false)
                return cell
            }else if indexPath.section == 0 {
                cell.backgroundColor = UIColor.white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: false)
                if let rescheduleDate = formatDateString(self.projectContractScheduleVisits[indexPath.row - 1].rescheduleDate ?? ""), !rescheduleDate.isEmpty, let schduleDate = formatDateString(self.projectContractScheduleVisits[indexPath.row - 1].visitDate ?? "") {
                    
                    let fullText = "\(schduleDate)\n\n\(rescheduleDate)"
                    
                    let attributedString = NSMutableAttributedString(string: fullText)
                    
                    let outdatedDateRange = (fullText as NSString).range(of: schduleDate)
                    
                    attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: outdatedDateRange)
                    
                    attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: outdatedDateRange)
                    
                    cell.lblText.attributedText = attributedString
                }else {
                    cell.lblText.text = formatDateString(self.projectContractScheduleVisits[indexPath.row - 1].visitDate ?? "")
                }
                return cell
            }else if indexPath.section == 1 {
                cell.backgroundColor = UIColor.white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = self.projectContractScheduleVisits[indexPath.row - 1].status
                return cell
            }else if indexPath.section == 2 {
                if (self.projectContractScheduleVisits[indexPath.row - 1].status?.lowercased() == "completed".lowercased()) {
                    cell.lblText.text = ""
                    cell.backgroundColor = .white
                    return cell
                }
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "DeleteActionXIB", for: indexPath) as! DeleteActionXIB
                if self.projectContractScheduleVisits[indexPath.row - 1].rescheduleDate == nil {
                    cell.checkMainView.isHidden = true
                }else {
                    cell.checkMainView.isHidden = false
                }
                if self.projectContractScheduleVisits[indexPath.row - 1].rescheduleDate == nil || !(UserDefaults.standard.userRole == .contractor) {
//                    cell.checkMainView.isHidden = true
                }
                
                if self.isContracterSetup {
                    cell.deleteImageView.image = UIImage(systemName: "calendar")
                    cell.deleteImageView.tintColor = .black
                    cell.checkMainView.isHidden = false
                }

                cell.backgroundColor = .white
                self.cellBorderSetUp(cell: cell, isHeader: false)

                cell.deleteAction.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
                cell.deleteAction.tag = indexPath.row - 1
                
                cell.deleteAction.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        if let visitDate = self.projectContractScheduleVisits[row].visitDate, let scheduleId = self.projectContractScheduleVisits[row].scheduleId {
                            self.showDeleteAlert(visitDate: visitDate, id: scheduleId)
                        }
                    }
                }
                
                cell.checkActionBtn.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let row = indexPath.row-1
                        let visitRequest = ScheduleRequest()
                        visitRequest.projectContractId = self.projectContractId
                        visitRequest.scheduleId = self.projectContractScheduleVisits[row].scheduleId
                        visitRequest.visitPurpose = "Inspection"
                        visitRequest.status = "Scheduled"
                        if let rescheduleDate =  self.projectContractScheduleVisits[indexPath.row - 1].rescheduleDate {
                            visitRequest.visitDate = rescheduleDate.replacingOccurrences(of: "T", with: " ")
                        }
                        visitRequest.rescheduleDate = nil
                        if let visitDate = visitRequest.visitDate {
                            self.showRecheduleVisiteAlert(visitDate: visitDate, schedule: visitRequest)
                        }else {
                            visitRequest.status = "Completed"
                            if let visitDate = self.projectContractScheduleVisits[row].visitDate?.replacingOccurrences(of: "T", with: " ") {
                                visitRequest.visitDate = visitDate
                                self.showCompletedVisiteAlert(completeVisitDate: visitDate, schedule: visitRequest)
                            }
                        }
                    }
                }
                return cell
            }
            return cell
        }else if spreadsheetView == self.showfolderSpreedSheetView {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            if indexPath.row == 0 {
                self.cellBorderSetUp(cell: cell, isHeader: true)
                cell.lblText.text = self.isContracterSetup ? self.uploadFolderHeaderRow[indexPath.section] : self.folderHeaderRow[indexPath.section]
                cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                return cell
            }else if self.projectContractFolderResponseModel.isEmpty {
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = self.isContracterSetup ? "No Folders are available to upload file" : "No Folders are available to view"
                return cell
            }else if indexPath.section == 0 {
                cell.backgroundColor = UIColor.white
                cell.lblText.textColor = .black
                cell.lblText.text = self.projectContractFolderResponseModel[indexPath.row - 1].name
                self.cellBorderSetUp(cell: cell, isHeader: false)
                return cell
            }else {
                if (!self.isContracterSetup && indexPath.section == 1) || (self.isContracterSetup && indexPath.section == 2) {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ViewActionBtnXIB", for: indexPath) as! ViewActionBtnXIB
                    self.cellBorderSetUp(cell: cell, isHeader: false)

                    cell.viewActionBtn.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let row = indexPath.row-1
                            if !self.projectContractFolderResponseModel.isEmpty, self.projectContractFolderResponseModel.indices.contains(row) {
                                self.goToFileViewVC(folderItemArray: [self.projectContractFolderResponseModel[row]])
                            }
                        }
                    }
                    return cell
                }else {
                    let index = indexPath.row-1
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ChooseImageCell", for: indexPath) as! ChooseImageCell
                    self.cellBorderSetUp(cell: cell, isHeader: false)
                    CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: cell.xib.chooseFileBtn, tag: index, allowPhotos: true, supportedTypes: [.image, .pdf])
                    return cell
                }
            }
        }else if spreadsheetView == self.addAssetSpreedSheetView {
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: true)
                cell.backgroundColor = UIColor(appColor: .AppTint)
                cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
                cell.lblText.textColor = UIColor.white
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = self.addAssetsHeaderRow[indexPath.section]
                cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                return cell
            }else if self.dataRows.isEmpty {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                self.cellBorderSetUp(cell: cell, isHeader: false)
                cell.backgroundColor = .clear
                cell.lblText.text = "No Assets are added. Please click on Add more button to add assets in this contract."
                cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
                cell.clipsToBounds = false
                return cell
            }else if indexPath.section == 0 && !self.isContracterSetup && !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SelectAssetXIB", for: indexPath) as! SelectAssetXIB
                cell.arrowWidthCons.constant = 20.0
                cell.downArrow.tintColor = .black
                cell.textField.text = self.dataRows[indexPath.row - 1][indexPath.column]
                self.cellBorderSetUp(cell: cell, isHeader: false)
                if !cell.textField.isEditing || (self.dataRows[indexPath.row - 1][indexPath.column]) == "" {
                    cell.downArrow.image = UIImage(systemName: "chevron.down")
                }else {
                    cell.downArrow.image = UIImage(systemName: "chevron.up")
                    cell.selectAssetLbl.isHidden = false
                }
                if self.dataRows[indexPath.row - 1][indexPath.column] != "" {
                    cell.closeIconWidthCons.constant = 30
                    cell.closeIcon.isHidden = false
                    cell.selectAssetLbl.isHidden = false
                }else {
                    cell.closeIconWidthCons.constant = 0
                    cell.closeIcon.isHidden = true
                    cell.textField.text = "Select Asset"
                    cell.selectAssetLbl.isHidden = true
                }
                cell.closeBtn.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.dataRows[indexPath.row - 1] = ["", "", "", "", ""]
                        spreadsheetView.reloadData()
                     }
                }
                cell.textField.delegate = self
                cell.textField.tag = self.addAssetsTag + indexPath.row - 1
                return cell
            }else if (indexPath.section == 0 && self.isContracterSetup) || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                self.cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
                cell.lblText.backgroundColor = UIColor.clear
                
                if (indexPath.section == 0 &&  self.isContracterSetup) {
                    cell.lblText.text = self.dataRows[indexPath.row - 1][indexPath.column]
                }else if indexPath.section == 1 && (self.dataRows[indexPath.row - 1][indexPath.column] == "") {
                    cell.lblText.text = ""
                }else if indexPath.section == 2 && (self.dataRows[indexPath.row - 1][indexPath.column] == "") {
                    cell.lblText.text = ""
                }else if indexPath.section == 3 && (self.dataRows[indexPath.row - 1][indexPath.column] == "") {
                    cell.lblText.text = "New"
                }else {
                    cell.lblText.text = self.dataRows[indexPath.row - 1][indexPath.column]
                }
                return cell
            }else if indexPath.section == 4 {
                if self.isContracterSetup {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ViewActionBtnXIB", for: indexPath) as! ViewActionBtnXIB
                    self.cellBorderSetUp(cell: cell, isHeader: false)

                    cell.viewActionBtn.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let row = indexPath.row-1
                            if let selectedAssetId = Int(self.dataRows[indexPath.row - 1][1]) {
                                self.goFurtherToAssetDetailVC(for: row, isViewModeEdit: false, selectedAssetId: selectedAssetId)
                            }
                        }
                    }

                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "DeleteActionXIB", for: indexPath) as! DeleteActionXIB
                    cell.backgroundColor = .white
                    self.cellBorderSetUp(cell: cell, isHeader: false)
                    if cell.checkMainView != nil {
                        cell.checkMainView.removeFromSuperview()
                        cell.stackView.removeArrangedSubview(cell.checkMainView)
                    }
                    cell.deleteView.addCorner()
                    cell.deleteView.addBorder()
                    cell.deleteView.isUserInteractionEnabled = false
                    cell.deleteMainView.isUserInteractionEnabled = false
                    cell.deleteAction.isUserInteractionEnabled = false
                    return cell
                }
            }
        }
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
        self.cellBorderSetUp(cell: cell, isHeader: false)
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if !self.isContracterSetup {
            if spreadsheetView == self.addAssetSpreedSheetView {
                if indexPath.row != 0, indexPath.column == 4 {
                    if self.dataRows.indices.contains(indexPath.row - 1) {
                        self.dataRows.remove(at: indexPath.row - 1)
                        self.addAssetSpreedSheetView.reloadData()
                    }
                    if self.selectedAssetItemArrayIndex.indices.contains(indexPath.row - 1) {
                        self.selectedAssetItemArrayIndex.remove(at: indexPath.row - 1)
                    }
                }
            }
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if spreadsheetView == self.addAssetSpreedSheetView, self.dataRows.isEmpty {
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: self.addAssetsHeaderRow.count-1))]
        }else if spreadsheetView == self.showfolderSpreedSheetView, self.projectContractFolderResponseModel.isEmpty {
            if !self.isContracterSetup {
                return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: self.folderHeaderRow.count-1))]
            }else {
                return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: self.uploadFolderHeaderRow.count-1))]
            }
        }else if spreadsheetView == self.scheduleVisitSpreedSheetView, self.projectContractScheduleVisits.isEmpty {
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: self.scheduleVisitHeaderRow.count-1))]
        }else if spreadsheetView == self.contractSpreedSheetView, self.contractQuotationResponse.isEmpty {
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: self.contractQuotationHeaderRow.count-1))]
        }else {
            return []
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
}

extension CreateContractsVC {
    func setFrequencyXib() {
        guard !self.isForViewOnly else { return }
        var actions = [UIAction]()
        actions.append(UIAction(title: Frequency.frequency.rawValue, state: selectFrequency == .frequency ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectFrequency = .frequency
                self.frequencyOptionBtn.optionXIB.lblText.text = Frequency.frequency.rawValue
                self.setFrequencyXib()
            }
        }))
        actions.append(UIAction(title: Frequency.daily.rawValue, state: selectFrequency == .daily ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectFrequency = .daily
                self.frequencyOptionBtn.optionXIB.lblText.text = Frequency.daily.rawValue
                self.contractRequest.frequency = Frequency.daily.rawValue
                self.setFrequencyXib()
            }
        }))
        actions.append(UIAction(title: Frequency.weekly.rawValue, state: selectFrequency == .weekly ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectFrequency = .weekly
                self.frequencyOptionBtn.optionXIB.lblText.text = Frequency.weekly.rawValue
                self.contractRequest.frequency = Frequency.daily.rawValue
                self.setFrequencyXib()
            }
        }))
        actions.append(UIAction(title: Frequency.quarterly.rawValue, state: selectFrequency == .quarterly ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectFrequency = .quarterly
                self.frequencyOptionBtn.optionXIB.lblText.text = Frequency.quarterly.rawValue
                self.contractRequest.frequency = Frequency.daily.rawValue
                self.setFrequencyXib()
            }
        }))
        actions.append(UIAction(title: Frequency.yearly.rawValue, state: selectFrequency == .yearly ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectFrequency = .yearly
                self.frequencyOptionBtn.optionXIB.lblText.text = Frequency.yearly.rawValue
                self.contractRequest.frequency = Frequency.daily.rawValue
                self.setFrequencyXib()
            }
        }))
        self.frequencyOptionBtn.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.frequencyOptionBtn.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setManagerXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Manager", state: searchManagerInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.managerOptionBtn.optionXIB.lblText.text = "Manager"
                self.searchManagerInd = 0
                self.setManagerXib()
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.managerRole.enumerated() {
            let area = item.name ?? ""
            
            if seenAreas.contains(area) {
                continue
            }
            seenAreas.insert(area)
            
            actions.append(UIAction(title: area, state: searchManagerInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.managerOptionBtn.optionXIB.lblText.text = item.name
                    self.contractRequest.projectManagerUserId = item.id
                    self.searchManagerInd = key + 1
                    self.setManagerXib()
                }
            }))
        }
        self.managerOptionBtn.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.managerOptionBtn.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setCompanyXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Company", state: searchCompanyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.companyOptionBtn.optionXIB.lblText.text = "Company"
                self.searchCompanyInd = 0
                self.setCompanyXib()
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.allCompanyResponseArray.enumerated() {
            let area = item.companyName ?? ""
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchCompanyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.companyOptionBtn.optionXIB.lblText.text = item.companyName
                    self.contractRequest.contractorCompanyId = item.companyId
                    self.searchCompanyInd = key + 1
                    self.setCompanyXib()
                }
            }))
        }
        self.companyOptionBtn.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.companyOptionBtn.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Category", state: searchCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.categoryOptionBtn.optionXIB.lblText.text = "Category"
                self.searchCategotyInd = 0
                self.setContractsCategoryXib()
            }
        }))
        var seenAreas = Set<String?>()

        for (key,item) in self.siteContractsCategoryResponseArray.enumerated() {
            let area = item.lovValue ?? "No Category"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.categoryOptionBtn.optionXIB.lblText.text = item.lovValue
                    self.contractRequest.category = item.lovValue
                    self.searchCategotyInd = key + 1
                    self.setContractsCategoryXib()
                }
            }))
        }
        self.categoryOptionBtn.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.categoryOptionBtn.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setSubContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Sub Category", state: searchSubCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.subCategoryOptionBtn.optionXIB.lblText.text = "Sub Category"
                self.searchSubCategotyInd = 0
                self.setSubContractsCategoryXib()
            }
        }))
        var seensubCategory = Set<String?>()
        
        for (key,item) in self.siteContractsSubCategoryResponseArray.enumerated() {
            if self.categoryOptionBtn.optionXIB.lblText.text?.lowercased() == item.lovDesc?.lowercased() {
                let subCategory = item.lovValue ?? ""
                
                if seensubCategory.contains(subCategory) {
                    continue
                }
                
                seensubCategory.insert(subCategory)
                
                actions.append(UIAction(title: subCategory, state: searchSubCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchSubCategotyInd = key + 1
                        self.subCategoryOptionBtn.optionXIB.lblText.text = item.lovValue
                        self.contractRequest.subCategory = item.lovValue
                        self.setSubContractsCategoryXib()
                    }
                }))
            }
        }
        self.subCategoryOptionBtn.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.subCategoryOptionBtn.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }

}

extension CreateContractsVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= self.addAssetsTag {
            textField.text = ""
            if !self.assetItemArray.isEmpty {
                self.oldOffsetY = self.scrollView.contentOffset.y
                if self.scrollView.contentOffset.y < self.addAssetsMainView.frame.minY {
                    self.scrollView.contentOffset.y = self.addAssetsMainView.frame.minY
                }
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= self.addAssetsTag {
            if !self.assetItemArray.isEmpty {
                self.scrollView.contentOffset.y = self.oldOffsetY
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag >= self.addAssetsTag {
            if !self.assetItemArray.isEmpty {
                self.updateTableView(below: textField)
            }
        }else {
            if self.managerNotesRows.count > textField.tag - 1 {
                self.managerNotesRows[textField.tag - 1] = textField.text ?? ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag >= self.addAssetsTag {
            if let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
                filterItemArray = []
                filterItemArray = assetItemArray.filter { $0.lowercased().contains(searchText.lowercased()) }
                if filterItemArray.isEmpty {
                    self.tableView?.filteredArray = ["No Data Found"]
                }else {
                    self.tableView?.filteredArray = filterItemArray
                }
            }
        }else if textField.tag != 0 {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
            if self.managerNotesRows.count > textField.tag - 1 {
                self.managerNotesRows[textField.tag - 1] = updatedText
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag >= self.addAssetsTag {
            textField.text = self.dataRows[textField.tag - self.addAssetsTag].first
            self.tableView?.isHidden = true
            self.addAssetSpreedSheetView.reloadData()
        }else {
            if self.managerNotesRows.count > textField.tag - 1 {
                self.managerNotesRows[textField.tag - 1] = textField.text ?? ""
            }
        }
    }
    
}

extension CreateContractsVC: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Notes..."
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.contains("Enter Notes...") {
            textView.text = ""
        }
    }
    
}

extension CreateContractsVC: AddFolderToContractsDelegate {
    
    func addFolderToCreateContract(folderName: String, folderId: Int) {
        let dic = [folderName: folderId]
        self.selectedAssetsItemArray.append(dic)
        self.folderCVHeight.constant = 50.0
        self.folderCollectionView.reloadData()
    }
    
}

extension CreateContractsVC {
    
    //default setup api calling
    func getAllCompanies() {
        let apiService = ApiService.getAllCompanies
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CompanyDetails>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let result) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.companyOptionBtn.optionXIB.lblText.text = "Company"
                        self.allCompanyResponseArray = result
                        self.searchCompanyInd = 0
                        self.setCompanyXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadCategoryDetail() {
        let apiService = ApiService.getProjectContractsCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if self.categoryOptionBtn.optionXIB.lblText.text?.lowercased() != "Category".lowercased() {
                            self.categoryOptionBtn.optionXIB.lblText.text = "Category"
                        }
                        self.siteContractsCategoryResponseArray = siteContractsCategotyArray
                        self.searchCategotyInd = 0
                        self.setContractsCategoryXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadSubCategoryDetail() {
        let apiService = ApiService.getProjectContractSubCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if self.subCategoryOptionBtn.optionXIB.lblText.text?.lowercased() != "Sub Category".lowercased() {
                            self.subCategoryOptionBtn.optionXIB.lblText.text = "Sub Category"
                            self.searchSubCategotyInd = 0
                        }
                    
                        self.siteContractsSubCategoryResponseArray = siteContractsCategotyArray
                        self.setSubContractsCategoryXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getManagerDetails() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.getUserRole(userRole: UserDefaults.standard.userRole, siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                switch responseResult {
                case .array(let result):
                    break
                case .single(let result):
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.managerOptionBtn.optionXIB.lblText.text = "Manager"
                        if let users = result.users {
                            self.managerRole = users
                            self.searchManagerInd = 0
                            self.setManagerXib()
                        }
                    }
                    break
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //API Calling
    func loadAssetDetail() {
        if let siteID = UserConstants.shared.selectedSiteID {
            let apiService = ApiService.getRegistedAssetDetail(model: AssetRegisterData.assetSummaryAPI(siteId: siteID))
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetsResponse>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array:
                        break
                    case .single(let single):
                        if let array = single.assets {
                            if array.isEmpty {
                            }else {
                                strongSelf.assetDetailsResponse = array
                                strongSelf.assetItemArray = strongSelf.assetDetailsResponse.compactMap { $0.assetName }
                            }
                            strongSelf.addAssetSpreedSheetView.reloadData()
                        }
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                }
            }
        }
    }
    
}

extension CreateContractsVC {
    
    //view only api calling
    func getAllManagerUser() {
        let apiService = ApiService.getAllUserDataBy(userRole: .tester)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let result):
                    if let users = result.users {
                        self.managerRole = users
                    }
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getParentFoldersFromSiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.documentSiteParentFoldersAPI(siteId: siteID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ParentFoldersResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.parentFolderItemArray = single.parentFolders ?? []
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }

    func getSiteAssetsBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
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
                    }
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func getContractDetails(by projectContractId: Int) {
        let apiService = ApiService.getProjectContractDetails(projectId: projectContractId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let projectContractResponse):
                    self.projectContractResponse = projectContractResponse
                    self.setUpViewOnlyResponse()
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func setUpViewOnlyResponse() {
        guard let projectContractResponse = projectContractResponse else { return }
        
        self.selectFolderHeightCons.constant = 0.0
        self.assetMainViewTop.constant = 20.0
        
        if self.isContracterSetup || UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers {
            self.summaryTxField.tfData.isEnabled = false
        }

        // Disable input fields and apply styles
        self.budgetTxField.tfData.isEnabled = false
        self.addNotesTextView.isEditable = false
        
        self.viewContractStatusView.addCorner()

        if let siteId = UserConstants.shared.selectedSiteID ?? UserConstants.shared.userDetail?.taggedSites?.first?.id {
            self.viewContractcCompanyDetailLbl.text = UserConstants.shared.allSites.first(where: { $0.siteId == siteId })?.siteName
        }

        // Set label properties
        self.viewContractTitle.numberOfLines = 0
        self.viewContractLbl.textColor = .white
        self.viewContractTitle.textColor = .black
        self.viewContractLbl.font = UIFont(name: .MontserratMedium, size: 16)
        self.viewContractTitle.font = UIFont(name: .MontserratMedium, size: 16)

        // Set project contract details
        self.viewContractLbl.text = projectContractResponse.status
        if projectContractResponse.status?.lowercased() == "TERMINATED".lowercased() {
            self.viewContractStatusView.backgroundColor = .orange
            self.actionBtnSubView.isHidden = true
        }else {
            self.viewContractStatusView.backgroundColor = .greenStatus
        }
        
        if let category = projectContractResponse.category, let subCategory = projectContractResponse.subCategory {
            self.viewContractTitle.text = "View Contract (\(category) > \(subCategory))"
        }

        self.summaryTxField.tfData.text = projectContractResponse.summary
        self.categoryOptionBtn.optionXIB.lblText.text = projectContractResponse.category
        self.subCategoryOptionBtn.optionXIB.lblText.text = projectContractResponse.subCategory
        self.companyOptionBtn.optionXIB.lblText.text = projectContractResponse.contractorCompanyName
        self.budgetTxField.tfData.text = projectContractResponse.budget
        self.managerOptionBtn.optionXIB.lblText.text = projectContractResponse.projectManagerName
        if let startDate = projectContractResponse.startDate {
            self.startDateOptionBtn.optionXIB.lblText.text = formatDateString(startDate) ?? startDate
        }
        
        if let endDate = projectContractResponse.endDate {
            self.endDateOptionBtn.optionXIB.lblText.text = formatDateString(endDate) ?? endDate
        }
        self.frequencyOptionBtn.optionXIB.lblText.text = projectContractResponse.frequency
        
        if let description = projectContractResponse.description, !description.isEmpty {
            self.addNotesTextView.text = description
        }else {
            self.addNotesTextView.text = "Enter Notes..."
        }
        
        if !self.isContracterSetup {
            self.stackView.isHidden = true
        }

        // Apply background color to option views
        [self.budgetTxField.tfData, self.addNotesTextView].forEach { $0?.backgroundColor = UIColor(appColor: .GrayStatusBG) }

        var optionViews = [
            self.startDateOptionBtn.optionXIB, self.endDateOptionBtn.optionXIB,
            self.frequencyOptionBtn.optionXIB, self.managerOptionBtn.optionXIB
        ]
        
        if self.isContracterSetup || UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers {
            optionViews.append(self.subCategoryOptionBtn.optionXIB)
            optionViews.append(self.categoryOptionBtn.optionXIB)
            optionViews.append(self.companyOptionBtn.optionXIB)
            
            self.summaryTxField.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        }

        optionViews.forEach { optionXIB in
            [optionXIB?.dummyTF, optionXIB?.imageView, optionXIB?.lblText].forEach {
                $0?.backgroundColor = UIColor(appColor: .GrayStatusBG)
            }
        }
        
        //contract quation setup
        if let contractQuotationResponse = projectContractResponse.contractorQuotes {
            self.contractQuotationResponse = contractQuotationResponse
            
            self.managerNotesRows = Array(repeating: "", count: contractQuotationResponse.count)
            
            self.responseArrayOfStatus = contractQuotationResponse.compactMap({$0.status})
        }
        self.contractSpreedSheetView.reloadData()
        
        //folder setup
        if let projectContractFolders =  projectContractResponse.projectContractFolders, !projectContractFolders.isEmpty {
            self.projectContractFolderResponseModel = projectContractFolders
        }
        self.showfolderSpreedSheetView.reloadData()
        
       //visit setup
        if let projectContractScheduleVisits =  projectContractResponse.projectContractScheduleVisits, !projectContractScheduleVisits.isEmpty {
            self.projectContractScheduleVisits = projectContractScheduleVisits
        }
        
        self.scheduleVisitSpreedSheetView.reloadData()
        
        //assets setup
        if let projectContractAssets = projectContractResponse.projectContractAssets, !projectContractAssets.isEmpty {
            self.dataRows = []
            for (index, asset) in projectContractAssets.enumerated() {
                self.dataRows.append(["", "", "", "", ""])
                
                if let assetName = asset.assetName {
                    self.dataRows[index][0] = assetName
                }
                
                if let assetId = asset.assetId {
                    self.dataRows[index][1] = "\(assetId)"
                }
                
                let position: String? = (asset.position)
                let floor: String? = (asset.floor)
                let room: String? = (asset.room)
                
                let location = [position, floor, room]
                
                let locationResult = location
                    .compactMap { $0?.isEmpty == false ? $0 : nil }
                    .joined(separator: " > ")
                
                self.dataRows[index][2] = locationResult.isEmpty ? "NA > NA > NA" : locationResult
                
                let category: String? = (asset.category)
                let subCategory: String? = (asset.subCategory)
                let subCategory2: String? = (asset.subCategory2)
                
                let categories = [category, subCategory, subCategory2]
                
                let categoriesResult = categories
                    .compactMap { $0?.isEmpty == false ? $0 : nil }
                    .joined(separator: " > ")
                
                self.dataRows[index][3] = categoriesResult.isEmpty ? "NA > NA" : categoriesResult
                self.addAssetSpreedSheetView.reloadData()
            }
            if !self.dataRows.isEmpty {
                self.removedAssets = self.dataRows.map { Int($0[1]) }.compactMap({$0})
            }
            self.mainView.layoutIfNeeded()
            self.scrollView.layoutIfNeeded()
            self.setScrollViewScrolling()
        }else {
            self.dataRows = []
            self.addAssetSpreedSheetView.reloadData()
        }
        
    }

}

extension CreateContractsVC {
    
    func showRecheduleVisiteAlert(visitDate: String, schedule: ScheduleRequest) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let alert = UIAlertController(title: nil, message: "Do you want to schedule visit to \(visitDate) visit as a requested?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Mark Schedule", style: .destructive) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.updateVisitsdetail(projectContractId: self.projectContractId ?? 0, scheduleRequest: schedule)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCompletedVisiteAlert(completeVisitDate: String, schedule: ScheduleRequest) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let alert = UIAlertController(title: nil, message: "Do you want to mark complete to \(completeVisitDate) visit ?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Mark Visit Complete", style: .destructive) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.updateVisitsdetail(projectContractId: self.projectContractId ?? 0, scheduleRequest: schedule)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDeleteAlert(visitDate: String, id: Int) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers || UserDefaults.standard.userRole == .contractor) else { return }

        let alert = UIAlertController(title: nil, message: "Do you want to delete \(visitDate) visit", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("\(visitDate) deleted.")
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.deleteScheduleVisites(visitDate: visitDate, scheduleId: id)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showRecheduleAlert(visitDate: String, schedule: ScheduleRequest) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let alert = UIAlertController(title: nil, message: "Do you want to reschedule your visit to \(visitDate)", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Reschedule visit", style: .destructive) { _ in
            print("\(visitDate) deleted.")
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.updateVisitsdetail(projectContractId: self.projectContractId ?? 0, scheduleRequest: schedule)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteScheduleVisites(visitDate: String, scheduleId: Int) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let apiService = ApiService.deleteScheduleVisitAPI(scheduleId:scheduleId)
        APIClient.requestDelete(apiService) { [weak self] isSucess in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                scl.hideView()
                if isSucess {
                    if let projectContractId = self.projectContractId {
                        self.getContractDetails(by: projectContractId)
                    let sclAlertView = SCLAlertView()
                    sclAlertView.showSuccess("", subTitle: "\(visitDate) has been deleted successully")
                    }
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    func goToFileViewVC(folderItemArray: [ProjectContractFolderModel]) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let vc = siteContractsSB.instantiateViewController(withIdentifier: "ViewFolderFileVC") as! ViewFolderFileVC
        vc.projectContractFolderItemArray = folderItemArray
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func goFurtherToAssetDetailVC(for index: Int, isViewModeEdit: Bool, selectedAssetId: Int) {
        guard !(UserDefaults.standard.userRole == .siteActionManager || UserDefaults.standard.userRole == .careTaker || UserDefaults.standard.userRole == .siteUsers) else { return }

        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CreateNewAssetVC") as! CreateNewAssetVC
        vc.isViewModeEdit = isViewModeEdit
        vc.selectedAssetId = selectedAssetId
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
}

extension CreateContractsVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        
        let fileName = fileData.fileName
        
        if let image = fileData.image, let fileName = fileName {
            processImage(image, fileName: fileName)
        } else if let fileURL = fileData.fileURL, let fileName =  fileName {
            processFileFromURL(fileURL, fileName: fileName)
        } else {
            showAlert(message: "No valid image or file URL provided.")
            return
        }
        
        guard let selectedImageFile = self.selectedImageFile else { return }
        let index = tag
        if self.projectContractFolderResponseModel.count > index {
            if let cell = self.showfolderSpreedSheetView.cellForItem(at: IndexPath(row: index+1, section: 1)) as? ChooseImageCell {
                cell.xib.fileNameLbl.text = fileData.fileName
            }
        }
        var req = FileUploadRequest()
        req.folderId = self.projectContractFolderResponseModel[index].id
        var fileRequest = FileRequest()
        fileRequest.fileVersion = 1
        fileRequest.siteId = UserConstants.shared.selectedSiteID ?? 297
        fileRequest.name = fileData.fileName
        fileRequest.originalFileName = fileData.fileName
        fileRequest.reviewerUserId = UserConstants.shared.currentUserID
        fileRequest.issueDate = Date().transformToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        fileRequest.expiryDate = fileRequest.issueDate
        fileRequest.uploadDate = fileRequest.issueDate
        req.files = [fileRequest]
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.uploadFileInFolder
        
        APIClient.requestMultipart(api) { multipartFormData in
            let fileURL = selectedImageFile
            do {
                let data = try Data(contentsOf: fileURL)
                multipartFormData.append(data, withName: "files", fileName: fileName, mimeType: APIClient.mimeType(for: fileURL))
            } catch {
                print(error.localizedDescription)
            }
            do {
                var json = req.toJSON()
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                multipartFormData.append(data, withName: "documentRequestString")
            } catch {
                print(error.localizedDescription)
            }
        } completion: { [weak self] (result: Result<APIClient.MappableResult<FileUploadResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let responseResult):
                if case .single(let responseResult) = responseResult {
                    print(responseResult.toJSON())
                    scl.hideView()
                    let sclAlertView = SCLAlertView()
                    sclAlertView.showSuccess("", subTitle: "File uploaded successfully.")
                    self.selectedImageFile = nil
                    if let projectContractId = self.projectContractId {
                        self.getContractDetails(by: projectContractId)
                    }
                }else {
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
//                self.getParentFoldersFromSiteId()
//                self.showfolderSpreedSheetView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                scl.hideView()
                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
            }
        }
    }
    
    func filePickerDidClose(tag: Int) {
        
    }
    
}

protocol AddFolderToContractsDelegate: AnyObject {
    func addFolderToCreateContract(folderName: String, folderId: Int)
}

extension CreateContractsVC {
    
    func cellBorderSetUp(cell: Cell, isHeader: Bool) {
        if isHeader {
            cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.backgroundColor = UIColor(appColor: .AppTint)
        }else {
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = .white
        }
    }
    
    func processImage(_ image: UIImage, fileName: String) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageSize = imageData.count
            let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
            if imageSize > maxFileSize {
                showAlert(message: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                return
            } else {
                saveFile(with: imageData, fileName: fileName)
            }
        }
    }

    func processFileFromURL(_ fileURL: URL, fileName: String) {
        do {
            let imageData = try Data(contentsOf: fileURL)
            let fileSize = imageData.count
            let maxFileSize = 1 * 1024 * 1024 // 1 MB in bytes
            if fileSize > maxFileSize {
                showAlert(message: "The selected file size is more than 1 MB. Please select a smaller file.")
                return
            } else {
                saveFile(with: imageData, fileName: fileName)
            }
        } catch {
            showAlert(message: "Failed to read the file from URL.")
        }
    }

    func saveFile(with data: Data, fileName: String) {
        let name = (fileName as NSString).deletingPathExtension
        let newFileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
        let fileURL = documentDirectory().appendingPathComponent(newFileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                showAlert(message: "Please try again")
                return
            }
        }
        do {
            try data.write(to: fileURL, options: .atomic)
            self.selectedImageFile = fileURL
        } catch {
            showAlert(message: "Please try again")
            return
        }
    }

}

