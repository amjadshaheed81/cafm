//
//  SiteBasicDetailVC.swift
//  cafm
//
//  Created by Savan Lakhani on 24/08/24.
//

import UIKit
import Photos
import MapKit
import SCLAlertView
import SpreadsheetView
import ImageIO
import WebKit
import MobileCoreServices
import SVGKit
import PhotosUI

class SiteBasicDetailVC: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, WKNavigationDelegate, PHPickerViewControllerDelegate {
    
    //Basic setup
    @IBOutlet weak var properyDetailLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var actionBtnViewXIB: ActionBtnViewXIB!
    @IBOutlet weak var saveSiteActionBtnHeight: NSLayoutConstraint!
    
    //select profile image setup
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectImageMainView: UIView!
    @IBOutlet weak var selectSubViewHeight: NSLayoutConstraint!
    @IBOutlet weak var selectSubView: UIView!
    @IBOutlet weak var selectImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteBtnHeight: NSLayoutConstraint!
    
    //local detail setup
    @IBOutlet weak var localDetailMainViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var localDetailSubView: UIView!
    @IBOutlet weak var localDetailTxField1: TextFiledDataXib!
    @IBOutlet weak var localDetailCheckImage: UIImageView!
    @IBOutlet weak var localDetailActionBtn: ActionBtnViewXIB!
    @IBOutlet weak var localDetailTxField2: TextFiledDataXib!
    @IBOutlet weak var clientResponsibilityHeight: NSLayoutConstraint!
    @IBOutlet weak var localDetailBtnActionHeight: NSLayoutConstraint!
    
    //option main view setup
    @IBOutlet weak var optionTimeSubMainView: UIView!
    @IBOutlet weak var openMainViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var optionMainView: UIView!
    @IBOutlet weak var saveTimingActionBtn: ActionBtnViewXIB!
    @IBOutlet weak var optionTimeSubView: SpreadsheetView!
    @IBOutlet weak var saveTimingActionBtnHeight: NSLayoutConstraint!
    
    //map View setup
    @IBOutlet weak var mapviewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapView: UIView!

    //key contacts setup
    @IBOutlet weak var keyContactMainView: UIView!
    @IBOutlet weak var keyContactView: SpreadsheetView!
    @IBOutlet weak var keyContactViewHeight: NSLayoutConstraint!
    
    //add key contact
    @IBOutlet weak var addKeyContactMainView: UIView!
    @IBOutlet weak var addKeyContactMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var keyContactNameView: CustomTextField!
    @IBOutlet weak var keyContactPhoneView: CustomTextField!
    @IBOutlet weak var keyContactEmailView: CustomTextField!
    @IBOutlet weak var keyContactRoleView: OptionBtnXib!
    @IBOutlet weak var addRowBtn: UIButton!
    

    var filteredArray: [String] = []
    
    //search postcode setup
    var tableView: CustomTableView?
    var overlayView: UIView!
    
    var keyBoardHeight: CGFloat = 0.0
    
    //store api response detail
    var suggestionsResponse: SuggestionsResponse?
    var addressResponse: AddressResponse?
    var siteResponseModel: SiteResponseModel?
    var siteScheduleResponseModel: SiteScheduleResponseModel?
    var siteImageResponse: SiteImageResponse?
    let scheduleTimeModel = SiteScheduleRequestModel()

    var keyContactsDetailArray: [GetKeyContactsDetailResponse] = []
    
    //basic array details
    var keyContactArray: [String] = []
    let headerArray = ["Site Name", "Address Line 1", "Address Line 2", "City", "Area", "Post Code", "Country"]
    var keyContactsHeaderView: [String] = ["Name", "Phone", "Email", "Role"]
    var openingTime = ["Day", "Start Time", "End Time", "Is Closed"]
    var dayArray = ["Mon:","Tues:","wed:","Thurs:","Fri:","Sat:","Sun:"]
    let rolesArray = [
        "",
        "Admin Property Manager",
        "Site Action Manager",
        "Site users",
        "Care Taker",
        "Contracter",
        "Surveyor",
        "Tradesman",
        "Electrician",
        "Gas Engineer",
        "Asbestos Surveyor",
        "AC Engineer",
        "Fire Door Install",
        "General Company",
        "Life Maintenance",
        "Plumber",
        "Auto Door Maintenance",
        "Refuse Collector",
        "Fire Alarm",
        "Asbestos Surveyor"
    ]
    
    var statusArray = ["Open", "Closed", "Sold"]
    
    var openTimingDisableStateArray: [Int] = []
    
    weak var homeVC: CreateNewSiteVC?
    var isNeedToShowSiteDetails = false
    var isForViewOnly = false
        
    //opening time setup basic view
    var timePicker = UIPickerView()
    var selectedPickerIndexPath: IndexPath?
    let hours = Array(0...12)
    let minutes = Array(0...59)
    let amPm = ["AM", "PM"]
    
    let keyContatsTag = 20
            
    let mkMapView : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .light
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyBoardHeight = 0.0
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpForViewOnly()
        self.updateScrollViewHeight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.emptySiteDetails(isNeedToEmptyDetail: true)
    }
    
    func updateScrollViewHeight() {
        DispatchQueue.main.async {
            self.mainView.layoutIfNeeded()
            self.scrollView.contentSize = self.mainView.frame.size
        }
    }
    
    func setUpForViewOnly() {
        if self.isNeedToShowSiteDetails {
            self.emptySiteDetails(isNeedToEmptyDetail: true)
            self.setUpSiteResponse()
            self.setUpMapViewLatitudeLongitudeByURL()
            if let siteImageUrl = self.siteResponseModel?.siteImageUrl {
                self.reloadSiteImage(urlString: siteImageUrl)
            }
            self.collectionView.reloadData()
            self.getKeyContactsDetails()
            self.optionTimeSubView.reloadData()
            self.keyContactView.reloadData()
        }
    }
    
    func initialSetup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.emptySiteDetails(isNeedToEmptyDetail: !self.isNeedToShowSiteDetails)
        self.setUpSpreedSheetViewCell()
        self.setUpMapViewBasic()
        self.addCornetAndBorderToViews()
        self.setInitialHeightOfViews()
        self.setectImageViewSetup()
        self.setUpOverlayImage()
        self.setUpTimerPicker()
        self.setUpLocalDetails()
        self.properyDetailLbl.font = UIFont(name: .MontserratSemiBold, size: 19)
        
        self.actionBtnViewXIB.saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.actionBtnViewXIB.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        
        self.localDetailActionBtn.saveBtn.addTarget(self, action: #selector(localDetailSaveBtnTapped), for: .touchUpInside)
        self.localDetailActionBtn.cancelBtn.addTarget(self, action: #selector(localDetailCancelBtnTapped), for: .touchUpInside)
        
        self.saveTimingActionBtn.saveBtn.addTarget(self, action: #selector(saveTimingSaveBtnTapped), for: .touchUpInside)
        self.saveTimingActionBtn.cancelBtn.addTarget(self, action: #selector(saveTimingCancelBtnTapped), for: .touchUpInside)

    }
        
    func emptySiteDetails(isNeedToEmptyDetail: Bool = false) {
        // set emtpy site details
        if isNeedToEmptyDetail {
            createSiteName = ""
            createSiteAddressLine1 = ""
            createSiteAddressLine2 = ""
            createSiteCity = ""
            createSiteArea = ""
            createSitePostCode = ""
            createSiteCountry = ""
            keyContactsName = ""
            keyContactsEmail = ""
            keyContactsRole = ""
            keyContactsPhone = ""
        }
    }
    
    func setUpSiteResponse() {
        createSiteName = self.siteResponseModel?.siteName ?? ""
        createSiteAddressLine1 = self.siteResponseModel?.address1 ?? ""
        createSiteAddressLine2 = self.siteResponseModel?.address2 ?? ""
        createSiteCity = self.siteResponseModel?.city ?? ""
        createSiteArea = self.siteResponseModel?.area ?? ""
        createSitePostCode = self.siteResponseModel?.postCode ?? ""
        createSiteCountry = self.siteResponseModel?.country ?? ""
        self.siteResponseModel?.mapViewUrl = self.siteResponseModel?.mapViewUrl
        if self.isForViewOnly {
            self.localDetailTxField1.tfData.isEnabled = false
            self.localDetailTxField2.tfData.isEnabled = false
            self.saveSiteActionBtnHeight.constant = 0.0
            self.actionBtnViewXIB.isHidden = true
        }
        self.localDetailTxField1.tfData.text = self.siteResponseModel?.localAuthority
        if self.siteResponseModel?.localAuthority != "" {
            self.localDetailTxField2.tfData.text = self.siteResponseModel?.status
        }
        if self.siteResponseModel?.clientResponsiblity == true {
            self.localDetailCheckImage.image = UIImage(named: "check_image")
        }
        self.scheduleTimeModel.monStartTime = self.siteResponseModel?.monStartTime
        self.scheduleTimeModel.monEndTime = self.siteResponseModel?.monEndTime
        self.scheduleTimeModel.tuesStartTime = self.siteResponseModel?.tuesStartTime
        self.scheduleTimeModel.tuesEndTime = self.siteResponseModel?.tuesEndTime
        self.scheduleTimeModel.wedStartTime = self.siteResponseModel?.wedStartTime
        self.scheduleTimeModel.wedEndTime = self.siteResponseModel?.wedEndTime
        self.scheduleTimeModel.thurStartTime = self.siteResponseModel?.thurStartTime
        self.scheduleTimeModel.thurEndTime = self.siteResponseModel?.thurEndTime
        self.scheduleTimeModel.friEndTime = self.siteResponseModel?.friEndTime
        self.scheduleTimeModel.friStartTime = self.siteResponseModel?.friStartTime
        self.scheduleTimeModel.satStartTime = self.siteResponseModel?.satStartTime
        self.scheduleTimeModel.satEndTime = self.siteResponseModel?.satEndTime
        self.scheduleTimeModel.sunStartTime = self.siteResponseModel?.sunStartTime
        self.scheduleTimeModel.sunEndTime = self.siteResponseModel?.sunEndTime
        
        if !self.isForViewOnly && self.isNeedToShowSiteDetails {
            let closed = "Closed".lowercased()
            if self.scheduleTimeModel.monStartTime?.lowercased() == closed || self.scheduleTimeModel.monEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(1)
            }
            if self.scheduleTimeModel.tuesStartTime?.lowercased() == closed || self.scheduleTimeModel.tuesEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(2)
            }
            if self.scheduleTimeModel.wedStartTime?.lowercased() == closed || self.scheduleTimeModel.wedEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(3)
            }
            if self.scheduleTimeModel.thurStartTime?.lowercased() == closed || self.scheduleTimeModel.thurEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(4)
            }
            if self.scheduleTimeModel.friStartTime?.lowercased() == closed || self.scheduleTimeModel.friEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(5)
            }
            if self.scheduleTimeModel.satStartTime?.lowercased() == closed || self.scheduleTimeModel.satStartTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(6)
            }
            if self.scheduleTimeModel.sunStartTime?.lowercased() == closed || self.scheduleTimeModel.sunEndTime?.lowercased() == closed  {
                self.openTimingDisableStateArray.append(7)
            }
        }
    }
    
    func setUpLocalDetails() {
        self.localDetailTxField1.lblTFName.text = "Local Authority"
        self.localDetailTxField2.lblTFName.text = "Status"
        if !self.isNeedToShowSiteDetails {
            self.localDetailTxField2.menuBtn.isHidden = false
            self.localDetailTxField2.downArrow.isHidden = false
            self.localDetailTxField2.menuBtn.addTarget(self, action: #selector(localDetailMenuAction), for: .touchUpInside)
        }
    }
    
    func setUpDropDownMenu() {
        var actions = [UIAction]()
        for item in self.statusArray {
            actions.append(UIAction(title: item, state: self.localDetailTxField2.tfData.text == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.localDetailTxField2.tfData.text = item
                    setUpDropDownMenu()
                }
            }))
        }
        self.localDetailTxField2.menuBtn.menu = UIMenu(title: "", children: actions)
        self.localDetailTxField2.menuBtn.showsMenuAsPrimaryAction = true
    }
    
    @objc func handleLocalDetailSetup(_ sender: UIButton) {
        if let menu = sender.menu {
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
            sender.sendActions(for: .touchUpInside)
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
    
    func setectImageViewSetup() {
        self.selectedImageView.contentMode = .scaleAspectFill
        addCornerToView(self.selectImageMainView, value: 7)
        addBorderToView(self.selectImageMainView)
    }
    
    func setInitialHeightOfViews() {
        if !self.isNeedToShowSiteDetails {
            self.selectSubViewHeight.constant = 0.0
            self.keyContactViewHeight.constant = 0.0
            self.addKeyContactMainViewHeight.constant = 0.0
            self.openMainViewHeightCons.constant = 0.0
            self.localDetailMainViewHeightCons.constant = 0.0
            self.mapviewHeight.constant = 0.0
            self.saveTimingActionBtnHeight.constant = 0.0
            self.clientResponsibilityHeight.constant = 0.0
            self.localDetailBtnActionHeight.constant = 0.0
            self.selectImageViewHeight.constant = 0.0
            self.deleteBtnHeight.constant = 0.0
            self.optionTimeSubView.isHidden = true
            self.optionTimeSubMainView.isHidden = true
            self.keyContactView.isHidden = true
            self.keyContactMainView.isHidden = true
            self.addKeyContactMainView.isHidden = true
            self.localDetailSubView.isHidden = true
            self.localDetailTxField1.isHidden = true
            self.localDetailTxField2.isHidden = true
            self.selectImageMainView.isHidden = true
            self.deleteBtn.isHidden = true
            self.localDetailActionBtn.isHidden = true
            self.saveTimingActionBtn.isHidden = true
            self.mainView.frame.size.height = self.actionBtnViewXIB.frame.maxY + 10.0
            self.mainView.layoutIfNeeded()
            self.scrollView.layoutIfNeeded()
        }else {
            self.setAllBottomMainViewHeight()
        }
    }
    
    func setAllBottomMainViewHeight() {
        self.selectSubViewHeight.constant = !self.isForViewOnly ? 350.0 : 260.0
        self.clientResponsibilityHeight.constant = 45.0
        self.keyContactViewHeight.constant = 100.0
        self.addKeyContactMainViewHeight.constant = !self.isForViewOnly ? 280 : 0.0
        self.openMainViewHeightCons.constant = !self.isForViewOnly ? 568.0 : 530.0
        self.localDetailMainViewHeightCons.constant = 390.0
        self.saveTimingActionBtnHeight.constant = !self.isForViewOnly ? 45.0 : 0.0
        self.localDetailBtnActionHeight.constant = !self.isForViewOnly ? 45.0 : 0.0
        self.deleteBtnHeight.constant = 45.0
        self.selectImageViewHeight.constant = !self.isForViewOnly ? 90.0 : 0.0
        self.localDetailActionBtn.isHidden = !self.isForViewOnly ? false : true
        self.saveTimingActionBtn.isHidden = !self.isForViewOnly ? false : true
        self.deleteBtn.isHidden = false
        self.selectImageMainView.isHidden = !self.isForViewOnly ? false : true
        self.localDetailSubView.isHidden = false
        self.localDetailTxField1.isHidden = false
        self.localDetailTxField2.isHidden = false
        self.optionTimeSubView.isHidden = false
        self.optionTimeSubMainView.isHidden = false
        self.keyContactView.isHidden = false
        self.keyContactMainView.isHidden = false
        self.addKeyContactMainView.isHidden =  !self.isForViewOnly ? false : true
        self.mainView.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
    }
    
    func addCornetAndBorderToViews() {
        addCornerToView(self.mapView)
        addBorderToView(self.mapView, color: .gray.withAlphaComponent(0.7))
        addCornerToView(self.selectedImageView, value: self.selectedImageView.frame.size.width/2)
        addBorderToView(self.selectedImageView, color: .gray.withAlphaComponent(0.7))
        addCornerToView(self.deleteBtn, value: 6)
        addCornerToView(self.selectSubView)
        addBorderToView(self.selectSubView, color: .gray.withAlphaComponent(0.7))
        addCornerToView(self.localDetailSubView)
        addBorderToView(self.localDetailSubView, color: .gray.withAlphaComponent(0.7))
        self.keyContactView.addShadow()
        self.optionTimeSubView.addShadow()
        addCornerToView(self.keyContactView, value: 7)
        addCornerToView(self.keyContactMainView)
        addBorderToView(self.keyContactView, color: .gray.withAlphaComponent(0.7))
        addCornerToView(self.optionTimeSubView, value: 7)
        addCornerToView(self.optionTimeSubMainView, value: 7)
        addBorderToView(self.optionTimeSubMainView, color: .gray.withAlphaComponent(0.7))
    }
    
    func setUpMapViewBasic() {
        self.mapView.addSubview(mkMapView)
        self.mkMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mkMapView.topAnchor.constraint(equalTo: self.mapView.topAnchor),
            self.mkMapView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            self.mkMapView.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor),
            self.mkMapView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor)
        ])
        self.mapView.isHidden = true
        self.mapView.frame.size.height = 0.0
    }
    
    func setupKeyContactRoleMenu() {
        var actions: [UIMenuElement] = []
        for value in self.rolesArray {
            let action = UIAction(title: "\(value)", state: keyContactsRole == value ? .on : .off) { [weak self] _ in
                guard let strongSelf = self else { return }
                keyContactsRole = value
                if value.isEmpty {
                    strongSelf.keyContactRoleView.lblText.text = "Select Role"
                }else {
                    strongSelf.keyContactRoleView.lblText.text = value
                }
                strongSelf.setupKeyContactRoleMenu()
            }
            actions.append(action)
        }

        self.keyContactRoleView.btnDownClick.menu = UIMenu(children: actions)
        self.keyContactRoleView.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func resetKeyContactTextFields() {
        self.keyContactNameView.textField.text = ""
        self.keyContactPhoneView.textField.text = ""
        self.keyContactEmailView.textField.text = ""
        self.keyContactRoleView.lblText.text = "Select Role"
    }
    
    func setUpSpreedSheetViewCell() {
        if !self.isForViewOnly, keyContactsHeaderView.count <= 4, !self.keyContactsHeaderView.contains("") {
            self.keyContactsHeaderView.append("")
        }

        if self.isForViewOnly {
            let height = CGFloat.zero
            self.addKeyContactMainViewHeight.constant = height
            self.addKeyContactMainView.frame.size.height = height
            self.addKeyContactMainView.isHidden = true
        }else {
            let height: CGFloat = 280.0
            self.addKeyContactMainViewHeight.constant = height
            self.addKeyContactMainView.frame.size.height = height
            self.addKeyContactMainView.isHidden = false
            
            self.addRowBtn.addCorner()
            self.addRowBtn.addBorder(color: UIColor(appColor: .Separator2))
            self.addRowBtn.titleLabel?.font = UIFont(name: .MontserratRegular, size: 15)
            
            self.keyContactNameView.delegate = self
            self.keyContactNameView.textField.delegate = self
            self.keyContactNameView.textField.placeholder = "Enter Name"
            self.keyContactNameView.textField.tag = self.keyContatsTag + 0
            
            self.keyContactPhoneView.delegate = self
            self.keyContactPhoneView.textField.delegate = self
            self.keyContactPhoneView.textField.placeholder = "Enter Phone"
            self.keyContactPhoneView.textField.tag = self.keyContatsTag + 1
            
            self.keyContactEmailView.delegate = self
            self.keyContactEmailView.textField.delegate = self
            self.keyContactEmailView.textField.placeholder = "Enter Email"
            self.keyContactEmailView.textField.tag = self.keyContatsTag + 2
            
            self.keyContactRoleView.lblText.text = "Select Role"
            self.setupKeyContactRoleMenu()
        }
        
        self.keyContactView.dataSource = self
        self.keyContactView.delegate = self
        self.keyContactView.bounces = false
        self.keyContactView.showsVerticalScrollIndicator = false
        self.keyContactView.showsHorizontalScrollIndicator = false
        
        //register cell
        self.keyContactView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.keyContactView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        
        self.optionTimeSubView.dataSource = self
        self.optionTimeSubView.delegate = self
        self.optionTimeSubView.bounces = false
        self.optionTimeSubView.showsVerticalScrollIndicator = false
        self.optionTimeSubView.showsHorizontalScrollIndicator = false

        self.optionTimeSubView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        self.optionTimeSubView.register(UINib(nibName: String(describing: CreateSiteKeyContactXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CreateSiteKeyContactXIB.self))
        self.optionTimeSubView.register(UINib(nibName: String(describing: OpenSetTimingXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: OpenSetTimingXIB.self))
        self.optionTimeSubView.register(UINib(nibName: String(describing: CheckBoxXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CheckBoxXIB.self))
    }
    
    func setUpTimerPicker() {
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        self.timePicker.isHidden = true
        self.timePicker.backgroundColor = .white
        self.timePicker.addCorner(value: 8)
        self.timePicker.addBorder()
        self.timePicker.addShadow()
        self.view.addSubview(self.timePicker)
    }
            
    func showTableView() {
        self.overlayView.isHidden = false
        self.tableView?.isHidden = false
    }
    
    @objc func hideTableView() {
        self.overlayView.isHidden = true
        self.timePicker.isHidden = true
        self.tableView?.isHidden = true
        self.tableView?.hideTableView()
    }
    
    func reloadSiteImage(urlString: String, scl:SCLAlertView? = nil) {
        if let url = URL(string: urlString) {
            downloadAndSaveImage(from: url) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch result {
                    case .success(let image):
                        self.selectedImageView.image = image
                        if scl != nil {
                            scl?.hideView()
                            SCLAlertView().showSuccess("Success", subTitle: "Site Image has been uploaded successfully.")
                        }
                    case .failure(let error):
                        print("Error downloading the image: \(error)")
                    }
                }
            }
        }
    }
    
    func setUpMapViewLatitudeLongitudeByURL() {
        if let mapViewUrl = self.siteResponseModel?.mapViewUrl {
            if let coordinates = extractCoordinates(from: mapViewUrl) {
                self.mapView.isHidden = false
                self.mapviewHeight.constant = 235.0
                self.mapView.frame.size.height = 235.0

                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                
                self.mkMapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = "Location"
                self.mkMapView.addAnnotation(annotation)
            } else {
                self.mapviewHeight.constant = 0.0
                self.mapView.isHidden = true
            }
            self.updateScrollViewHeight()
        }else {
            self.mapviewHeight.constant = 0.0
            self.mapView.isHidden = true
        }
    }
    
    func setUpMapViewLatitudeLongitude() {
        if let addressResponse = self.addressResponse, let latitude = addressResponse.latitude, let longitude = addressResponse.longitude {
            self.mapView.isHidden = false
            self.mapviewHeight.constant = 235.0
            self.mapView.frame.size.height = 235.0
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // Set the region to display
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mkMapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Desired Location"
            mkMapView.addAnnotation(annotation)
            self.updateScrollViewHeight()
        }else {
            self.mapviewHeight.constant = 0.0
            self.mapView.isHidden = true
        }
    }
    
    @IBAction func selectImageTap(_ sender: Any) {
        self.presentPhotoPicker()
    }
    
    @IBAction func clientResponsibilityAction(_ sender: Any)  {
        guard !self.isForViewOnly else { return }
        if self.localDetailCheckImage.tag == 100 {
            self.localDetailCheckImage.image = UIImage(named: "check_image")
            self.localDetailCheckImage.tag = 101
        }else {
            self.localDetailCheckImage.image = UIImage(named: "un_check_image")
            self.localDetailCheckImage.tag = 100
        }
    }
    
    @IBAction func deleteImageTap(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        let apiService = ApiService.deleteSiteImage(userId: self.siteResponseModel?.siteId ?? 0)
        
        APIClient.requestDelete(apiService) { [weak self] isSucess in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                scl.hideView()
                if isSucess {
                    self.selectedImageView.image = UIImage(systemName: "person.circle")
                    self.selectedImageView.subviews.forEach { subview in
                        subview.removeFromSuperview()
                    }
                    scl.hideView()
                    SCLAlertView().showSuccess("Success", subTitle: "Site Image has been deleted successfully.")
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
        
    }
    
    @objc func localDetailSaveBtnTapped() {
        let request = UpdateCreateSiteLocalDetailsRequestModel()
        request.siteId = self.siteResponseModel?.siteId ?? 0
        request.clientResponsibility = self.localDetailCheckImage.tag == 101
        request.localAuthority = self.localDetailTxField1.tfData.text
        request.status = self.localDetailTxField2.tfData.text
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")

        let apiService = ApiService.updateLocalDetails(userModel: request)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<GetKeyContactsDetailResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                scl.hideView()
                SCLAlertView().showSuccess("Success", subTitle: "Local details has been updated successfully.")
            case .failure(let error):
                scl.hideView()
                SCLAlertView().showError("Error", subTitle: "something went wrong!!")
            }
        }
    }
    
    @objc func saveTimingSaveBtnTapped() {
        let request = self.scheduleTimeModel
        request.siteId = self.siteResponseModel?.siteId ?? 0
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")

        let apiService = ApiService.updateTimingAPI(userModel: request)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteScheduleResponseModel>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        scl.hideView()
                        self.siteScheduleResponseModel = responseResult
                        SCLAlertView().showSuccess("Success", subTitle: "Site Timings has been updated successfully.")
                    }
                case .failure(let error):
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "something went wrong!!")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func saveTimingCancelBtnTapped() {
        
    }
    
    @objc func localDetailCancelBtnTapped() {
        print("Cancel Pressed")
    }

    @objc func saveBtnTapped() {
        for sections in 0..<self.collectionView.numberOfSections {
            let indexPath = IndexPath(item: 0, section: sections)
            if let customCell = collectionView.cellForItem(at: indexPath) as? siteBasicDetailCollectionCell {
                if let textFields = customCell.txfiled {
                    if textFields.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                        if textFields.tag == 0 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your siteName.")
                        }else if textFields.tag == 1 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your address1.")
                        }else if textFields.tag == 2 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your address2.")
                        }else if textFields.tag == 3 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your city.")
                        }else if textFields.tag == 4 {
                            SCLAlertView().showError("Error", subTitle: "Please select your area.")
                        }else if textFields.tag == 5 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your postCode.")
                        }else if textFields.tag == 6 {
                            SCLAlertView().showError("Error", subTitle: "Please enter your country.")
                        }
                        return
                    }
                }
            }
        }
        self.createSiteDetails()
    }

    @objc func cancelBtnTapped() {
        print("Cancel Pressed")
    }
    
    @objc func localDetailMenuAction() {
        self.setUpDropDownMenu()
    }
    
    @IBAction func addRowToKeyContacts(_ sender: UIButton) {
        if keyContactsName == "" {
            SCLAlertView().showError("Error", subTitle: "Please enter your contacts.")
            return
        }else if keyContactsPhone == "" {
            SCLAlertView().showError("Error", subTitle: "Please enter your phone number.")
            return
        }else if keyContactsEmail == "" {
            SCLAlertView().showError("Error", subTitle: "Please enter your email.")
            return
        }else if keyContactsRole == "" {
            SCLAlertView().showError("Error", subTitle: "Please enter your contact role.")
            return
        }

        let model = UpdateKeyContactRequestModel()
        model.contactName = keyContactsName
        model.phone = keyContactsPhone
        model.email = keyContactsEmail
        model.actionManager = keyContactsRole.replacingOccurrences(of: " ", with: "").lowercased()
        model.siteId = self.siteResponseModel?.siteId ?? 0
        model.id = "-1"
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")

        let apiService = ApiService.updateKeyContactAPI(models: [model])
        
        APIClient.requestWithArray(apiService, parameters: [model].toJSON()) { [weak self] isSucess, code in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if isSucess {
                    keyContactsName = ""
                    keyContactsPhone = ""
                    keyContactsEmail = ""
                    keyContactsRole = ""
                    strongSelf.resetKeyContactTextFields()
                    strongSelf.getKeyContactsDetails(scl: scl)
                }else {
                    scl.hideView()
                }
            }
        }
    }
    
    func getKeyContactsDetails(scl: SCLAlertView? = nil) {
        guard let siteID = self.siteResponseModel?.siteId else {
            scl?.hideView()
            SCLAlertView().showSuccess("Success", subTitle: "Site has been added successfully.")
            return
        }
        
        let apiService = ApiService.getKeyContactsDetail(userId: siteID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<GetKeyContactsDetailResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let responseResult) = responseResult {
                    scl?.hideView()
                    self?.keyContactsDetailArray = responseResult
                    if !(self?.isNeedToShowSiteDetails ?? false) {
                        SCLAlertView().showSuccess("Success", subTitle: "Site has been added successfully.")
                    }
                }else {
                    if case .single(let responseResult) = responseResult {
                        scl?.hideView()
                        self?.keyContactsDetailArray = []
                        self?.keyContactsDetailArray.append(responseResult)
                        if !(self?.isNeedToShowSiteDetails ?? false) {
                            SCLAlertView().showSuccess("Success", subTitle: "Site has been added successfully.")
                        }
                    }
                }
                self?.reloadKeyContactsSpreadSheetView()
            case .failure(let error):
                scl?.hideView()
                if !(self?.isNeedToShowSiteDetails ?? false) {
                    SCLAlertView().showError("Error", subTitle: "something went wrong!!")
                }
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func reloadKeyContactsSpreadSheetView() {
        self.keyContactView.reloadData()
        
        let height = self.keyContactView.contentSize.height
        self.keyContactViewHeight.constant = height
        self.keyContactView.frame.size.height = height
    }
    
    func deleteKeyContactsRow(id: Int) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        let apiService = ApiService.deletekeyContacts(id: id)
        APIClient.requestDelete(apiService) { [weak self] isSucess in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                scl.hideView()
                if isSucess {
                    scl.hideView()
                    strongSelf.getKeyContactsDetails()
                    SCLAlertView().showSuccess("Success", subTitle: "Key contact has been deleted succesfully.")
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    func createSiteDetails() {
        let request = CreateSiteRequestModel()
        request.siteId = self.siteResponseModel?.siteId
        
        for sections in 0..<self.collectionView.numberOfSections {
            let indexPath = IndexPath(item: 0, section: sections)
            if let customCell = collectionView.cellForItem(at: indexPath) as? siteBasicDetailCollectionCell {
                if let textFields = customCell.txfiled {
                    if textFields.tag == 0 {
                        request.siteName = textFields.text
                    }else if textFields.tag == 1 {
                        request.address1 = textFields.text
                    }else if textFields.tag == 2 {
                        request.address2 = textFields.text
                    }else if textFields.tag == 3 {
                        request.city = textFields.text
                    }else if textFields.tag == 4 {
                        request.area = textFields.text
                    }else if textFields.tag == 5 {
                        request.postCode = textFields.text
                    }else if textFields.tag == 6 {
                        request.country = textFields.text
                    }
                }
            }
        }
        
        let centerCoordinate = mkMapView.region.center
        request.latitude = centerCoordinate.latitude
        request.longitude = centerCoordinate.longitude
        request.mapViewUrl = "http://maps.google.com/maps?q=\(centerCoordinate.latitude),\(centerCoordinate.longitude)"
        request.streetViewUrl = request.mapViewUrl
        
        if self.localDetailTxField2.tfData.text == "" {
            request.status = "Open"
        }else {
            request.status = self.localDetailTxField2.tfData.text
        }

        request.clientResponsibility = "\(self.localDetailCheckImage.tag == 101)"
        request.localAuthority = self.localDetailTxField1.tfData.text
        
        request.monStartTime = self.siteScheduleResponseModel?.monStartTime
        request.monEndTime = self.siteScheduleResponseModel?.monEndTime
        request.tuesStartTime = self.siteScheduleResponseModel?.tuesStartTime
        request.tuesEndTime = self.siteScheduleResponseModel?.tuesEndTime
        request.wedStartTime = self.siteScheduleResponseModel?.wedStartTime
        request.wedEndTime = self.siteScheduleResponseModel?.wedEndTime
        request.thurStartTime = self.siteScheduleResponseModel?.thurStartTime
        request.thurEndTime = self.siteScheduleResponseModel?.thurEndTime
        request.friStartTime = self.siteScheduleResponseModel?.friStartTime
        request.friEndTime = self.siteScheduleResponseModel?.friEndTime
        request.sunStartTime = self.siteScheduleResponseModel?.sunStartTime
        request.sunEndTime = self.siteScheduleResponseModel?.sunEndTime
        request.satStartTime = self.siteScheduleResponseModel?.sunStartTime
        request.satEndTime = self.siteScheduleResponseModel?.sunEndTime
        
        request.siteImageUrl = self.siteImageResponse?.url ?? ""
        request.siteImage = self.siteImageResponse?.url ?? ""
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        let createSiteApiService = ApiService.createSite(userModel: request)
        let updateSiteApiService = ApiService.updateSite(userModel: request)
        
        var siteInfoMessage = request.siteId == nil ? "Site has been created successfully." : "Site has been updated successfully."
        
        APIClient.request(request.siteId == nil ? createSiteApiService : updateSiteApiService) { [weak self] (result: Result<APIClient.MappableResult<SiteResponseModel>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        DispatchQueue.main.async {
                            SCLAlertView().showSuccess("Success", subTitle: siteInfoMessage)
                            self.siteResponseModel = responseResult
                            self.setAllBottomMainViewHeight()
                            self.updateScrollViewHeight()
                            self.reloadKeyContactCollection()
                            self.enableHomeVCTabs()
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func reloadKeyContactCollection() {
        DispatchQueue.main.async {
            self.keyContactView.reloadData()
            self.optionTimeSubView.reloadData()
        }
    }
    
    func enableHomeVCTabs() {
        if let homeVC = self.homeVC {
            homeVC.collectionView.reloadData()
        }
    }
    
    @objc func deleteKeyContact(_ sender: ActionButton) {
        let index = sender.tag
        if self.keyContactsDetailArray.count > index {
            let item = self.keyContactsDetailArray[index]
            if let id = item.id {
                self.deleteKeyContactsRow(id: id)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

extension SiteBasicDetailVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if spreadsheetView == self.optionTimeSubView {
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = self.headerArray
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }
            return 60.0
        }else {
            if row == 0 {
                return 40.0
            }else {
                return 60.0
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if spreadsheetView == self.optionTimeSubView {
            return column == 0 ? 100.0 : isiPadDevice ? isForViewOnly ? (screenWidth - 100)/2 : (screenWidth - 100)/3 : 200
        }else {
            if column == 0 || column == 2 {
                return 330.0
            }else if column == 1 || column == 3 {
                return 250.0
            }else {
                return 60.0
            }
        }
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == self.optionTimeSubView {
            return (self.isForViewOnly && self.isNeedToShowSiteDetails) ? 3 : 4
        }
        return self.keyContactsHeaderView.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == self.optionTimeSubView {
            return 8
        }else if spreadsheetView == self.keyContactView {
            if self.keyContactsDetailArray.isEmpty {
                return 1+1
            }else {
                return self.keyContactsDetailArray.count+1
            }
        }
        return 0
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        let totalColumn = self.keyContactsHeaderView.count
        if spreadsheetView == self.keyContactView {
            if self.keyContactsDetailArray.isEmpty {
                return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
            }
        }
        return []
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if spreadsheetView == self.optionTimeSubView {
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
                cell.lblText.text = self.openingTime[indexPath.column]
                
                if cell.lblText.text?.lowercased() == "Is Closed".lowercased() {
                    cell.lblText.textAlignment = .center
                }
                cell.setNeedsLayout()
                return cell
            }else {
                if indexPath.column > 0 && indexPath.column < 3 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "OpenSetTimingXIB", for: indexPath) as! OpenSetTimingXIB
                    cell.gridlines.top = .none
                    cell.gridlines.bottom = .none
                    cell.gridlines.left = .none
                    cell.gridlines.right = .none
                    cell.clockImg.isHidden = false
                    cell.mainView.backgroundColor = .white
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDatePicker(_:)))
                    cell.actionBtn.addGestureRecognizer(tapGesture)
                    cell.actionBtn.tag = indexPath.column
                    if !self.openTimingDisableStateArray.isEmpty {
                        if self.openTimingDisableStateArray.contains(indexPath.row) {
                            cell.mainView.backgroundColor = .gray.withAlphaComponent(0.3)
                            cell.clockImg.isHidden = true
                        }
                        if indexPath.row == 1 {
                            if self.openTimingDisableStateArray.contains(1) {
                                self.scheduleTimeModel.monStartTime = "Closed"
                                self.scheduleTimeModel.monEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.monStartTime = ""
                                self.scheduleTimeModel.monEndTime = ""
                            }
                        }else if indexPath.row == 2 {
                            if self.openTimingDisableStateArray.contains(2) {
                                self.scheduleTimeModel.tuesStartTime = "Closed"
                                self.scheduleTimeModel.tuesEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.tuesStartTime = ""
                                self.scheduleTimeModel.tuesEndTime = ""
                            }
                        }else if indexPath.row == 3 {
                            if self.openTimingDisableStateArray.contains(3) {
                                self.scheduleTimeModel.wedStartTime = "Closed"
                                self.scheduleTimeModel.wedEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.wedStartTime = ""
                                self.scheduleTimeModel.wedEndTime = ""
                            }
                        }else if indexPath.row == 4 {
                            if self.openTimingDisableStateArray.contains(4) {
                                self.scheduleTimeModel.thurStartTime = "Closed"
                                self.scheduleTimeModel.thurEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.thurStartTime = ""
                                self.scheduleTimeModel.thurEndTime = ""
                            }
                        }else if indexPath.row == 5 {
                            if self.openTimingDisableStateArray.contains(5) {
                                self.scheduleTimeModel.friStartTime = "Closed"
                                self.scheduleTimeModel.friEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.friStartTime = ""
                                self.scheduleTimeModel.friEndTime = ""
                            }
                        }else if indexPath.row == 6 {
                            if self.openTimingDisableStateArray.contains(6) {
                                self.scheduleTimeModel.satStartTime = "Closed"
                                self.scheduleTimeModel.satEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.satStartTime = ""
                                self.scheduleTimeModel.satEndTime = ""
                            }
                        }else if indexPath.row == 7 {
                            if self.openTimingDisableStateArray.contains(7) {
                                self.scheduleTimeModel.sunStartTime = "Closed"
                                self.scheduleTimeModel.sunEndTime = "Closed"
                            }else if !self.isNeedToShowSiteDetails {
                                self.scheduleTimeModel.sunStartTime = ""
                                self.scheduleTimeModel.sunEndTime = ""
                            }
                        }
                        if indexPath.row == 1 {
                            if indexPath.column == 1, self.scheduleTimeModel.monStartTime != "", self.scheduleTimeModel.monStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.monStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.monEndTime != "", self.scheduleTimeModel.monEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.monEndTime
                            }
                        }else if indexPath.row == 2 {
                            if indexPath.column == 1, self.scheduleTimeModel.tuesStartTime != "", self.scheduleTimeModel.tuesStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.tuesStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.tuesEndTime != "", self.scheduleTimeModel.tuesEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.tuesEndTime
                            }
                        }else if indexPath.row == 3 {
                            if indexPath.column == 1, self.scheduleTimeModel.wedStartTime != "", self.scheduleTimeModel.wedStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.wedStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.wedEndTime != "", self.scheduleTimeModel.wedEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.wedEndTime
                            }
                        }else if indexPath.row == 4 {
                            if indexPath.column == 1, self.scheduleTimeModel.thurStartTime != "", self.scheduleTimeModel.thurStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.thurStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.thurEndTime != "", self.scheduleTimeModel.thurEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.thurEndTime
                            }
                        }else if indexPath.row == 5 {
                            if indexPath.column == 1, self.scheduleTimeModel.friStartTime != "", self.scheduleTimeModel.friStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.friStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.friEndTime != "", self.scheduleTimeModel.friEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.friEndTime
                            }
                        }else if indexPath.row == 6 {
                            if indexPath.column == 1, self.scheduleTimeModel.satStartTime != "", self.scheduleTimeModel.satStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.satStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.satEndTime != "", self.scheduleTimeModel.satEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.satEndTime
                            }
                        }else if indexPath.row == 7 {
                            if indexPath.column == 1, self.scheduleTimeModel.sunStartTime != "", self.scheduleTimeModel.sunStartTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.sunStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.sunEndTime != "", self.scheduleTimeModel.sunEndTime != "Closed" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.sunEndTime
                            }
                        }
                        return cell
                    }else {
                        if self.openTimingDisableStateArray.isEmpty, !self.isForViewOnly {
                            cell.timeDetailLbl.text = "--:-- --"
                            return cell
                        }
                        if indexPath.row == 1 {
                            if indexPath.column == 1, self.scheduleTimeModel.monStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.monStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.monEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.monEndTime
                            }
                        }else if indexPath.row == 2 {
                            if indexPath.column == 1, self.scheduleTimeModel.tuesStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.tuesStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.tuesEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.tuesEndTime
                            }
                        }else if indexPath.row == 3 {
                            if indexPath.column == 1, self.scheduleTimeModel.wedStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.wedStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.wedEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.wedEndTime
                            }
                        }else if indexPath.row == 4 {
                            if indexPath.column == 1, self.scheduleTimeModel.thurStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.thurStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.thurEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.thurEndTime
                            }
                        }else if indexPath.row == 5 {
                            if indexPath.column == 1, self.scheduleTimeModel.friStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.friStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.friEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.friEndTime
                            }
                        }else if indexPath.row == 6 {
                            if indexPath.column == 1, self.scheduleTimeModel.satStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.satStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.satEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.satEndTime
                            }
                        }else if indexPath.row == 7 {
                            if indexPath.column == 1, self.scheduleTimeModel.sunStartTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.sunStartTime
                            }else if indexPath.column == 2, self.scheduleTimeModel.sunEndTime != "" {
                                cell.timeDetailLbl.text = self.scheduleTimeModel.sunEndTime
                            }
                        }
                        if self.isForViewOnly {
                            cell.clockImg.isHidden = true
                        }
                        return cell
                    }
                }else if indexPath.column == 3 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.gridlines.top = .none
                    cell.gridlines.bottom = .none
                    cell.gridlines.left = .none
                    cell.gridlines.right = .none
                    if !self.openTimingDisableStateArray.isEmpty {
                        if self.openTimingDisableStateArray.contains(indexPath.row) {
                            cell.checkImageView.image = UIImage(named: "check_image")
                        }else {
                            cell.checkImageView.image = UIImage(named: "un_check_image")
                        }
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setStateOfTimingDate(_:)))
                    cell.addGestureRecognizer(tapGesture)
                    cell.tag = indexPath.row
                    return cell
                }
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.lblText.textColor = .black
                cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
                cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
                cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
                cell.backgroundColor = .white
                cell.lblText.font = UIFont(name: .MontserratMedium, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = self.dayArray[indexPath.row-1]
                cell.gridlines.top = .none
                cell.gridlines.bottom = .none
                cell.gridlines.left = .none
                cell.gridlines.right = .none
                cell.setNeedsLayout()
                return cell
            }
        }else if spreadsheetView == self.keyContactView {
            let column = indexPath.section
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
                
                if self.keyContactsHeaderView.count > column {
                    let headerText = self.keyContactsHeaderView[column]
                    
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.white
                    
                    cell.mainLbl.text = headerText
                }
                return cell
            }else {
                if self.keyContactsDetailArray.isEmpty && indexPath.row == 1 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setBottomGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    cell.mainLbl.text = "No Contacts found!!"
                    return cell
                }else {
                    let row = indexPath.row-1
                    if column == 4 {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                        cell.setBottomGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        
                        cell.stackView.arrangedSubviews.forEach { view in
                            cell.stackView.removeArrangedSubview(view)
                            view.removeFromSuperview()
                        }
                        
                        let refHeight = cell.stackView.frame.height
                        let deleteBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: row, image: UIImage(systemName: "trash.fill"), target: self, action: #selector(self.deleteKeyContact(_:)))
                        cell.stackView.addArrangedSubview(deleteBtn)
                        return cell
                    }else {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                        cell.setBottomGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        
                        cell.backgroundColor = UIColor.white
                        cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                        cell.mainLbl.textColor = UIColor.black
                        
                        if self.keyContactsDetailArray.count > row {
                            let item = self.keyContactsDetailArray[row]
                            if column == 0 {
                                cell.mainLbl.text = item.contactName
                            }else if column == 1 {
                                cell.mainLbl.text = item.phone
                            }else if column == 2 {
                                cell.mainLbl.text = item.email
                            }else if column == 3 {
                                cell.mainLbl.text = item.actionManager
                            }else {
                                cell.mainLbl.text = ""
                            }
                        }
                        return cell
                    }
                }
            }
        }
        return nil
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        print(indexPath.column)
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == self.optionTimeSubView {
            return 1
        }
        return 0
    }
    
}

extension SiteBasicDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "siteBasicDetailCollectionCell", for: indexPath) as! siteBasicDetailCollectionCell
        cell.txfiled.isEnabled = !self.isForViewOnly
        cell.selectedButton.isEnabled = !self.isForViewOnly
        cell.txfiled.font = UIFont(name: .MontserratMedium, size: 16)
        cell.selectedButton.titleLabel?.font = UIFont(name: .MontserratMedium, size: 16)
        if cell.selectedButton.titleLabel?.text == "Select" {
            cell.selectedButton.setTitleColor(UIColor.gray, for: .normal)
        }
        cell.imageViewWidthCons.constant = indexPath.section != 0 ? 0.0 : 40.0
        cell.selectedButton.isHidden = !(indexPath.section == 4)
        cell.downArrow.isHidden = !(indexPath.section == 4)
        cell.buildingImageView.isHidden = !(indexPath.section == 0)
        addCornerToView(cell.mainView, value: 7)
        addBorderToView(cell.mainView, color: .gray)
        cell.txfiled.tag = indexPath.section
        cell.txfiled.delegate = self
        cell.txfiled.textColor = indexPath.row == 4 ? .clear : .black
        if indexPath.section == 0 {
            cell.txfiled.text = createSiteName
        }else if indexPath.section == 1 {
            cell.txfiled.text = self.addressResponse?.line1 ?? createSiteAddressLine1
        }else if indexPath.section == 2 {
            cell.txfiled.text = self.addressResponse?.line2 ?? createSiteAddressLine2
        }else if indexPath.section == 3 {
            cell.txfiled.text = self.addressResponse?.townOrCity ?? createSiteCity
        }else if indexPath.section == 4 {
            if createSiteArea != "" {
                cell.txfiled.text = createSiteArea
                cell.selectedButton.setTitle("", for: .normal)
            }else {
                cell.selectedButton.setTitle("Select", for: .normal)
            }
        }else if indexPath.section == 5 {
            cell.txfiled.text = self.addressResponse?.postcode ?? createSitePostCode
            cell.txfiled.placeholder = "Search Post Code"
        }else if indexPath.section == 6 {
            cell.txfiled.text = self.addressResponse?.county ?? createSiteCountry
        }else {
            cell.txfiled.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "siteBasicDetailHeaderCollectionCell", for: indexPath) as! siteBasicDetailHeaderCollectionCell
        cell.headerLbl.text = self.headerArray[indexPath.section]
        cell.headerLbl.font = UIFont(name: .MontserratMedium, size: 16)
        cell.headerLbl.textColor = UIColor.black
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 20)
    }
    
}

//set profile image setup
extension SiteBasicDetailVC : UIImagePickerControllerDelegate {
    
    @objc func selectPhoto() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.showSelectionPopup()
        case .denied, .restricted:
            let alert = UIAlertController(title: "Access Denied", message: "Please allow access to photo library in settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self?.presentPhotoPicker()
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images // This ensures only images are shown
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                if let pickedImage = image as? UIImage {
                    // Fetch the asset associated with the picked image
                    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                            guard let fileURL = url else {
                                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                guard let self else {return}
                                showAlert(vc: self, message: "Please try again")
                                return
                            }
                            // Process the image here as needed
                            DispatchQueue.main.async {
                                self?.handlePickedImage(pickedImage, fromURL: fileURL)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handlePickedImage(_ pickedImage: UIImage, fromURL fileURL: URL) {
        // Implement the logic you had for handling a single image
        // Fetch the file name from the URL
        let fileName = fileURL.lastPathComponent
        print("Selected image name: \(fileName)")
        
        // Check the image size and proceed similarly to your original code
        if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
            let imageSize = imageData.count
            let maxFileSize = 1 * 1024 * 1024 // 1 MB in bytes
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if imageSize > maxFileSize {
                    // Image size exceeds 1 MB, show an alert
                    showAlert(vc: self, message: "The selected image size is more than 1 MB. Please select a smaller image.")
                } else {
                    print("Image size is within the limit: \(imageSize) bytes")
                    let name = (fileName as NSString).deletingPathExtension
                    let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                    let fileURL = documentDirectory().appendingPathComponent(newfileName)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            showAlert(vc: self,message: "Please try again")
                            return
                        }
                    }
                    do {
                        try imageData.write(to: fileURL, options: .atomic)
                        self.uploadSiteImageDetail(from: fileURL)
                    } catch {
                        showAlert(vc: self,message: "Please try again")
                        print("Error saving image: \(error)")
                    }
                }
            }
        }
    }

    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let asset = info[.phAsset] as? PHAsset {
                if let fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename {
                    print("Selected image name: \(fileName)")
                    
                    print("Selected the correct image!")
                    if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                        let imageSize = imageData.count
                        let maxFileSize = 1 * 1024 * 1024 // 1 MB in bytes
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            if imageSize > maxFileSize {
                                showAlert(vc: self, message: "The selected image size is more than 1 MB. Please select a smaller image.")
                            } else {
                                print("Image size is within the limit: \(imageSize) bytes")
                                let name = (fileName as NSString).deletingPathExtension
                                let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                                let fileURL = documentDirectory().appendingPathComponent(newfileName)
                                if FileManager.default.fileExists(atPath: fileURL.path) {
                                    do {
                                        try FileManager.default.removeItem(at: fileURL)
                                    } catch {
                                        showAlert(vc: self,message: "Please try again")
                                        return
                                    }
                                }
                                do {
                                    try imageData.write(to: fileURL, options: .atomic)
                                    self.uploadSiteImageDetail(from: fileURL)
                                } catch {
                                    showAlert(vc: self,message: "Please try again")
                                    print("Error saving image: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SiteBasicDetailVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.hideTableView()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)

        if textField.tag == 0 {
            createSiteName = updatedText
        }else if textField.tag == 1 {
            createSiteAddressLine1 = updatedText
        }else if textField.tag == 2 {
            createSiteAddressLine2 = updatedText
        }else if textField.tag == 3 {
            createSiteCity = updatedText
        }else if textField.tag == 4 {
            createSiteArea = updatedText
        }else if textField.tag == 5 {
            createSitePostCode = updatedText
            let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            
            // API Call to update filteredArray
            searchResultAPI(with: searchText) { [weak self] newResults in
                guard let self = self else { return }
                self.filteredArray = []
                self.filteredArray = newResults
                self.updateTableView(below: textField)
            }
        }else if textField.tag == 6 {
            createSiteCountry = updatedText
        }else if textField.tag == self.keyContatsTag + 0 { //key contacts name
            keyContactsName = textField.text ?? ""
        }else if textField.tag == self.keyContatsTag + 1 { //key contacts phone setup
            let maxLength = 10
            if updatedText.count <= maxLength {
                keyContactsPhone = currentText
            }
            return updatedText.count <= maxLength
        }else if textField.tag == self.keyContatsTag + 2 { //key contacts email setup
            keyContactsEmail = updatedText
        }
        return true
    }
    
    func searchResultAPI(with query: String, completion: @escaping ([String]) -> Void) {
        let apiService = ApiService.getSearchAddressAPI(searchText: query)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SuggestionsResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let responseResult) = responseResult {
                    guard let self = self else { return }
                    let address: [String] = responseResult.suggestions?
                        .compactMap { $0.address }
                        .filter { !$0.isEmpty }
                        ?? []
                    self.suggestionsResponse = responseResult
                    return completion(address)
                }
            case .failure(let error):
                self?.suggestionsResponse = nil
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getSearchResultAPI(with query: String) {
        let apiService = ApiService.getSearchResultAddressAPI(searchText: query)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AddressResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let responseResult) = responseResult {
                    guard let self = self else { return }
                    self.addressResponse = responseResult
                    self.collectionView.reloadData()
                    self.setUpMapViewLatitudeLongitude()
                }
            case .failure(let error):
                self?.addressResponse = nil
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateTableView(below textField: UITextField) {
        showTableView()
        if self.tableView == nil {
            self.tableView = CustomTableView()
        }

        // Safely find the cell containing the text field
        if let cell = textField.superview?.superview?.superview as? UICollectionViewCell {
            let cellFrame = self.collectionView.convert(cell.frame, to: view)
            let textFieldFrame = textField.convert(textField.bounds, to: view)

            // Calculate available space below and above the text field
            let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
            let availableSpaceAboveTextField = textFieldFrame.minY - 10 // Padding of 10

            // Calculate the desired height for the tableView
            let desiredTableViewHeight = CGFloat(filteredArray.count > 5 ? (5 * 40) + 20 : filteredArray.count * 40)

            // Determine whether to show the table view below or above the text field
            if desiredTableViewHeight <= availableSpaceBelowTextField {
                // Show the tableView below the text field
                self.tableView?.frame = CGRect(x: textFieldFrame.minX,
                                               y: textFieldFrame.maxY + 5, // Small gap below the text field
                                               width: textFieldFrame.width,
                                               height: desiredTableViewHeight)
            } else if desiredTableViewHeight <= availableSpaceAboveTextField {
                // Show the tableView above the text field
                self.tableView?.frame = CGRect(x: textFieldFrame.minX,
                                               y: textFieldFrame.minY - desiredTableViewHeight - 5, // Small gap above the text field
                                               width: textFieldFrame.width,
                                               height: desiredTableViewHeight)
            } else {
                // Show the tableView with maximum available space below or above
                if availableSpaceBelowTextField >= availableSpaceAboveTextField {
                    // Show the tableView below, but limit its height to the available space
                    let tableViewHeight = min(desiredTableViewHeight, availableSpaceBelowTextField)
                    self.tableView?.frame = CGRect(x: textFieldFrame.minX,
                                                   y: textFieldFrame.maxY + 5,
                                                   width: textFieldFrame.width,
                                                   height: tableViewHeight)
                } else {
                    // Show the tableView above, but limit its height to the available space
                    let tableViewHeight = min(desiredTableViewHeight, availableSpaceAboveTextField)
                    self.tableView?.frame = CGRect(x: textFieldFrame.minX,
                                                   y: textFieldFrame.minY - tableViewHeight - 5,
                                                   width: textFieldFrame.width,
                                                   height: tableViewHeight)
                }
            }

            self.tableView?.isHidden = filteredArray.isEmpty
            self.tableView?.filteredArray = filteredArray
            self.tableView?.showTableView(with: filteredArray)
            view.addSubview(self.tableView!)

            self.tableView?.didSelectItem = { selectedItem in
                print("Selected item: \(selectedItem)")
                if let suggestionsResponse = self.suggestionsResponse?.suggestions {
                    if let suggestion = suggestionsResponse.first(where: { $0.address?.lowercased() == selectedItem.lowercased() }) {
                        self.getSearchResultAPI(with: suggestion.id ?? "")
                    }
                }
            }
        } else {
            print("Error: Could not find the UICollectionViewCell containing the text field.")
        }
    }
    
}

//open timing set time setup
extension SiteBasicDetailVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        case 2:
            return amPm.count
        default:
            return 0
        }
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(hours[row])"
        case 1:
            return String(format: "%02d", minutes[row])
        case 2:
            return amPm[row]
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = selectedPickerIndexPath,
              let cell = self.optionTimeSubView.cellForItem(at: indexPath) as? OpenSetTimingXIB else { return }

        let selectedHour = hours[pickerView.selectedRow(inComponent: 0)]
        let selectedMinute = String(format: "%02d", minutes[pickerView.selectedRow(inComponent: 1)])
        let selectedAmPm = amPm[pickerView.selectedRow(inComponent: 2)]

        cell.timeDetailLbl.text = "\(selectedHour):\(selectedMinute) \(selectedAmPm)"
        self.timePicker.isHidden = true
        self.overlayView.isHidden = true
        
        if indexPath.row == 1 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.monStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.monEndTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 2 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.tuesStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.tuesEndTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 3 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.wedStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.wedStartTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 4 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.thurStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.thurEndTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 5 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.friStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.friEndTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 6 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.satStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.satEndTime = cell.timeDetailLbl.text
            }
        }else if indexPath.row == 7 {
            if indexPath.column == 1 {
                self.scheduleTimeModel.sunStartTime = cell.timeDetailLbl.text
            }else if indexPath.column == 2 {
                self.scheduleTimeModel.sunEndTime = cell.timeDetailLbl.text
            }
        }
    }

    @objc func handleDatePicker(_ sender: UITapGestureRecognizer) {
        guard !self.isForViewOnly else { return }
        guard let actionButton = sender.view as? UIButton else { return }

        let point = actionButton.convert(actionButton.bounds.origin, to: self.optionTimeSubView)
        if let indexPath = self.optionTimeSubView.indexPathForItem(at: point) {
            guard !self.openTimingDisableStateArray.contains(indexPath.row) else { return  }
            self.selectedPickerIndexPath = indexPath
            let buttonFrame = actionButton.convert(actionButton.bounds, to: self.view)

            self.timePicker.frame = CGRect(x: buttonFrame.origin.x - 10, y: buttonFrame.maxY + 5, width: buttonFrame.width + 20, height: 200)
            self.timePicker.isHidden = false
            self.overlayView.isHidden = false
        }
    }
    
    @objc func setStateOfTimingDate(_ sender: UITapGestureRecognizer) {
        guard !self.isForViewOnly else { return }
        guard let checkBoxXIB = sender.view as? CheckBoxXIB else { return }
        if checkBoxXIB.checkImageView.image == UIImage(named: "un_check_image") {
            self.openTimingDisableStateArray.append(checkBoxXIB.tag)
        }else {
            if let index = self.openTimingDisableStateArray.firstIndex(where: { $0 ==  checkBoxXIB.tag }) {
                self.openTimingDisableStateArray.remove(at: index)
            }
        }
        if !self.openTimingDisableStateArray.isEmpty {
            self.scheduleTimeModel.monStartTime = ""
            self.scheduleTimeModel.monEndTime = ""

            self.scheduleTimeModel.tuesStartTime = ""
            self.scheduleTimeModel.tuesEndTime = ""

            self.scheduleTimeModel.wedStartTime = ""
            self.scheduleTimeModel.wedEndTime = ""

            self.scheduleTimeModel.thurStartTime = ""
            self.scheduleTimeModel.thurEndTime = ""

            self.scheduleTimeModel.friStartTime = ""
            self.scheduleTimeModel.friEndTime = ""

            self.scheduleTimeModel.satStartTime = ""
            self.scheduleTimeModel.satEndTime = ""

            self.scheduleTimeModel.sunStartTime = ""
            self.scheduleTimeModel.sunEndTime = ""

        }
        self.optionTimeSubView.reloadData()
    }

}

extension SiteBasicDetailVC: UIDocumentPickerDelegate { //site image setup
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        handleFile(selectedFileURL)
    }
    
    func handleFile(_ fileURL: URL) {
        let fileExtension = fileURL.pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg", "png":
            displayImage(from: fileURL)
        case "svg":
            displaySVG(from: fileURL)
        case "gif":
            displayGIF(from: fileURL)
        default:
            break
        }
    }
    
    func displayImage(from url: URL) {
        if let image = UIImage(contentsOfFile: url.path) {
            self.selectedImageView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
        }

        self.uploadSiteImageDetail(from: url)
    }
    
    func displayGIF(from url: URL) {
        let webView = WKWebView(frame: self.selectedImageView.bounds)
        webView.contentMode = .scaleAspectFit
        let request = URLRequest(url: url)
        webView.load(request)
        self.selectedImageView.image = nil
        self.selectedImageView.addSubview(webView)
        self.uploadSiteImageDetail(from: url)
    }
    
    func displaySVG(from url: URL) {
        let svgImage = SVGKImage(contentsOf: url)
        self.selectedImageView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        if let svgImage = svgImage?.uiImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.selectedImageView.image = svgImage
            }
        }
        self.uploadSiteImageDetail(from: url)
    }
    
    func uploadSiteImageDetail(from url: URL) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let apiService = ApiService.uploadSiteImageData(userId: self.siteResponseModel?.siteId ?? 0)

        APIClient.uploadFile(apiService, url) { [weak self] (result: Result<APIClient.MappableResult<SiteImageResponse>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        self.siteImageResponse = responseResult
                        if let url = responseResult.url {
                            reloadSiteImage(urlString:url, scl: scl)
                        }else {
                            scl.hideView()
                            SCLAlertView().showError("Error", subTitle: "something went wrong while uploading site image")
                        }
                    }
                case .failure(let error):
                    SCLAlertView().showError("Error", subTitle: "something went wrong while uploading site image")
                }
            }
        }
    }
    
    func showSelectionPopup() {
        // Create an action sheet UIAlertController
        let alertController = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
        
        let option1 = UIAlertAction(title: "Image", style: .default) { _ in
            self.presentPhotoPicker()
        }
        
        let option2 = UIAlertAction(title: "SVG", style: .default) { _ in
            self.handleSVGOption()
        }
        
        let option3 = UIAlertAction(title: "GIF", style: .default) { _ in
            self.handleGIFOption()
        }
        
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(option3)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .svg, .gif], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func handleSVGOption() {
        self.presentDocumentPicker()
    }
    
    func handleGIFOption() {
        self.presentDocumentPicker()
    }
    
}

// create site required cell setup
class siteBasicDetailCollectionCell: UICollectionViewCell {
    
    let dropDownMenuArray = ["Select", "East Midlands", "Ireland & Northern Ireland", "London & Eastern", "North East, Yourshine & Humberside", "North West", "Scotland", "South East", "South West", "Wales", "West Midlands"]
    
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var txfiled: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageViewWidthCons: NSLayoutConstraint!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var dropDownIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpDropDownMenu()
    }
    
    func setUpDropDownMenu() {
        var actions = [UIAction]()
        for item in self.dropDownMenuArray {
            actions.append(UIAction(title: item, state: self.txfiled.text == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedButton.setTitle(item, for: .normal)
                    self.selectedButton.setTitleColor(item == "Select" ? UIColor.gray : UIColor.black, for: .normal)
                    self.txfiled.text = item == "Select" ? nil : item
                    createSiteArea = self.txfiled.text ?? ""
                    self.txfiled.textColor = .clear
                }
            }))
        }
        self.selectedButton.menu = UIMenu(title: "", children: actions)
        self.selectedButton.showsMenuAsPrimaryAction = true
    }
    
    @objc func handleSelection(_ sender: UIButton) {
        if let menu = sender.menu {
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
            sender.sendActions(for: .touchUpInside)
        }
    }
    
}

class siteBasicDetailHeaderCollectionCell: UICollectionReusableView {
    
    @IBOutlet weak var headerLbl: UILabel!
    
}


// create site details user defaults
var createSiteName: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteName") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteName")
    }
}

var createSiteAddressLine1: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteAddressLine1") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteAddressLine1")
    }
}

var createSiteAddressLine2: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteAddressLine2") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteAddressLine2")
    }
}

var createSiteCity: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteCity") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteCity")
    }
}

var createSiteArea: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteArea") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteArea")
    }
}

var createSitePostCode: String {
    get {
        UserDefaults.standard.value(forKey: "createSitePostCode") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSitePostCode")
    }
}

var createSiteCountry: String {
    get {
        UserDefaults.standard.value(forKey: "createSiteCountry") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "createSiteCountry")
    }
}

//key contacts details
var keyContactsName: String {
    get {
        UserDefaults.standard.value(forKey: "keyContactsName") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "keyContactsName")
    }
}

var keyContactsPhone: String {
    get {
        UserDefaults.standard.value(forKey: "keyContactsPhone") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "keyContactsPhone")
    }
}

var keyContactsEmail: String {
    get {
        UserDefaults.standard.value(forKey: "keyContactsEmail") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "keyContactsEmail")
    }
}

var keyContactsRole: String {
    get {
        UserDefaults.standard.value(forKey: "keyContactsRole") as? String ?? ""
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "keyContactsRole")
    }
}

extension SiteBasicDetailVC {
    
    //download Site Image
    func downloadAndSaveImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.dataTask(with: url) { data, response, error in
            // Handle errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid data
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No data found"])
                completion(.failure(error))
                return
            }
            
            // Create a unique filename
            let fileName = UUID().uuidString + ".png"
            
            // Get the documents directory URL
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // Create the full file path
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                // Write the image data to the file
                try data.write(to: fileURL)
                
                // Load the saved image from the fileURL
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    completion(.success(image))
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Could not create image from file"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        downloadTask.resume()
    }
    
}

func extractCoordinates(from urlString: String) -> (latitude: CLLocationDegrees, longitude: CLLocationDegrees)? {
    // Find the range of the coordinates in the URL string
    if let coordinateRange = urlString.range(of: "q=") {
        let coordinatesString = urlString[coordinateRange.upperBound...]
        
        // Split the coordinates string by comma
        let coordinates = coordinatesString.split(separator: ",")
        if coordinates.count == 2 {
            if let latitude = CLLocationDegrees(coordinates[0]),
               let longitude = CLLocationDegrees(coordinates[1]) {
                return (latitude: latitude, longitude: longitude)
            }
        }
    }
    return nil
}

extension SiteBasicDetailVC: CustomTextFieldDelegate {
    
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        
    }
    
}
