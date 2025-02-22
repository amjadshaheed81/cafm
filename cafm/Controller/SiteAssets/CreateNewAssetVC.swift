//
//  CreateNewAssetVC.swift
//  cafm
//
//  Created by NS on 06/09/24.
//
//

import UIKit
import SCLAlertView
import SearchTextField
import PhotosUI
import SpreadsheetView

class CreateNewAssetVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var assetNameXIB: TextFiledDataXib!
    @IBOutlet weak var manufacturerXIB: TextFiledDataXib!
    
    @IBOutlet weak var relatedAssetMainView: UIView!
    @IBOutlet weak var relatedAssetCV: UICollectionView!
    @IBOutlet weak var relatedAssetCVMainView: UIView!
    @IBOutlet weak var relatedAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var relatedAssetTF_XIB: CustomTextField!
    
    @IBOutlet weak var folderXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var modelXIB: TextFiledDataXib!
    @IBOutlet weak var serialNumberXIB: TextFiledDataXib!
    
    @IBOutlet weak var assetImageMainView: UIView!
    @IBOutlet weak var assetImageMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var assetImageChooseFileView: UIView!
    @IBOutlet weak var assetImageChooseFileViewHeight: NSLayoutConstraint!
    @IBOutlet weak var assetImageChooseFileXIB: ChooseFileCapsuleXIB!
    
    @IBOutlet weak var categoryXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var subCategory1XIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var subCategory2XIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var subCategory3XIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var checkboxMainView: UIView!
    @IBOutlet weak var checkbox1XIB: CheckboxLabelXIB!
    @IBOutlet weak var checkbox2XIB: CheckboxLabelXIB!
    @IBOutlet weak var checkbox3XIB: CheckboxLabelXIB!
    
    @IBOutlet weak var tabMainView: UIView!
    @IBOutlet weak var tabMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tabCV: UICollectionView!
    
    @IBOutlet weak var purchaseDetailsMainView: UIView!
    @IBOutlet weak var locationMainView: UIView!
    @IBOutlet weak var valuationDisposalMainView: UIView!
    @IBOutlet weak var patDetailsMainView: UIView!
    @IBOutlet weak var passiveFireProtectionMainView: UIView!
    @IBOutlet weak var doorSpecificationsMainView: UIView!
    
    @IBOutlet weak var purchaseDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var supplierXIB: TextFiledDataXib!
    @IBOutlet weak var transactionIdXIB: TextFiledDataXib!
    @IBOutlet weak var costXIB: TextFiledDataXib!
    
    @IBOutlet weak var invoiceMainView: UIView!
    @IBOutlet weak var invoiceChooseFileView: UIView!
    @IBOutlet weak var invoiceChooseFileViewHeight: NSLayoutConstraint!
    @IBOutlet weak var invoiceChooseFileXIB: ChooseFileCapsuleXIB!
    @IBOutlet weak var downloadUploadedInvoiceBtn: UIButton!
    @IBOutlet weak var downloadUploadedInvoiceBtnHeight: NSLayoutConstraint!
    
    @IBOutlet weak var internalExternalXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var floorXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var roomXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var valuationDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var valuationXIB: TextFiledDataXib!
    @IBOutlet weak var valuationDoneByXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var disposalDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var disposalValueXIB: TextFiledDataXib!
    @IBOutlet weak var disposalToXIB: TextFiledDataXib!
    
    @IBOutlet weak var addPATRecordMainView: DesignableView!
    @IBOutlet weak var addPATRecordMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addPATRecordBtn: DefaultFontButton!
    @IBOutlet weak var patDetailsSpreadsheetContainerView: DesignableView!
    @IBOutlet weak var patDetailsSpreadsheetView: SpreadsheetView!
    @IBOutlet weak var patDetailsSpreadsheetViewWidth: NSLayoutConstraint!
    @IBOutlet weak var patDetailsSpreadsheetViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var productNameXIB: TextFiledDataXib!
    @IBOutlet weak var accessPositionXIB: TextFiledDataXib!
    @IBOutlet weak var materialXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var serviceXIB: TextFiledDataXib!
    @IBOutlet weak var dimensionXIB: TextFiledDataXib!
    @IBOutlet weak var quantityXIB: TextFiledDataXib!
    @IBOutlet weak var area_sq_m_XIB: TextFiledDataXib!
    
    @IBOutlet weak var doorWidth_mm_XIB: TextFiledDataXib!
    @IBOutlet weak var doorHeight_mm_XIB: TextFiledDataXib!
    @IBOutlet weak var doorDepth_mm_XIB: TextFiledDataXib!
    @IBOutlet weak var doorFinishXIB: TextFiledDataXib!
    @IBOutlet weak var visionPanelXIB: TextFiledDataXib!
    @IBOutlet weak var fireRatingXIB: TextFiledDataXib!
    @IBOutlet weak var fireMaterialXIB: TextFiledDataXib!
    @IBOutlet weak var frameFinishXIB: TextFiledDataXib!
    
    @IBOutlet weak var tabSaveBtnView: UIView!
    @IBOutlet weak var tabSaveBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tabSaveBtn: PrimaryButton!
    
    @IBOutlet weak var disableUserInteractionView: UIView!
    @IBOutlet weak var tabDisableUserInteractionView: UIView!
    @IBOutlet weak var purchaseDetailDisableUserInteractionView: UIView!
    
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
    private var patDetailsLoadingStatus: LoadingStatus = .default
    
    private var tagAssetTableView: CustomTableView?
    private var tagAssetOverlayView: UIView!
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    private var keyBoardHeight: CGFloat = 0.0
    
    var isForCreateNew: Bool = false
    var isViewModeEdit: Bool = false
    private var isFieldsEditable: Bool {
        return self.isForCreateNew || self.isViewModeEdit
    }
    var selectedAssetId: Int?
    
    private var assetModel: AssetDetailsResponse? {
        didSet {
            self.patDetailsItemsArray = self.assetModel?.assetPATItems ?? []
        }
    }
    
    private var parentFolderItemArray: [ParentFolder] = []
    private var assetsItemArray: [AssetDetailsResponse] = []
    private var ASSET_CATEGORY_ItemArray: [LOV_Model] = []
    private var ASSET_SUB_CATEGORY_ItemArray: [LOV_Model] = []
    private var ASSET_SUB_CATEGORY_2_ItemArray: [LOV_Model] = []
    private var ASSET_SUB_CATEGORY_3_ItemArray: [LOV_Model] = []
    
    private var userItemArray: [User] = []
    private var testerUserItemArray: [User] = []
    private var siteLayoutItemArray: [SiteLayoutModel] = []
    private var PASSIVE_FIRE_PROTECTION_ItemArray: [LOV_Model] = []
    
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var selectedASSET_SUB_CATEGORY_ItemArray: [LOV_Model] = []
    private var selectedASSET_SUB_CATEGORY_2_ItemArray: [LOV_Model] = []
    private var selectedASSET_SUB_CATEGORY_3_ItemArray: [LOV_Model] = []
    private var selectedFloorItemArray: [SiteLayoutModel] {
        return self.siteLayoutItemArray.filter { $0.nodeType == .floor }
    }
    private var selectedRoomItemArray: [SiteLayoutModel] {
        return self.siteLayoutItemArray.filter { $0.nodeType == .room }
    }
    private var patDetailsItemsArray: [AssetPATItem] = []
    private var addPATRecordItemArray: [AssetPATItem] = []
    
    private var selectedParentFolderId: Int?
    private var selectedASSET_CATEGORY_id: Int?
    private var selectedASSET_SUB_CATEGORY_id: Int?
    private var selectedASSET_SUB_CATEGORY_2_id: Int?
    private var selectedASSET_SUB_CATEGORY_3_id: Int?
    private var selectedInternalExternal: String?
    private var selectedFloorId: Int?
    private var selectedRoomId: Int?
    private var selectedValuationDoneByUserId: Int?
    private var selectedPASSIVE_FIRE_PROTECTION_id: Int?
    
    private var selectedAssetFileName: String? {
        didSet {
            self.assetImageChooseFileXIB.fileNameLbl.text = selectedAssetFileName ?? "No file chosen"
        }
    }
    private var selectedAssetImage: UIImage?
    private var selectedAssetFileURL: URL?
    private var selectedInvoiceFileName: String? {
        didSet {
            self.invoiceChooseFileXIB.fileNameLbl.text = selectedInvoiceFileName ?? "No file chosen"
        }
    }
    private var selectedInvoiceImage: UIImage?
    private var selectedInvoiceFileURL: URL?
    
    // Choose File Tag
    private let assetFileTag = 1
    private let invoiceFileTag = 2
    
    // Date Picker Tag
    private let purchaseDateTag = 1
    private let valuationDateTag = 2
    private let disposalDateTag = 3
    private let kAssetsDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kAssetsRequestDateFormat = "yyyy-MM-dd HH:mm:ss"
    
    private let selectFolderStr = "Select Folder"
    private let selectCategoryStr = "Select Category"
    private let selectSubCategory1Str = "Select Sub Category 1"
    private let selectSubCategory2Str = "Select Sub Category 2"
    private let selectSubCategory3Str = "Select Sub Category 3"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let selectInternalExternalStr = "Select Internal/External"
    private let selectFloorStr = "Select Floor"
    private let selectRoomStr = "Select Room"
    private let purchaseDetailsStr = "Purchase Details"
    private let locationStr = "Location"
    private let valuationDisposalStr = "Valuation & Disposal"
    private let patDetailsStr = "PAT Details"
    private let passiveFireProtectionStr = "Passive Fire Protection"
    private let doorSpecificationsStr = "Door Specifications"
    private let selectMaterialStr = "Select Material"
    private let siteAssetHasBeenAddedSuccessStr = "Site asset has been added successully."
    private let failedToAddSiteAssetStr = "Failed to add Site asset."
    private let siteAssetHasBeenUpdatedSuccessStr = "Site asset has been updated successully."
    private let failedToUpdateSiteAssetStr = "Failed to update Site asset."
    private let patDetailsHasBeenUpdatedSuccessfullyStr = "PAT details has been updated successfully."
    private let passiveFireProtectionDetailsHasBeenUpdatedSuccessfullyStr = "Passive fire protection details has been updated successfully."
    private let doorSpecificationsDetailsHasBeenUpdatedSuccessfullyStr = "Door Specifications details has been updated successfully."
    
    private var tabItemArray: [(index: Int, text: String, isDataFilled: Bool)] = []
    private var selectedTabIndex: Int = 0
    
    private var patDetailsHeaderColumnNames = [
        "Tester",
        "Test Date",
        "Next Test Date",
        "Action",
    ]
    private var view4_patDetailsSpreadSheet_Height: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if self.isForCreateNew {
            self.title = "Create New Asset"
        }else if self.isViewModeEdit {
            self.title = "Update Asset"
        }else {
            self.title = "View Asset"
        }
        if self.isFieldsEditable {
            let saveBtn = getPrimaryNavigationBtn(title: "Save")
            saveBtn.addTarget(self, action: #selector(self.navSaveBtnClicked(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        }else if UserDefaults.standard.userRole == .admin || UserDefaults.standard.userRole == .manager {
            let saveBtn = getPrimaryNavigationBtn(title: "Edit")
            saveBtn.addTarget(self, action: #selector(self.navEditBtnClicked(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        }else {
            let userRole = UserDefaults.standard.userRole
            if userRole == .admin || userRole == .manager {
                let saveBtn = getPrimaryNavigationBtn(title: "Edit")
                saveBtn.addTarget(self, action: #selector(self.navEditBtnClicked(_:)), for: .touchUpInside)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        if self.relatedAssetTF_XIB.textField.isEditing {
            self.updateTagAssetTableView(for: self.relatedAssetTF_XIB.textField)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyBoardHeight = 0.0
    }
    
    @objc func navEditBtnClicked(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            for controller in navigationController.viewControllers {
                if controller is AssetRegisterVC {
                    let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CreateNewAssetVC") as! CreateNewAssetVC
                    vc.isViewModeEdit = true
                    vc.selectedAssetId = self.selectedAssetId
                    self.navigationController?.popViewController(animated: false)
                    controller.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
        }else {
            let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CreateNewAssetVC") as! CreateNewAssetVC
            vc.isViewModeEdit = true
            vc.selectedAssetId = self.selectedAssetId
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.isViewModeEdit = true
        self.configureNavigationBar()
        self.setupViews()
        self.reloadViews()
    }
    
    @objc func navSaveBtnClicked(_ sender: UIButton) {
        let model = AssetDetailsResponse()
        model.isSelected = nil
        model.assetId = self.assetModel?.assetId
        self.assetNameXIB.tfData.endEditing(true)
        if let text = self.assetNameXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.assetName = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please enter asset name", cancelButtonTitle: "OK")
            return
        }
        self.manufacturerXIB.tfData.endEditing(true)
        if let text = self.manufacturerXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.manufacturer = text
        }
        //else {
        //    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter manufacturer", cancelButtonTitle: "OK")
        //    return
        //}
        //if let id = selectedParentFolderId {
        //    model.folderId = id
        //}else {
        //    SCLAlertView.showErrorAlert(title: "Error", message: "Please select folder", cancelButtonTitle: "OK")
        //    return
        //}
        self.modelXIB.tfData.endEditing(true)
        if let text = self.modelXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.model = text
        }
        //else {
        //    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter model", cancelButtonTitle: "OK")
        //    return
        //}
        self.serialNumberXIB.tfData.endEditing(true)
        if let text = self.serialNumberXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.serialNumber = text
        }
        //else {
        //    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter serial number", cancelButtonTitle: "OK")
        //    return
        //}
        if self.selectedAssetFileName != nil && (self.selectedAssetImage != nil || self.selectedAssetFileURL != nil) {
        }else if self.assetImageView.image != nil {
            model.image = self.assetModel?.image
        }
        //else {
        //    SCLAlertView.showErrorAlert(title: "Error", message: "Please select asset image.", cancelButtonTitle: "OK")
        //    return
        //}
        if let id = self.selectedASSET_CATEGORY_id {
            model.category = self.ASSET_CATEGORY_ItemArray.first(where: { $0.id == id })?.lovValue
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please select category", cancelButtonTitle: "OK")
            return
        }
        if !self.selectedAssetsItemArray.isEmpty {
            model.relatedAssetId = self.selectedAssetsItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
        }
        if let id = self.selectedASSET_SUB_CATEGORY_id {
            model.subCategory = self.ASSET_SUB_CATEGORY_ItemArray.first(where: { $0.id == id })?.lovValue
        }
        if let id = self.selectedASSET_SUB_CATEGORY_2_id {
            model.subCategory2 = self.ASSET_SUB_CATEGORY_2_ItemArray.first(where: { $0.id == id })?.lovValue
        }
        if let id = self.selectedASSET_SUB_CATEGORY_3_id {
            model.subCategory3 = self.ASSET_SUB_CATEGORY_3_ItemArray.first(where: { $0.id == id })?.lovValue
        }
        model.patItem = self.checkbox1XIB.isOn
        model.pfpItem = self.checkbox2XIB.isOn
        model.doorItem = self.checkbox3XIB.isOn
        
        model.barcode = ""
        
        self.saveSiteAsset(model: model)
    }
    
    func saveSiteAsset(model: AssetDetailsResponse) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.put_siteAssetsAPI(siteId: siteID)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.requestMultipart(apiService) { multipartFormData in
            if let fileName = model.assetName ?? self.selectedAssetFileName {
                if let image = self.selectedAssetImage {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(data, withName: "assetImage", fileName: fileName, mimeType: "image/jpeg")
                    }
                }else if let fileURL = self.selectedAssetFileURL {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        multipartFormData.append(data, withName: "assetImage", fileName: fileName, mimeType: APIClient.mimeType(for: fileURL))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }else if let image = self.assetImageView.image {
                //let imageURL = model.image, let url = URL(string: imageURL)
                if let data = image.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(data, withName: "assetImage", fileName: model.assetName ?? "image", mimeType: "image/jpeg")
                }
            }
            
            do {
                var json = model.toJSON()
                json.removeValue(forKey: "isSelected")
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                multipartFormData.append(data, withName: "assetRequestString")
            } catch {
                print(error.localizedDescription)
            }
        } completion: { [weak self] (result: Result<APIClient.MappableResult<AssetDetailsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.assetId != nil {
                        self.loadingSCLAlertView.hideView()
                        SCLAlertView.showSuccessAlert(title: "", message: siteAssetHasBeenAddedSuccessStr, doneButtonTitle: "OK") { [weak self] in
                            guard let self else { return }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else {
                        self.hideLoadingAndShowError(message: failedToAddSiteAssetStr)
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError(message: failedToAddSiteAssetStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: failedToAddSiteAssetStr)
            }
        }
    }
    
    func hideLoadingAndShowError(message: String?) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
    func setupViews() {
        self.disableUserInteractionView.isHidden = self.isFieldsEditable
        let bgColor = self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        self.assetNameXIB.title = "Asset Name"
        self.assetNameXIB.tfData.backgroundColor = bgColor
        self.manufacturerXIB.title = "Manufacturer"
        self.manufacturerXIB.tfData.backgroundColor = bgColor
        
        relatedAssetCV.delegate = self
        relatedAssetCV.dataSource = self
        relatedAssetTF_XIB.textField.placeholder = "Tag Asset"
        relatedAssetTF_XIB.textField.backgroundColor = bgColor
        relatedAssetTF_XIB.textField.delegate = self
        relatedAssetTF_XIB.delegate = self
        setUpOverlayImage()
        reloadRelatedAssetCV(assetId: nil)
        
        self.folderXIB.title = "Folder"
        self.folderXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.folderXIB.optionXIB.lblText.text = selectFolderStr
        self.modelXIB.title = "Model"
        self.modelXIB.tfData.backgroundColor = bgColor
        self.serialNumberXIB.title = "Serial Number"
        self.serialNumberXIB.tfData.backgroundColor = bgColor
        
        let kAssetImageViewHeight: CGFloat = CGFloat.zero
        self.assetImageMainViewHeight.constant = kAssetImageViewHeight
        self.assetImageMainView.frame.size.height = kAssetImageViewHeight
        self.assetImageMainView.isHidden = true
        self.assetImageView.addBorder(color: UIColor(appColor: .ViewBorder))
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.assetImageChooseFileXIB.chooseFileBtn, tag: self.assetFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
        }else {
            let kHeight: CGFloat = CGFloat.zero
            self.assetImageChooseFileViewHeight.constant = kHeight
            self.assetImageChooseFileView.frame.size.height = kHeight
            self.assetImageChooseFileView.isHidden = true
        }
        
        self.categoryXIB.title = "Category"
        self.categoryXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.categoryXIB.optionXIB.lblText.text = selectCategoryStr
        self.subCategory1XIB.title = "Sub Category 1"
        self.subCategory1XIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.subCategory1XIB.optionXIB.lblText.text = selectSubCategory1Str
        self.setupSubCategory1Menu()
        self.subCategory2XIB.title = "Sub Category 2"
        self.subCategory2XIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.subCategory2XIB.optionXIB.lblText.text = selectSubCategory2Str
        self.setupSubCategory2Menu()
        self.subCategory3XIB.title = "Sub Category 3"
        self.subCategory3XIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.subCategory3XIB.optionXIB.lblText.text = selectSubCategory3Str
        self.setupSubCategory3Menu()
        
        self.checkbox1XIB.title = "PAT item (fill PAT details below)"
        self.checkbox1XIB.isDisabled = !self.isFieldsEditable
        self.checkbox1XIB.delegate = self
        self.checkbox1XIB.isOn = false
        self.checkbox2XIB.title = "Passive fire schedule required (fill PFS details below below)"
        self.checkbox2XIB.isDisabled = !self.isFieldsEditable
        self.checkbox2XIB.delegate = self
        self.checkbox2XIB.isOn = false
        self.checkbox3XIB.title = "Door Assets (fill Door assets details below below)"
        self.checkbox3XIB.isDisabled = !self.isFieldsEditable
        self.checkbox3XIB.delegate = self
        self.checkbox3XIB.isOn = false
        
        if self.isForCreateNew {
            let height: CGFloat = CGFloat.zero
            self.tabMainViewHeight.constant = height
            self.tabMainView.frame.size.height = height
            self.tabMainView.isHidden = true
        }else {
            self.setupTabViews()
        }
    }
    
    func reloadViews() {
        guard let model = self.assetModel else {
            return
        }
        
        if self.isForCreateNew {
            self.title = "Create New Asset"
        }else if self.isViewModeEdit {
            self.title = "Update \(model.assetName ?? "Asset")"
        }else {
            self.title = "View \(model.assetName ?? "Asset")"
        }
        
        self.assetNameXIB.tfData.text = model.assetName
        self.manufacturerXIB.tfData.text = model.manufacturer
        
        if let relatedAssetId = model.relatedAssetId {
            let idArray = relatedAssetId.components(separatedBy: ",").compactMap({ Int($0) })
            self.selectedAssetsItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
            reloadRelatedAssetCV(assetId: nil)
        }
        
        //if let folderId = model.folderId, let folderName = self.parentFolderItemArray.first(where: { $0.id == folderId })?.name {
        //    self.selectedParentFolderId = folderId
        //    self.folderXIB.optionXIB.lblText.text = folderName
        //}else if let folderName = model.folderName, let item = self.parentFolderItemArray.first(where: { $0.name == folderName }) {
        //    self.selectedParentFolderId = item.id
        //    self.folderXIB.optionXIB.lblText.text = folderName
        //}
        
        self.modelXIB.tfData.text = model.model
        self.serialNumberXIB.tfData.text = model.serialNumber
        
        self.selectedAssetFileName = nil
        self.selectedAssetImage = nil
        self.selectedAssetFileURL = nil
        if let image = model.image {
            self.assetImageView.sd_setImage(with: URL(string: image)) { [weak self] image, _, _, _ in
                guard let self else { return }
                if let image {
                    let kAssetImageViewHeight: CGFloat = 5+min(self.assetImageView.frame.size.width, self.assetImageView.frame.size.width*image.size.height/image.size.width)+5
                    self.assetImageMainViewHeight.constant = kAssetImageViewHeight
                    self.assetImageMainView.frame.size.height = kAssetImageViewHeight
                    self.assetImageMainView.isHidden = false
                }else {
                    let kAssetImageViewHeight: CGFloat = CGFloat.zero
                    self.assetImageMainViewHeight.constant = kAssetImageViewHeight
                    self.assetImageMainView.frame.size.height = kAssetImageViewHeight
                    self.assetImageMainView.isHidden = true
                }
            }
        }
        
        if let category = model.category, let item = self.ASSET_CATEGORY_ItemArray.first(where: { $0.lovValue == category }) {
            self.selectedASSET_CATEGORY_id = item.id
            self.categoryXIB.optionXIB.lblText.text = item.lovValue
            self.setupCategoryMenu()
            self.selectedASSET_SUB_CATEGORY_ItemArray = self.ASSET_SUB_CATEGORY_ItemArray.filter({ $0.attribite1 == item.lovValue })
            self.reloadSubCategory1XIB()
        }
        if let subCategory = model.subCategory, let item = self.ASSET_SUB_CATEGORY_ItemArray.first(where: { $0.lovValue == subCategory }) {
            self.selectedASSET_SUB_CATEGORY_id = item.id
            self.subCategory1XIB.optionXIB.lblText.text = item.lovValue
            self.setupSubCategory1Menu()
            self.selectedASSET_SUB_CATEGORY_2_ItemArray = self.ASSET_SUB_CATEGORY_2_ItemArray.filter({ $0.attribite1 == item.lovValue })
            self.reloadSubCategory2XIB()
        }
        if let subCategory2 = model.subCategory2, let item = self.ASSET_SUB_CATEGORY_2_ItemArray.first(where: { $0.lovValue == subCategory2 }) {
            self.selectedASSET_SUB_CATEGORY_2_id = item.id
            self.subCategory2XIB.optionXIB.lblText.text = subCategory2
            self.setupSubCategory2Menu()
            self.selectedASSET_SUB_CATEGORY_3_ItemArray = self.ASSET_SUB_CATEGORY_3_ItemArray.filter({ $0.attribite1 == item.lovValue })
            self.reloadSubCategory3XIB()
        }
        if let subCategory3 = model.subCategory3, let item = self.ASSET_SUB_CATEGORY_3_ItemArray.first(where: { $0.lovValue == subCategory3 }) {
            self.selectedASSET_SUB_CATEGORY_3_id = item.id
            self.subCategory3XIB.optionXIB.lblText.text = subCategory3
            self.setupSubCategory3Menu()
        }
        
        self.checkbox1XIB.isOn = model.patItem ?? false
        self.checkbox2XIB.isOn = model.pfpItem ?? false
        self.checkbox3XIB.isOn = model.doorItem ?? false
        
        if !self.isForCreateNew {
            self.reloadTabViews()
        }
    }
    
    func setUpOverlayImage() {
        self.tagAssetOverlayView = UIView(frame: self.view.bounds)
        self.tagAssetOverlayView.backgroundColor = .clear
        self.tagAssetOverlayView.isHidden = true // Initially hidden
        self.view.addSubview(self.tagAssetOverlayView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTagAssetsTableView))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hideTagAssetsTableView))
        self.tagAssetOverlayView.addGestureRecognizer(panGesture)
        self.tagAssetOverlayView.addGestureRecognizer(tapGesture)
    }
    
    func showTagAssetsTableView() {
        self.tagAssetOverlayView.isHidden = false
        self.tagAssetTableView?.isHidden = false
    }
    
    @objc func hideTagAssetsTableView() {
        self.tagAssetOverlayView.isHidden = true
        self.tagAssetTableView?.isHidden = true
        self.tagAssetTableView?.hideTableView()
    }
    
    func updateTagAssetTableView(for textField: UITextField) {
        guard textField.isEditing else { return }
        showTagAssetsTableView()
        if self.tagAssetTableView == nil {
            self.tagAssetTableView = CustomTableView()
            self.tagAssetTableView?.type = .tagAsset
        }
        
        // Safely find the cell containing the text field
        var textFieldFrame = textField.convert(textField.bounds, to: view)
        textFieldFrame.origin.y -= self.relatedAssetCVMainViewHeight.constant
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - topSafeArea - navigationHeight - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        let desiredTableViewHeight = CGFloat(filteredAssetsItemArray.count > 5 ? (5 * 40) + 20 : filteredAssetsItemArray.count * 40)
        
        // Determine whether to show the table view below or above the text field
        if desiredTableViewHeight <= availableSpaceBelowTextField {
            // Show the tableView below the text field
            self.tagAssetTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                   y: textFieldFrame.maxY + 5, // Small gap below the text field
                                                   width: textFieldFrame.width,
                                                   height: desiredTableViewHeight)
        } else if desiredTableViewHeight <= availableSpaceAboveTextField {
            // Show the tableView above the text field
            self.tagAssetTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                   y: textFieldFrame.minY - desiredTableViewHeight - 5, // Small gap above the text field
                                                   width: textFieldFrame.width,
                                                   height: desiredTableViewHeight)
        } else {
            // Show the tableView with maximum available space below or above
            if availableSpaceBelowTextField >= availableSpaceAboveTextField {
                // Show the tableView below, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceBelowTextField)
                self.tagAssetTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                       y: textFieldFrame.maxY + 5,
                                                       width: textFieldFrame.width,
                                                       height: tableViewHeight)
            } else {
                // Show the tableView above, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceAboveTextField)
                self.tagAssetTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                       y: textFieldFrame.minY - tableViewHeight - 5,
                                                       width: textFieldFrame.width,
                                                       height: tableViewHeight)
            }
        }
        
        self.tagAssetTableView?.isHidden = filteredAssetsItemArray.isEmpty
        self.tagAssetTableView?.tagAssetItemArray = filteredAssetsItemArray
        self.tagAssetTableView?.showTableView(with: filteredAssetsItemArray)
        view.addSubview(self.tagAssetTableView!)
        
        self.tagAssetTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? AssetDetailsResponse {
                    textField.text = ""
                    self.reloadRelatedAssetCV(assetId: item.assetId) { [weak self] in
                        guard let self else { return }
                        reloadFilteredAssetsItemArray()
                    }
                }
            }
        }
    }
    
    func reloadFilteredAssetsItemArray() {
        let textField: UITextField = self.relatedAssetTF_XIB.textField
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filteredAssetsItemArray = self.assetsItemArray.filter { asset in
                return !self.selectedAssetsItemArray.contains { $0.assetId == asset.assetId } && (text.isEmpty || asset.assetName?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateTagAssetTableView(for: textField)
            }
        }
    }
    
    func reloadRelatedAssetCV(assetId: Int?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let assetId, let item = self.assetsItemArray.first(where: { $0.assetId == assetId }) {
                self.selectedAssetsItemArray.insert(item, at: 0)
            }
            
            if self.selectedAssetsItemArray.isEmpty {
                let height: CGFloat = CGFloat.zero
                self.relatedAssetCVMainView.isHidden = true
                self.relatedAssetCVMainViewHeight.constant = height
                self.relatedAssetCVMainView.frame.size.height = height
            }else {
                let height: CGFloat = 50
                self.relatedAssetCVMainView.isHidden = false
                self.relatedAssetCVMainViewHeight.constant = height
                self.relatedAssetCVMainView.frame.size.height = height
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.relatedAssetCV.reloadData()
                completion?()
            }
        }
    }
    
    func setupFolderMenu() {
        let view: OptionBtnWithTitleXIB = self.folderXIB
        var actions: [UIMenuElement] = []
        for item in self.parentFolderItemArray {
            let action = UIAction(title: item.name ?? "", state: self.selectedParentFolderId == item.id ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedParentFolderId = item.id
                view.optionXIB.lblText.text = item.name
                self.setupFolderMenu()
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(title: selectFolderStr, children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupCategoryMenu() {
        let view: OptionBtnWithTitleXIB = self.categoryXIB
        var actions: [UIMenuElement] = []
        for item in self.ASSET_CATEGORY_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedASSET_CATEGORY_id == item.id ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedASSET_CATEGORY_id = item.id
                view.optionXIB.lblText.text = item.lovValue
                self.setupCategoryMenu()
                self.selectedASSET_SUB_CATEGORY_ItemArray = self.ASSET_SUB_CATEGORY_ItemArray.filter({ $0.attribite1 == item.lovValue })
                self.reloadSubCategory1XIB()
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(title: selectCategoryStr, children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubCategory1XIB() {
        self.subCategory1XIB.optionXIB.lblText.text = selectSubCategory1Str
        self.selectedASSET_SUB_CATEGORY_id = nil
        self.setupSubCategory1Menu()
        self.selectedASSET_SUB_CATEGORY_2_ItemArray = []
        self.reloadSubCategory2XIB()
    }
    
    func setupSubCategory1Menu() {
        let view: OptionBtnWithTitleXIB = self.subCategory1XIB
        let defaultStr = selectSubCategory1Str
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedASSET_SUB_CATEGORY_id = item?.id
            view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
            self.setupSubCategory1Menu()
            self.selectedASSET_SUB_CATEGORY_2_ItemArray = self.ASSET_SUB_CATEGORY_2_ItemArray.filter({ $0.attribite1 == item?.lovValue })
            self.reloadSubCategory2XIB()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedASSET_SUB_CATEGORY_id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedASSET_SUB_CATEGORY_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedASSET_SUB_CATEGORY_id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubCategory2XIB() {
        self.subCategory2XIB.optionXIB.lblText.text = selectSubCategory2Str
        self.selectedASSET_SUB_CATEGORY_2_id = nil
        self.setupSubCategory2Menu()
        self.selectedASSET_SUB_CATEGORY_3_ItemArray = []
        self.reloadSubCategory3XIB()
    }
    
    func setupSubCategory2Menu() {
        let view: OptionBtnWithTitleXIB = self.subCategory2XIB
        let defaultStr = selectSubCategory2Str
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedASSET_SUB_CATEGORY_2_id = item?.id
            view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
            self.setupSubCategory2Menu()
            self.selectedASSET_SUB_CATEGORY_3_ItemArray = self.ASSET_SUB_CATEGORY_3_ItemArray.filter({ $0.attribite1 == item?.lovValue })
            self.reloadSubCategory3XIB()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedASSET_SUB_CATEGORY_2_id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedASSET_SUB_CATEGORY_2_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedASSET_SUB_CATEGORY_2_id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubCategory3XIB() {
        self.subCategory3XIB.optionXIB.lblText.text = selectSubCategory3Str
        self.selectedASSET_SUB_CATEGORY_3_id = nil
        self.setupSubCategory3Menu()
    }
    
    func setupSubCategory3Menu() {
        let view: OptionBtnWithTitleXIB = self.subCategory3XIB
        let defaultStr = selectSubCategory3Str
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedASSET_SUB_CATEGORY_3_id = item?.id
            view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
            self.setupSubCategory3Menu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedASSET_SUB_CATEGORY_3_id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedASSET_SUB_CATEGORY_3_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedASSET_SUB_CATEGORY_3_id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func downloadUploadedInvoiceBtnClicked(_ sender: UIButton) {
        guard let invoiceFile = self.assetModel?.invoiceFile else { return }
        CAFMFileUtils.shared.downloadAndShareFile(invoiceFile, from: self, sender: sender, shouldDeleteAfterSharing: true)
    }
    
    @IBAction func tabSaveBtnClicked(_ sender: PrimaryButton) {
        let index = self.selectedTabIndex
        switch index {
        case 1, 2, 3:
            guard let assetModel else { return }
            let model = AssetDetailsResponse()
            model.assetId = assetModel.assetId
            model.isSelected = nil
            
            if let value = assetModel.purchaseDate {
                model.purchaseDate = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
            }else {
                if index == 1 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter purchase date.", cancelButtonTitle: "OK")
                    return
                }else {
                    model.purchaseDate = assetModel.purchaseDate
                }
            }
            self.supplierXIB.tfData.endEditing(true)
            if let text = self.supplierXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.supplier = text
            }else {
                if index == 1 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter supplier", cancelButtonTitle: "OK")
                    return
                }else {
                    model.supplier = assetModel.supplier
                }
            }
            self.transactionIdXIB.tfData.endEditing(true)
            if let text = self.transactionIdXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.transactionId = text
            }else {
                //if index == 1 {
                //    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter transaction ID", cancelButtonTitle: "OK")
                //    return
                //}else {
                model.transactionId = assetModel.transactionId
                //}
            }
            self.costXIB.tfData.endEditing(true)
            if let text = self.costXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.cost = text
            }else {
                if index == 1 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter cost", cancelButtonTitle: "OK")
                    return
                }else {
                    model.cost = assetModel.cost
                }
            }
            if self.selectedInvoiceFileName != nil && (self.selectedInvoiceImage != nil || self.selectedInvoiceFileURL != nil) {
            }else if let value = assetModel.invoiceFile {
                model.invoiceFile = value
            }else {
                //if index == 1 {
                //    SCLAlertView.showErrorAlert(title: "Error", message: "Please select invoice file", cancelButtonTitle: "OK")
                //    return
                //}else {
                model.invoiceFile = assetModel.invoiceFile
                //}
            }
            
            if let id = self.selectedInternalExternal {
                model.position = id
            }else {
                //if index == 2 {
                //    SCLAlertView.showErrorAlert(title: "Error", message: "Please select Internal/External", cancelButtonTitle: "OK")
                //    return
                //}else {
                model.position = assetModel.position
                //}
            }
            if let id = self.selectedFloorId {
                model.floor = self.siteLayoutItemArray.first(where: { $0.nodeType == .floor && $0.id == id })?.nodeName
            }else {
                //if index == 2 {
                //    SCLAlertView.showErrorAlert(title: "Error", message: "Please select floor", cancelButtonTitle: "OK")
                //    return
                //}else {
                model.floor = assetModel.floor
                //}
            }
            if let id = self.selectedRoomId {
                model.room = self.siteLayoutItemArray.first(where: { $0.nodeType == .room && $0.id == id })?.nodeName
            }else {
                if index == 2 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please select room", cancelButtonTitle: "OK")
                    return
                }else {
                    model.room = assetModel.room
                }
            }
            
            if let value = assetModel.valuationDate {
                model.valuationDate = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter valuation date", cancelButtonTitle: "OK")
                    return
                }else {
                    model.valuationDate = assetModel.valuationDate
                }
            }
            self.valuationXIB.tfData.endEditing(true)
            if let text = self.valuationXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.valuationValue = text
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter valuation value", cancelButtonTitle: "OK")
                    return
                }else {
                    model.valuationValue = assetModel.valuationValue
                }
            }
            if let id = self.selectedValuationDoneByUserId {
                model.valuationUserId = self.userItemArray.first(where: { $0.id == id })?.id
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please select valuation done by", cancelButtonTitle: "OK")
                    return
                }else {
                    model.valuationUserId = assetModel.valuationUserId
                }
            }
            if let value = assetModel.disposalDate {
                model.disposalDate = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter disposal date", cancelButtonTitle: "OK")
                    return
                }else {
                    model.disposalDate = assetModel.disposalDate
                }
            }
            self.disposalValueXIB.tfData.endEditing(true)
            if let text = self.disposalValueXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.disposalValue = text
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter disposal value", cancelButtonTitle: "OK")
                    return
                }else {
                    model.disposalValue = assetModel.disposalValue
                }
            }
            self.disposalToXIB.tfData.endEditing(true)
            if let text = self.disposalToXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.disposalTo = text
            }else {
                if index == 3 {
                    SCLAlertView.showErrorAlert(title: "Error", message: "Please enter disposal to", cancelButtonTitle: "OK")
                    return
                }else {
                    model.disposalTo = assetModel.disposalTo
                }
            }
            
            self.saveSiteAssetsDetails(model: model, from: index)
            break
        case 4:
            guard let assetModel else { return }
            let model = PATDetailsRequest()
            model.assetPATItems = self.patDetailsItemsArray.compactMap({ assetPATItem in
                if let date = assetPATItem.patDate {
                    assetPATItem.patDate = date.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
                }
                if let date = assetPATItem.patNextDate {
                    assetPATItem.patNextDate = date.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
                }
                return assetPATItem
            })+self.addPATRecordItemArray.compactMap({ assetPATItem in
                if let date = assetPATItem.patDate {
                    assetPATItem.patDate = date.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
                }
                if let date = assetPATItem.patNextDate {
                    assetPATItem.patNextDate = date.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: kAssetsRequestDateFormat)
                }
                return assetPATItem
            })
            model.deletedPatIds = assetModel.assetPATItems?.filter({ assetPATItem in
                return !self.patDetailsItemsArray.contains { $0.patId == assetPATItem.patId }
            }).compactMap({ $0.patId })
            self.saveSiteAssets_patDetails(model: model)
            break
        case 5:
            guard let assetModel else { return }
            let model = AssetPFPItem()
            model.assetId = assetModel.assetId
            
            self.productNameXIB.tfData.endEditing(true)
            if let text = self.productNameXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.product = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter product name", cancelButtonTitle: "OK")
                return
            }
            self.accessPositionXIB.tfData.endEditing(true)
            if let text = self.accessPositionXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.access = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter Access/Position", cancelButtonTitle: "OK")
                return
            }
            if let id = self.selectedPASSIVE_FIRE_PROTECTION_id {
                model.material = self.PASSIVE_FIRE_PROTECTION_ItemArray.first(where: { $0.id == id })?.lovValue
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please select material", cancelButtonTitle: "OK")
                return
            }
            self.serviceXIB.tfData.endEditing(true)
            if let text = self.serviceXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.service = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter service", cancelButtonTitle: "OK")
                return
            }
            self.dimensionXIB.tfData.endEditing(true)
            if let text = self.dimensionXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.dimension = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter dimension", cancelButtonTitle: "OK")
                return
            }
            self.quantityXIB.tfData.endEditing(true)
            if let text = self.quantityXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.quantity = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter quantity", cancelButtonTitle: "OK")
                return
            }
            self.area_sq_m_XIB.tfData.endEditing(true)
            if let text = self.area_sq_m_XIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.area = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter area (in sq m)", cancelButtonTitle: "OK")
                return
            }
            
            self.saveSiteAssets_pspDetails(model: model)
            break
        case 6:
            guard let assetModel else { return }
            let model = AssetDoorSpecifications()
            model.assetId = assetModel.assetId
            
            self.doorWidth_mm_XIB.tfData.endEditing(true)
            if let text = self.doorWidth_mm_XIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.width = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter door width (in mm)", cancelButtonTitle: "OK")
                return
            }
            self.doorHeight_mm_XIB.tfData.endEditing(true)
            if let text = self.doorHeight_mm_XIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.height = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter door height (in mm)", cancelButtonTitle: "OK")
                return
            }
            self.doorDepth_mm_XIB.tfData.endEditing(true)
            if let text = self.doorDepth_mm_XIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.depth = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter door depth (in mm)", cancelButtonTitle: "OK")
                return
            }
            self.doorFinishXIB.tfData.endEditing(true)
            if let text = self.doorFinishXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.finish = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter door finish", cancelButtonTitle: "OK")
                return
            }
            self.visionPanelXIB.tfData.endEditing(true)
            if let text = self.visionPanelXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.visionPanel = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter vision panel", cancelButtonTitle: "OK")
                return
            }
            self.fireRatingXIB.tfData.endEditing(true)
            if let text = self.fireRatingXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.fireRating = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter fire rating", cancelButtonTitle: "OK")
                return
            }
            self.fireMaterialXIB.tfData.endEditing(true)
            if let text = self.fireMaterialXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.frameMaterial = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter fire material", cancelButtonTitle: "OK")
                return
            }
            self.frameFinishXIB.tfData.endEditing(true)
            if let text = self.frameFinishXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.frameFinish = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter frame finish", cancelButtonTitle: "OK")
                return
            }
            
            self.saveSiteAssets_doorSpecification(model: model)
            break
        default:
            break
        }
    }
    
    func saveSiteAssetsDetails(model: AssetDetailsResponse, from index: Int) {
        guard let assetId = self.assetModel?.assetId else {
            return
        }
        let apiService = ApiService.put_siteAssetsDetails(assetId: assetId)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.requestMultipart(apiService) { multipartFormData in
            if index == 1, let fileName = self.selectedInvoiceFileName {
                if let image = self.selectedInvoiceImage {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(data, withName: "purchaseInvoice", fileName: fileName, mimeType: "image/jpeg")
                    }
                }else if let fileURL = self.selectedInvoiceFileURL {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        multipartFormData.append(data, withName: "purchaseInvoice", fileName: fileName, mimeType: APIClient.mimeType(for: fileURL))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: model.toJSON(), options: [])
                multipartFormData.append(data, withName: "assetDetailsRequestString")
            } catch {
                print(error.localizedDescription)
            }
        } completion: { [weak self] (result: Result<APIClient.MappableResult<AssetDetailsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.assetId != nil {
                        self.getSiteAssetsDetailsFromAssetId(fromUpdateSiteAssetsDetails: true)
                    }else {
                        self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
            }
        }
    }
    
    func saveSiteAssets_patDetails(model: PATDetailsRequest) {
        guard let assetId = self.assetModel?.assetId else {
            return
        }
        let apiService = ApiService.put_siteAssets_patDetails(assetId: assetId, model: model)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<PATDetailsRequest>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.addPATRecordItemArray = []
                    self.getSiteAssetsDetailsFromAssetId(fromUpdateSiteAssetsDetails: true)
                    break
                case .array:
                    self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
            }
        }
    }
    
    func saveSiteAssets_pspDetails(model: AssetPFPItem) {
        guard let assetId = self.assetModel?.assetId else {
            return
        }
        let apiService = ApiService.put_siteAssets_pspDetails(assetId: assetId, model: model)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetDetailsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.assetId != nil {
                        self.getSiteAssetsDetailsFromAssetId(fromUpdateSiteAssetsDetails: true)
                    }else {
                        self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
            }
        }
    }
    
    func saveSiteAssets_doorSpecification(model: AssetDoorSpecifications) {
        guard let assetId = self.assetModel?.assetId else {
            return
        }
        let apiService = ApiService.put_siteAssets_doorSpecification(assetId: assetId, model: model)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetDoorSpecifications>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.assetId != nil {
                        self.getSiteAssetsDetailsFromAssetId(fromUpdateSiteAssetsDetails: true)
                    }else {
                        self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    }
                    break
                case .array:
                    self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
            }
        }
    }
    
}

//MARK: - TabViews
extension CreateNewAssetVC {
    
    func setupTabViews() {
        let bgColor = self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        self.tabItemArray = [
            (index: 1, text: purchaseDetailsStr, isDataFilled: false),
            (index: 2, text: locationStr, isDataFilled: false),
            (index: 3, text: valuationDisposalStr, isDataFilled: false),
        ]
        
        self.tabCV.delegate = self
        self.tabCV.dataSource = self
        self.tabCV.reloadData()
        
        self.purchaseDateXIB.title = "Purchase Date"
        self.purchaseDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.purchaseDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.purchaseDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.purchaseDateXIB.optionXIB.btnDownClick.tag = self.purchaseDateTag
        self.purchaseDateXIB.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
        self.supplierXIB.title = "Supplier"
        self.supplierXIB.tfData.backgroundColor = bgColor
        self.transactionIdXIB.title = "Transaction ID"
        self.transactionIdXIB.tfData.backgroundColor = bgColor
        self.transactionIdXIB.tfData.keyboardType = .numberPad
        self.costXIB.title = "Cost"
        self.costXIB.tfData.backgroundColor = bgColor
        self.costXIB.tfData.keyboardType = .decimalPad
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.invoiceChooseFileXIB.chooseFileBtn, tag: self.invoiceFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
        }else {
            let kHeight: CGFloat = CGFloat.zero
            self.invoiceChooseFileViewHeight.constant = kHeight
            self.invoiceChooseFileView.frame.size.height = kHeight
            self.invoiceChooseFileView.isHidden = true
        }
        
        self.internalExternalXIB.title = "Internal/External"
        self.internalExternalXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.internalExternalXIB.optionXIB.lblText.text = selectInternalExternalStr
        self.floorXIB.title = "Floor"
        self.floorXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.floorXIB.optionXIB.lblText.text = selectFloorStr
        self.roomXIB.title = "Room"
        self.roomXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.roomXIB.optionXIB.lblText.text = selectRoomStr
        
        if !self.isFieldsEditable {
            let height: CGFloat = CGFloat.zero
            self.addPATRecordMainViewHeight.constant = height
            self.addPATRecordMainView.frame.size.height = height
            self.addPATRecordMainView.isHidden = true
            
            self.patDetailsHeaderColumnNames.removeAll { $0 == "Action" }
        }
        
        self.patDetailsSpreadsheetView.addCorner(value: 12)
        self.patDetailsSpreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.patDetailsSpreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.patDetailsSpreadsheetView.showsVerticalScrollIndicator = false
        self.patDetailsSpreadsheetView.showsHorizontalScrollIndicator = false
        self.patDetailsSpreadsheetView.bounces = false
        self.patDetailsSpreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.patDetailsSpreadsheetView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        self.patDetailsSpreadsheetView.register(UINib(nibName: OptionBtnXibCell.className(), bundle: nil), forCellWithReuseIdentifier: OptionBtnXibCell.className())
        self.patDetailsSpreadsheetView.dataSource = self
        self.patDetailsSpreadsheetView.delegate = self
        
        self.valuationDateXIB.title = "Valuation Date"
        self.valuationDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.valuationDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.valuationDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.valuationDateXIB.optionXIB.btnDownClick.tag = self.valuationDateTag
        self.valuationDateXIB.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
        self.valuationXIB.title = "Valuation"
        self.valuationXIB.tfData.backgroundColor = bgColor
        self.valuationXIB.tfData.keyboardType = .decimalPad
        self.valuationDoneByXIB.title = "Valuation Done By"
        self.valuationDoneByXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.valuationDoneByXIB.optionXIB.lblText.text = ""
        self.disposalDateXIB.title = "Disposal Date"
        self.disposalDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.disposalDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.disposalDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.disposalDateXIB.optionXIB.btnDownClick.tag = self.disposalDateTag
        self.disposalDateXIB.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVC(_:)), for: .touchUpInside)
        self.disposalValueXIB.title = "Disposal Value"
        self.disposalValueXIB.tfData.backgroundColor = bgColor
        self.disposalValueXIB.tfData.keyboardType = .decimalPad
        self.disposalToXIB.title = "Disposal To"
        self.disposalToXIB.tfData.backgroundColor = bgColor
        
        self.productNameXIB.title = "Product Name"
        self.productNameXIB.tfData.backgroundColor = bgColor
        self.accessPositionXIB.title = "Access/Position"
        self.accessPositionXIB.tfData.backgroundColor = bgColor
        self.materialXIB.title = "Material"
        self.materialXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.materialXIB.optionXIB.lblText.text = selectMaterialStr
        self.serviceXIB.title = "Service"
        self.serviceXIB.tfData.backgroundColor = bgColor
        self.dimensionXIB.title = "Dimension"
        self.dimensionXIB.tfData.backgroundColor = bgColor
        self.quantityXIB.title = "Quantity"
        self.quantityXIB.tfData.backgroundColor = bgColor
        self.area_sq_m_XIB.title = "Area (in sq m)"
        self.area_sq_m_XIB.tfData.backgroundColor = bgColor
        
        self.doorWidth_mm_XIB.title = "Door Width (mm)"
        self.doorWidth_mm_XIB.tfData.backgroundColor = bgColor
        self.doorHeight_mm_XIB.title = "Door Height (mm)"
        self.doorHeight_mm_XIB.tfData.backgroundColor = bgColor
        self.doorDepth_mm_XIB.title = "Door Depth (mm)"
        self.doorDepth_mm_XIB.tfData.backgroundColor = bgColor
        self.doorFinishXIB.title = "Door Finish"
        self.doorFinishXIB.tfData.backgroundColor = bgColor
        self.visionPanelXIB.title = "Vision Panel"
        self.visionPanelXIB.tfData.backgroundColor = bgColor
        self.fireRatingXIB.title = "Fire Rating"
        self.fireRatingXIB.tfData.backgroundColor = bgColor
        self.fireMaterialXIB.title = "Fire Material"
        self.fireMaterialXIB.tfData.backgroundColor = bgColor
        self.frameFinishXIB.title = "Frame Finish"
        self.frameFinishXIB.tfData.backgroundColor = bgColor
        
        self.purchaseDetailsMainView.isHidden = true
        self.locationMainView.isHidden = true
        self.valuationDisposalMainView.isHidden = false
        self.patDetailsMainView.isHidden = false
        self.passiveFireProtectionMainView.isHidden = false
        self.doorSpecificationsMainView.isHidden = false
        
        if !self.isFieldsEditable {
            let height: CGFloat = CGFloat.zero
            self.tabSaveBtnViewHeight.constant = height
            self.tabSaveBtnView.frame.size.height = height
            self.tabSaveBtnView.isHidden = true
        }
        
        self.selectedTabIndex = 1
        self.showTabAtIndex(self.selectedTabIndex)
    }
    
    func reloadTabViews() {
        self.reload_purchaseDetailsMainView()
        self.reload_locationMainView()
        self.reload_valuationDisposalMainView()
        self.reload_patDetailsMainView()
        self.reload_passiveFireProtectionMainView()
        self.reload_doorSpecificationsMainView()
        
        self.tabCV.reloadData()
        self.showTabAtIndex(self.selectedTabIndex)
    }
    
    func reload_purchaseDetailsMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if let index = self.tabItemArray.firstIndex(where: { $0.text == purchaseDetailsStr }) {
            var isDataFilled = true
            if let value = model.purchaseDate, let newStr = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) {
                self.purchaseDateXIB.optionXIB.lblText.text = newStr
            }else {
                isDataFilled = false
            }
            if let value = model.supplier {
                self.supplierXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            if let value = model.transactionId {
                self.transactionIdXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            if let value = model.cost {
                self.costXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            self.selectedInvoiceFileName = nil
            self.selectedInvoiceImage = nil
            self.selectedInvoiceFileURL = nil
            if model.invoiceFile != nil {
                let height: CGFloat = 24
                self.downloadUploadedInvoiceBtnHeight.constant = height
                self.downloadUploadedInvoiceBtn.frame.size.height = height
                self.downloadUploadedInvoiceBtn.isHidden = false
            }else {
                let height: CGFloat = CGFloat.zero
                self.downloadUploadedInvoiceBtnHeight.constant = height
                self.downloadUploadedInvoiceBtn.frame.size.height = height
                self.downloadUploadedInvoiceBtn.isHidden = true
                isDataFilled = false
            }
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func reload_locationMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if let index = self.tabItemArray.firstIndex(where: { $0.text == locationStr }) {
            var isDataFilled = true
            
            if let value = model.position {
                self.internalExternalXIB.optionXIB.lblText.text = value
                self.selectedInternalExternal = value
                self.setupInternalExternalMenu()
            }else {
                self.reloadInternalExternalXIB()
                isDataFilled = false
            }
            if let value = model.floor?.intValue, let item = self.selectedFloorItemArray.first(where: { $0.id == value }) {
                self.floorXIB.optionXIB.lblText.text = item.nodeName ?? selectFloorStr
                self.selectedFloorId = item.id
                self.setupFloorMenu()
            }else {
                self.reloadFloorXIB()
                isDataFilled = false
            }
            if let value = model.room?.intValue, let item = self.selectedRoomItemArray.first(where: { $0.id == value }) {
                self.roomXIB.optionXIB.lblText.text = item.nodeName ?? selectRoomStr
                self.selectedRoomId = item.id
                self.setupRoomMenu()
            }else {
                self.reloadRoomXIB()
                isDataFilled = false
            }
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func reload_valuationDisposalMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if let index = self.tabItemArray.firstIndex(where: { $0.text == valuationDisposalStr }) {
            var isDataFilled = true
            if let value = model.valuationDate, let newStr = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) {
                self.valuationDateXIB.optionXIB.lblText.text = newStr
            }else {
                isDataFilled = false
            }
            if let value = model.valuationValue {
                self.valuationXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            if let value = model.valuationUserId, let item = self.userItemArray.first(where: { $0.id == value }) {
                self.selectedValuationDoneByUserId = item.id
                self.valuationDoneByXIB.optionXIB.lblText.text = item.name ?? ""
                self.setupValuationDoneByMenu()
            }else if let valuationUserName = model.valuationUserName, let item = self.userItemArray.first(where: { $0.name == valuationUserName }) {
                self.selectedValuationDoneByUserId = item.id
                self.valuationDoneByXIB.optionXIB.lblText.text = item.name ?? ""
                self.setupValuationDoneByMenu()
            }else {
                isDataFilled = false
            }
            if let value = model.disposalDate, let newStr = value.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) {
                self.disposalDateXIB.optionXIB.lblText.text = newStr
            }else {
                isDataFilled = false
            }
            if let value = model.disposalValue {
                self.disposalValueXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            if let value = model.disposalTo {
                self.disposalToXIB.tfData.text = value
            }else {
                isDataFilled = false
            }
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func reload_patDetailsMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if self.checkbox1XIB.isOn {
            if !self.tabItemArray.contains(where: { $0.text == patDetailsStr }) {
                self.tabItemArray.append((index: 4, text: patDetailsStr, isDataFilled: false))
            }
        }else {
            self.tabItemArray.removeAll { $0.text == patDetailsStr }
        }
        if let index = self.tabItemArray.firstIndex(where: { $0.text == patDetailsStr }) {
            var isDataFilled = true
            if let assetPATItems = model.assetPATItems, !assetPATItems.isEmpty {
            }else {
                isDataFilled = false
            }
            self.reload_patDetailsSpreadsheetView()
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func reload_passiveFireProtectionMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if self.checkbox2XIB.isOn {
            if !self.tabItemArray.contains(where: { $0.text == passiveFireProtectionStr }) {
                self.tabItemArray.append((index: 5, text: passiveFireProtectionStr, isDataFilled: false))
            }
        }else {
            self.tabItemArray.removeAll { $0.text == passiveFireProtectionStr }
        }
        if let index = self.tabItemArray.firstIndex(where: { $0.text == passiveFireProtectionStr }) {
            var isDataFilled = true
            if let item = model.assetPFPItem {
                if let value = item.product {
                    self.productNameXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.access {
                    self.accessPositionXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.material, let first = self.PASSIVE_FIRE_PROTECTION_ItemArray.first(where: { $0.lovValue == value }) {
                    self.selectedPASSIVE_FIRE_PROTECTION_id = first.id
                    self.materialXIB.optionXIB.lblText.text = first.lovValue
                    self.setupMaterialMenu()
                }else {
                    isDataFilled = false
                }
                if let value = item.service {
                    self.serviceXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.dimension {
                    self.dimensionXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.quantity {
                    self.quantityXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.area {
                    self.area_sq_m_XIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
            }else {
                isDataFilled = false
            }
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func reload_doorSpecificationsMainView() {
        guard let model = self.assetModel else {
            return
        }
        
        if self.checkbox3XIB.isOn {
            if !self.tabItemArray.contains(where: { $0.text == doorSpecificationsStr }) {
                self.tabItemArray.append((index: 6, text: doorSpecificationsStr, isDataFilled: false))
            }
        }else {
            self.tabItemArray.removeAll { $0.text == doorSpecificationsStr }
        }
        if let index = self.tabItemArray.firstIndex(where: { $0.text == doorSpecificationsStr }) {
            var isDataFilled = true
            if let item = model.assetDoorSpecifications {
                if let value = item.width {
                    self.doorWidth_mm_XIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.height {
                    self.doorHeight_mm_XIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.depth {
                    self.doorDepth_mm_XIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.finish {
                    self.doorFinishXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.visionPanel {
                    self.visionPanelXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.fireRating {
                    self.fireRatingXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.frameMaterial {
                    self.fireMaterialXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
                if let value = item.frameFinish {
                    self.frameFinishXIB.tfData.text = value
                }else {
                    isDataFilled = false
                }
            }else {
                isDataFilled = false
            }
            self.tabItemArray[index].isDataFilled = isDataFilled
        }
    }
    
    func showTabAtIndex(_ index: Int) {
        if self.isFieldsEditable {
            self.tabDisableUserInteractionView.isHidden = true
            self.purchaseDetailDisableUserInteractionView.isHidden = true
        }else {
            if index == 1 {
                self.tabDisableUserInteractionView.isHidden = true
                self.purchaseDetailDisableUserInteractionView.isHidden = false
            }else {
                self.tabDisableUserInteractionView.isHidden = false
                self.purchaseDetailDisableUserInteractionView.isHidden = true
            }
        }
        
        let view1: UIView! = self.purchaseDetailsMainView
        let view2: UIView! = self.locationMainView
        let view3: UIView! = self.valuationDisposalMainView
        let view4: UIView! = self.patDetailsMainView
        let view5: UIView! = self.passiveFireProtectionMainView
        let view6: UIView! = self.doorSpecificationsMainView
        
        view1.isHidden = index != 1
        view2.isHidden = index != 2
        view3.isHidden = index != 3
        view4.isHidden = index != 4
        view5.isHidden = index != 5
        view6.isHidden = index != 6
        
        let headerHeight: CGFloat = 142
        let view1Size: CGFloat = 380+self.invoiceChooseFileViewHeight.constant+self.downloadUploadedInvoiceBtnHeight.constant
        let view2Size: CGFloat = 248
        let view3Size: CGFloat = 506
        let view4Size: CGFloat = get_patDetailsMainViewHeight()
        let view5Size: CGFloat = 592
        let view6Size: CGFloat = 678
        let saveBtnViewHeight: CGFloat = self.isFieldsEditable ? 60 : 0
        
        let height: CGFloat
        switch index {
        case 1: height = view1Size
        case 2: height = view2Size
        case 3: height = view3Size
        case 4: height = view4Size
        case 5: height = view5Size
        case 6: height = view6Size
        default: height = CGFloat.zero
        }
        let totalSize = headerHeight+height+saveBtnViewHeight
        self.tabMainViewHeight.constant = totalSize
        self.tabMainView.frame.size.height = totalSize
    }
    
    @objc func openDatePickerVC(_ sender: UIButton) {
        var dateString: String?
        var selectedDate: Date?
        switch sender.tag {
        case self.purchaseDateTag:
            dateString = self.assetModel?.purchaseDate
        case self.valuationDateTag:
            dateString = self.assetModel?.valuationDate
        case self.disposalDateTag:
            dateString = self.assetModel?.disposalDate
        default:
            break
        }
        if let dateString, let date = dateString.transformToDate(dateFormat: kAssetsDateFormat) {
            selectedDate = date
        }
        self.openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate)
    }
    
    func reloadInternalExternalXIB() {
        self.internalExternalXIB.text = selectInternalExternalStr
        self.selectedInternalExternal = nil
        self.setupInternalExternalMenu()
    }
    
    func setupInternalExternalMenu() {
        let view: OptionBtnWithTitleXIB = self.internalExternalXIB
        let defaultStr = selectInternalExternalStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedInternalExternal = item
            view.text = item ?? defaultStr
            self.setupInternalExternalMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedInternalExternal == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in positionItemArray {
            let action = UIAction(title: item, state: self.selectedInternalExternal == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadFloorXIB() {
        self.floorXIB.optionXIB.lblText.text = selectFloorStr
        self.selectedFloorId = nil
        self.setupFloorMenu()
    }
    
    func setupFloorMenu() {
        let view: OptionBtnWithTitleXIB = self.floorXIB
        let defaultStr = selectFloorStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedFloorId = item?.id
            view.optionXIB.lblText.text = item?.nodeName ?? defaultStr
            self.setupFloorMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedFloorId == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedFloorItemArray {
            let action = UIAction(title: item.nodeName ?? "", state: self.selectedFloorId == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadRoomXIB() {
        self.roomXIB.optionXIB.lblText.text = selectRoomStr
        self.selectedRoomId = nil
        self.setupRoomMenu()
    }
    
    func setupRoomMenu() {
        let view: OptionBtnWithTitleXIB = self.roomXIB
        let defaultStr = selectRoomStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedRoomId = item?.id
            view.optionXIB.lblText.text = item?.nodeName ?? defaultStr
            self.setupRoomMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedRoomId == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedRoomItemArray {
            let action = UIAction(title: item.nodeName ?? "", state: self.selectedRoomId == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupValuationDoneByMenu() {
        let view: OptionBtnWithTitleXIB = self.valuationDoneByXIB
        let defaultStr = ""
        var actions: [UIMenuElement] = []
        
        let performAction: ((User?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedValuationDoneByUserId = item?.id
            view.optionXIB.lblText.text = item?.name ?? defaultStr
            self.setupValuationDoneByMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedValuationDoneByUserId == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.userItemArray {
            let action = UIAction(title: item.name ?? "", state: self.selectedValuationDoneByUserId == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadMaterialXIB() {
        self.materialXIB.optionXIB.lblText.text = selectMaterialStr
        self.selectedPASSIVE_FIRE_PROTECTION_id = nil
        self.setupMaterialMenu()
    }
    
    func setupMaterialMenu() {
        let view: OptionBtnWithTitleXIB = self.materialXIB
        let defaultStr = selectMaterialStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedPASSIVE_FIRE_PROTECTION_id = item?.id
            view.optionXIB.lblText.text = item?.lovValue ?? defaultStr
            self.setupMaterialMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedPASSIVE_FIRE_PROTECTION_id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.PASSIVE_FIRE_PROTECTION_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedPASSIVE_FIRE_PROTECTION_id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reload_patDetailsSpreadsheetView() {
        if self.addPATRecordItemArray.isEmpty, self.patDetailsItemsArray.isEmpty {
            self.patDetailsLoadingStatus = .noResponse
        }else {
            self.patDetailsLoadingStatus = .default
        }
        self.patDetailsSpreadsheetView.reloadData()
        let spreadsheetSize = self.patDetailsSpreadsheetView.contentSize
        let width = min(self.patDetailsSpreadsheetContainerView.frame.width, spreadsheetSize.width)
        self.patDetailsSpreadsheetViewWidth.constant = width
        self.patDetailsSpreadsheetView.frame.size.width = width
        let height = spreadsheetSize.height
        self.patDetailsSpreadsheetViewHeight.constant = height
        self.patDetailsSpreadsheetView.frame.size.height = height
        if self.selectedTabIndex == 4 {
            self.showTabAtIndex(self.selectedTabIndex)
        }
    }
    
    func get_patDetailsMainViewHeight() -> CGFloat {
        return self.addPATRecordMainViewHeight.constant+10+self.patDetailsSpreadsheetView.contentSize.height+10
    }
    
    func setupTesterMenu(for index: Int, cell: OptionBtnXibCell) {
        if self.addPATRecordItemArray.count > index {
            let item = self.addPATRecordItemArray[index]
            
            var actions: [UIMenuElement] = []
            let performAction: ((User) -> Void) = { [weak self] user in
                guard let self else { return }
                item.patUserId = user.id
                item.patUserName = user.name
                cell.optionXIB.lblText.text = user.name
                self.setupTesterMenu(for: index, cell: cell)
            }
            for user in self.testerUserItemArray {
                let action = UIAction(title: user.name ?? "", state: item.patUserId == user.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(user)
                }
                actions.append(action)
            }
            cell.optionXIB.btnDownClick.menu = UIMenu(title: "Select Title", children: actions)
            cell.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
        }
    }
    
    @objc func openDatePickerVCFor_patDetailsTestDate(_ sender: UIButton) {
        let index = sender.tag
        if self.addPATRecordItemArray.count > index {
            let item = self.addPATRecordItemArray[index]
            var selectedDate: Date?
            if let dateString = item.patDate, let date = dateString.transformToDate(dateFormat: kAssetsDateFormat) {
                selectedDate = date
            }
            openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate) { [weak self] date in
                guard let self else { return }
                let assetDateString = date?.transformToString(dateFormat: kAssetsDateFormat)
                item.patDate = assetDateString
                self.reload_patDetailsSpreadsheetView()
            }
        }
    }
    
    @objc func openDatePickerVCFor_patDetailsNextTestDate(_ sender: UIButton) {
        let index = sender.tag
        if self.addPATRecordItemArray.count > index {
            let item = self.addPATRecordItemArray[index]
            var selectedDate: Date?
            var minDate: Date?
            if let dateString = item.patNextDate, let date = dateString.transformToDate(dateFormat: kAssetsDateFormat) {
                selectedDate = date
            }
            if let dateString = item.patDate, let date = dateString.transformToDate(dateFormat: kAssetsDateFormat) {
                minDate = date
            }
            openDatePickerVC(sender: sender, tag: sender.tag, selectedDate: selectedDate, minDate: minDate) { [weak self] date in
                guard let self else { return }
                let assetDateString = date?.transformToString(dateFormat: kAssetsDateFormat)
                item.patNextDate = assetDateString
                self.reload_patDetailsSpreadsheetView()
            }
        }
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
    
}

//MARK: - Load Data
extension CreateNewAssetVC {
    
    func loadData() {
        //self.getAllSites()
        self.getParentFoldersFromSiteId()
    }
    
    func getAllSites() {
        let apiService = ApiService.siteAllDetails(sort: "asc", sortName: "siteName")
        
        self.loadingStatus = .loading
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CreateSiteRequestModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.getUserDetails(sites: array)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getUserDetails(sites: [CreateSiteRequestModel]) {
        guard let userID = UserConstants.shared.currentUserID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.userDetailsAPI(userId: userID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<User>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let response):
                    UserConstants.shared.userDetail = response
                    UserConstants.shared.setAllSites(from: sites)
                    self.getParentFoldersFromSiteId()
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
    
    func getParentFoldersFromSiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.documentSiteParentFoldersAPI(siteId: siteID)
        
        self.loadingStatus = .loading
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ParentFoldersResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.parentFolderItemArray = single.parentFolders ?? []
                    self.setupFolderMenu()
                    self.getSiteAssetsFromSiteId()
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
    
    func getSiteAssetsFromSiteId() {
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
                    self.assetsItemArray = single.assets ?? []
                    self.get_lovASSET_CATEGORY()
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
    
    func get_lovASSET_CATEGORY() {
        let apiService = ApiService.lovAPI(lovType: .ASSET_CATEGORY)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.ASSET_CATEGORY_ItemArray = array
                    self.setupCategoryMenu()
                    self.get_lovASSET_SUB_CATEGORY()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovASSET_SUB_CATEGORY() {
        let apiService = ApiService.lovAPI(lovType: .ASSET_SUB_CATEGORY)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.ASSET_SUB_CATEGORY_ItemArray = array
                    self.get_lovASSET_SUB_CATEGORY_2()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovASSET_SUB_CATEGORY_2() {
        let apiService = ApiService.lovAPI(lovType: .ASSET_SUB_CATEGORY_2)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.ASSET_SUB_CATEGORY_2_ItemArray = array
                    self.get_lovASSET_SUB_CATEGORY_3()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovASSET_SUB_CATEGORY_3() {
        let apiService = ApiService.lovAPI(lovType: .ASSET_SUB_CATEGORY_3)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.ASSET_SUB_CATEGORY_3_ItemArray = array
                    if self.isForCreateNew {
                        self.loadingStatus = .default
                    }else {
                        self.getSiteAssetsDetailsFromAssetId()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getSiteAssetsDetailsFromAssetId(fromUpdateSiteAssetsDetails: Bool = false) {
        guard let assetId = self.selectedAssetId else {
            if fromUpdateSiteAssetsDetails {
                self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        let apiService = ApiService.siteAssetsDetails(assetId: assetId)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetDetailsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.assetModel = single
                    if fromUpdateSiteAssetsDetails {
                        self.reloadViews()
                        self.loadingSCLAlertView.hideView()
                        SCLAlertView.showSuccessAlert(title: "", message: siteAssetHasBeenUpdatedSuccessStr, doneButtonTitle: "OK") { [weak self] in
                            guard self != nil else { return }
                        }
                    }else {
                        self.getAllUser()
                    }
                    break
                case .array:
                    if fromUpdateSiteAssetsDetails {
                        self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if fromUpdateSiteAssetsDetails {
                    self.hideLoadingAndShowError(message: failedToUpdateSiteAssetStr)
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    func getAllUser() {
        let apiService = ApiService.getAllUserData
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.userItemArray = single.users ?? []
                    self.setupValuationDoneByMenu()
                    self.getAllTesterUser()
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
    
    func getAllTesterUser() {
        let apiService = ApiService.getAllUserDataBy(userRole: .tester)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.testerUserItemArray = single.users ?? []
                    self.getSiteLayoutFromSiteID()
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
    
    func getSiteLayoutFromSiteID() {
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
                    self.reloadInternalExternalXIB()
                    self.reloadFloorXIB()
                    self.reloadRoomXIB()
                    self.get_lovPASSIVE_FIRE_PROTECTION()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovPASSIVE_FIRE_PROTECTION() {
        let apiService = ApiService.lovAPI(lovType: .PASSIVE_FIRE_PROTECTION)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.PASSIVE_FIRE_PROTECTION_ItemArray = array
                    self.reloadMaterialXIB()
                    self.reloadViews()
                    self.loadingStatus = .default
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
}

//MARK: - EmptyViewDelegate
extension CreateNewAssetVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if view == self.emptyView {
            if self.loadingStatus.shouldReload {
                self.loadData()
            }
        }
    }
}

//MARK: - CustomTextFieldDelegate
extension CreateNewAssetVC: CustomTextFieldDelegate {
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        switch view {
        case self.relatedAssetTF_XIB:
            self.reloadFilteredAssetsItemArray()
            break
        default:
            break
        }
    }
}

//MARK: - UITextFieldDelegate
extension CreateNewAssetVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.relatedAssetTF_XIB.textField:
            self.reloadFilteredAssetsItemArray()
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.relatedAssetTF_XIB.textField:
            textField.text = ""
            self.hideTagAssetsTableView()
            break
        default:
            break
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CreateNewAssetVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.relatedAssetCV:
            return self.selectedAssetsItemArray.count
        case self.tabCV:
            return self.tabItemArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.relatedAssetCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
            if self.selectedAssetsItemArray.count > indexPath.row {
                let item = self.selectedAssetsItemArray[indexPath.row]
                let tag = item.assetName?.trimmingSpacesAndLines()
                cell.lblSiteName.text = tag
                if self.isFieldsEditable {
                    cell.btnRemoveSite.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            self.selectedAssetsItemArray.remove(at: indexPath.row)
                            self.reloadRelatedAssetCV(assetId: nil)
                            self.reloadFilteredAssetsItemArray()
                        }
                    }
                }else {
                    let width = CGFloat.zero
                    cell.closeImageViewWidth.constant = width
                    cell.closeImageView.frame.size.width = width
                }
            }
            return cell
        case self.tabCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelSelectionCell", for: indexPath) as! LabelSelectionCell
            cell.mainLbl.font = UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize+2)
            
            if self.tabItemArray.count > indexPath.row {
                let item = self.tabItemArray[indexPath.row]
                cell.mainLbl.text = item.text
                cell.imageView.image = UIImage(systemName: item.isDataFilled ? "checkmark.circle" : "exclamationmark.triangle")
                
                let tintColor: UIColor
                if self.selectedTabIndex == item.index {
                    cell.selectionView.isHidden = false
                    tintColor = UIColor(appColor: .AppTint)
                }else {
                    cell.selectionView.isHidden = true
                    if item.isDataFilled {
                        tintColor = UIColor(appColor: .BLC_Lv1_Green_Border)
                    }else {
                        tintColor = UIColor(appColor: .BLC_Lv2_Yellow_Border)
                    }
                }
                cell.mainLbl.textColor = tintColor
                cell.imageView.tintColor = tintColor
            }
            return cell
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.relatedAssetCV:
            break
        case self.tabCV:
            if self.tabItemArray.count > indexPath.row {
                let item = self.tabItemArray[indexPath.row]
                self.selectedTabIndex = item.index
                self.tabCV.reloadData()
                self.tabCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.showTabAtIndex(self.selectedTabIndex)
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.relatedAssetCV:
            if self.selectedAssetsItemArray.count > indexPath.row {
                let item = self.selectedAssetsItemArray[indexPath.row]
                let text = item.assetName?.trimmingSpacesAndLines() ?? ""
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: self.isFieldsEditable ? 10+5+22+5 : 10+5+5).width
                return CGSize(width: width, height: 40)
            }
        case self.tabCV:
            if self.tabItemArray.count > indexPath.row {
                let item = self.tabItemArray[indexPath.row]
                
                let refSize = CGSize(width: 12+22+6+22+12, height: 20+20+20)
                let widthAddition: CGFloat = 12+22+6+12
                let minWidth = refSize.width-widthAddition
                
                let width = getLabelSize(text: item.text, font: UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize+2), minWidth: minWidth, widthAddition: widthAddition).width
                return CGSize(width: width, height: refSize.height)
            }
        default:
            return CGSize.zero
        }
        return CGSize.zero
    }
    
}

//MARK: - CheckboxLabelXIBDelgate
extension CreateNewAssetVC: CheckboxLabelXIBDelgate {
    func checkboxLabelXIBCheckBtnClicked(view: CheckboxLabelXIB, sender: UIButton) {
        view.isOn.toggle()
        switch view {
        case self.checkbox1XIB:
            if view.isOn {
                self.checkbox2XIB.isOn = false
                self.checkbox3XIB.isOn = false
            }
            break
        case self.checkbox2XIB:
            if view.isOn {
                self.checkbox1XIB.isOn = false
                self.checkbox3XIB.isOn = false
            }
            break
        case self.checkbox3XIB:
            if view.isOn {
                self.checkbox1XIB.isOn = false
                self.checkbox2XIB.isOn = false
            }
            break
        default:
            break
        }
    }
}

//MARK: - CAFMFilePickerDelegate
extension CreateNewAssetVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        switch tag {
        case self.assetFileTag:
            self.selectedAssetFileName = fileData.fileName
            self.selectedAssetImage = fileData.image
            self.selectedAssetFileURL = fileData.fileURL
            break
        case self.invoiceFileTag:
            self.selectedInvoiceFileName = fileData.fileName
            self.selectedInvoiceImage = fileData.image
            self.selectedInvoiceFileURL = fileData.fileURL
            break
        default:
            break
        }
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}

//MARK: - DatePickerVCDelegate
extension CreateNewAssetVC: DatePickerVCDelegate {
    func datePickerVCDidSelectDate(vc: UIViewController, date: Date?) {
        let assetDateString = date?.transformToString(dateFormat: kAssetsDateFormat)
        let dateString: String
        if let date {
            dateString = date.transformToString(dateFormat: ddMMyyyyStr)
        }else {
            dateString = ddMMyyyyStr
        }
        switch vc.view.tag {
        case self.purchaseDateTag:
            self.assetModel?.purchaseDate = assetDateString
            self.purchaseDateXIB.optionXIB.lblText.text = dateString
            break
        case self.valuationDateTag:
            self.assetModel?.valuationDate = assetDateString
            self.valuationDateXIB.optionXIB.lblText.text = dateString
            break
        case self.disposalDateTag:
            self.assetModel?.disposalDate = assetDateString
            self.disposalDateXIB.optionXIB.lblText.text = dateString
            break
        default:
            break
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension CreateNewAssetVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
}

//MARK: - SpreadsheetViewDelegate, SpreadsheetViewDataSource
extension CreateNewAssetVC: SpreadsheetViewDelegate, SpreadsheetViewDataSource {
    
    @IBAction func addPATRecordBtnClicked(_ sender: DefaultFontButton) {
        let item = AssetPATItem()
        item.assetId = self.assetModel?.assetId
        item.assetName = self.assetModel?.assetName
        self.addPATRecordItemArray.append(item)
        self.reload_patDetailsSpreadsheetView()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        switch spreadsheetView {
        case self.patDetailsSpreadsheetView:
            return self.patDetailsHeaderColumnNames.count
        default:
            return 0
        }
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch spreadsheetView {
        case self.patDetailsSpreadsheetView:
            if self.patDetailsLoadingStatus.hasData {
                return 1+self.patDetailsItemsArray.count+self.addPATRecordItemArray.count
            }else {
                return 1+1
            }
        default:
            return 0
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch spreadsheetView {
        case self.patDetailsSpreadsheetView:
            if !self.patDetailsLoadingStatus.hasData {
                let totalColumn = self.patDetailsHeaderColumnNames.count
                return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
            }else {
                return []
            }
        default:
            return []
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        switch spreadsheetView {
        case self.patDetailsSpreadsheetView:
            let column = indexPath.section
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
                if self.patDetailsHeaderColumnNames.count > column {
                    let headerText = self.patDetailsHeaderColumnNames[column]
                    
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.white
                    
                    cell.mainLbl.text = headerText
                }
                return cell
            }else if !self.patDetailsLoadingStatus.hasData {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                
                cell.backgroundColor = UIColor.white
                cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor.black
                
                cell.mainLbl.text = self.patDetailsLoadingStatus.rawValue
                return cell
            }else {
                let index = indexPath.row-1
                if column == 3 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    let refHeight = cell.stackView.frame.height
                    
                    let deleteBtn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "trash.fill"), target: self, action: #selector(self.deletePATDetails(_:)))
                    deleteBtn.tintColor = UIColor(appColor: .RedRiskScore)
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    cell.stackView.addArrangedSubview(deleteBtn)
                    return cell
                }else {
                    if self.patDetailsItemsArray.count > index {
                        let item = self.patDetailsItemsArray[index]
                        
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                        cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        
                        let text: String
                        if column == 0 {
                            text = item.patUserName ?? self.testerUserItemArray.first(where: { $0.id == item.patUserId })?.name ?? ""
                        }else if column == 1 {
                            text = item.patDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date"
                        }else if column == 2 {
                            text = item.patNextDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date"
                        }else {
                            text = ""
                        }
                        
                        cell.backgroundColor = UIColor.white
                        cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                        cell.mainLbl.textColor = UIColor.black
                        
                        cell.mainLbl.text = text
                        
                        return cell
                    }else {
                        let addIndex = index-self.patDetailsItemsArray.count
                        
                        if self.addPATRecordItemArray.count > addIndex {
                            let item = self.addPATRecordItemArray[addIndex]
                            
                            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: OptionBtnXibCell.className(), for: indexPath) as! OptionBtnXibCell
                            cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                            cell.backgroundColor = UIColor.white
                            
                            if column == 0 {
                                let text = item.patUserName ?? self.testerUserItemArray.first(where: { $0.id == item.patUserId })?.name ?? "Select Tester"
                                cell.optionXIB.lblText.text = text
                                self.setupTesterMenu(for: addIndex, cell: cell)
                            }else if column == 1 {
                                let text = item.patDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                                
                                cell.optionXIB.lblText.text = text
                                cell.optionXIB.imageView.image = UIImage(systemName: "calendar")
                                cell.optionXIB.btnDownClick.tag = addIndex
                                cell.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVCFor_patDetailsTestDate(_:)), for: .touchUpInside)
                            }else if column == 2 {
                                let text = item.patNextDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                                
                                cell.optionXIB.lblText.text = text
                                cell.optionXIB.imageView.image = UIImage(systemName: "calendar")
                                cell.optionXIB.btnDownClick.tag = addIndex
                                cell.optionXIB.btnDownClick.addTarget(self, action: #selector(self.openDatePickerVCFor_patDetailsNextTestDate(_:)), for: .touchUpInside)
                            }
                            
                            return cell
                        }
                    }
                }
            }
            return nil
        default:
            return nil
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.patDetailsHeaderColumnNames.count > column {
            let headerText = self.patDetailsHeaderColumnNames[column]
            let refSize = CGSize(width: 12+30+12, height: 10+18+10)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerWidth = getLabelSize(text: headerText, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if !self.patDetailsLoadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.patDetailsLoadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.patDetailsHeaderColumnNames.count))
            }else {
                let itemArray = self.patDetailsItemsArray
                if column == 3 {
                    return max(headerWidth, 12+40+12)
                }else {
                    var textArray: [String] = []
                    if column == 0 {
                        textArray = itemArray.compactMap({ item in
                            return item.patUserName ?? self.testerUserItemArray.first(where: { $0.id == item.patUserId })?.name ?? ""
                        })
                    }else if column == 1 {
                        textArray = itemArray.compactMap({ $0.patDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date" })
                    }else if column == 2 {
                        textArray = itemArray.compactMap({ $0.patNextDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date" })
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    if self.addPATRecordItemArray.isEmpty {
                        return max(headerWidth, maxColumnWidth)
                    }else {
                        return max(headerWidth, maxColumnWidth, 12+200+12)
                    }
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
            let headerHeight = getMaxLabelSize(textArray: self.patDetailsHeaderColumnNames, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else if !self.patDetailsLoadingStatus.hasData {
            return getLabelSize(text: self.patDetailsLoadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
        }else {
            let index = row-1
            if self.patDetailsItemsArray.count > index {
                let item = self.patDetailsItemsArray[index]
                
                let textArray = [
                    item.patUserName ?? self.testerUserItemArray.first(where: { $0.id == item.patUserId })?.name ?? "",
                    item.patDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date",
                    item.patNextDate?.transformToNewDateString(dateFormat: kAssetsDateFormat, newDateFormat: ddMMyyyyStr) ?? "Invalid date",
                ]
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight, 10+40+10)
            }else {
                let addIndex = index-self.patDetailsItemsArray.count
                if self.addPATRecordItemArray.count > addIndex {
                    return 10+40+10
                }
            }
        }
        return 0
    }
    
    @objc func deletePATDetails(_ sender: UIButton) {
        let index = sender.tag
        if self.patDetailsItemsArray.count > index {
            self.patDetailsItemsArray.remove(at: index)
            self.reload_patDetailsSpreadsheetView()
        }else {
            let addIndex = index-self.patDetailsItemsArray.count
            if self.addPATRecordItemArray.count > addIndex {
                self.addPATRecordItemArray.remove(at: index)
                self.reload_patDetailsSpreadsheetView()
            }
        }
    }
    
}
