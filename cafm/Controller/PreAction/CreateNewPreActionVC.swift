//
//  CreateNewPreActionVC.swift
//  cafm
//
//  Created by Savan Lakhani on 06/10/24.
//

import UIKit
import PhotosUI
import SCLAlertView

enum PreActionType {
    case createNew
    case viewOnly
    case markAsApproved
    case markAsClosed
}

enum InternalExternal: String {
    case selectInternalExternal = "Select Internal/External"
    case `internal` = "internal"
    case external = "external"
}

class CreateNewPreActionVC: UIViewController, CAFMFilePickerDelegate {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var btnSelectImage: UIButton!
    
    @IBOutlet weak var uploadFileMainView: DesignableCornerView!
    @IBOutlet weak var uploadFileHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomActionView: UIView!
    
    @IBOutlet weak var relatedAssetCV: UICollectionView!
    @IBOutlet weak var relatedAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var relatedAssetMainView: UIView!
    @IBOutlet weak var relatedAssetCVMainview: UIView!
    @IBOutlet weak var relatedAssetTF_XIB: CustomTextField!
    
    @IBOutlet weak var roomOptionXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var floorOptionXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var internalExternalOptionXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var enterNotsTV1: UITextView!
    @IBOutlet weak var enterNotesTV2: UITextView!
    
    @IBOutlet weak var chooseFileMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseFileMainView: UIView!
    @IBOutlet weak var chooseFileView: ChooseFileCapsuleXIB!
    @IBOutlet weak var chooseFileViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var enterNotesTV2Height: NSLayoutConstraint!
    @IBOutlet weak var enterNotesTV2Top: NSLayoutConstraint!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var saveBtnWidth: NSLayoutConstraint!
    
    var preActionID: Int?
    
    var preActionType: PreActionType = .createNew
    
    private var assetsItemArray: [AssetDetailsResponse] = []
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var siteLayoutDataArray: [SiteLayoutModel] = []
    private var preActionResponse: PreAction?
    
    private var tagAssetOverlayView: UIView!
    private var tagAssetTableView: CustomTableView?
    
    var searchAssetFloorInd = 0
    var searchAssetRoomInd = 0
    
    var actionId: Int? = nil
    
    private var keyBoardHeight: CGFloat = 0.0
    
    var selectedImageFile: URL?
    
    var externalInternal: InternalExternal = .selectInternalExternal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseFileView.isHidden = true
        self.chooseFileViewHeight.constant = 0.0
        self.chooseFileMainView.isHidden = true
        self.chooseFileMainViewHeight.constant = 0.0
        CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.btnSelectImage, tag: 1, allowPhotos: true, supportedTypes: [.image])
        if self.preActionType == .createNew {
            self.title = "Create New Pre-Action"
            self.uploadImageView.isHidden = true
            self.saveBtn.setTitle("SAVE", for: .normal)
        }else {
            self.uploadFileMainView.isHidden = true
            if self.preActionType == .viewOnly {
                self.title = "Update/View Pre Actions"
            }else if self.preActionType == .markAsApproved {
                self.title = "Approve Pre Action"
                self.saveBtn.setTitle("APPROVE & CREATE ACTION", for: .normal)
                self.saveBtnWidth.constant = 260
            }else if self.preActionType == .markAsClosed {
                self.title = "Pre-Action Closure"
                self.saveBtn.setTitle("MARK AS CLOSED", for: .normal)
                self.saveBtnWidth.constant = 180
                self.chooseFileView.isHidden = false
                self.chooseFileViewHeight.constant = 50.0
                self.chooseFileMainView.isHidden = false
                self.chooseFileMainViewHeight.constant = 80
                CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.chooseFileView.chooseFileBtn, tag: 0, allowPhotos: true, supportedTypes: [.image, .pdf])
            }
        }
        self.initailizeUI()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setScrollViewScrolling()
    }
    
    func setScrollViewScrolling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.bottomActionView.layoutIfNeeded()
            self.mainView.frame.size.height = self.bottomActionView.frame.maxY + 10
            self.scrollView.contentSize.height = self.bottomActionView.frame.maxY + 10
        }
    }
    
    func setInternalExternalXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: InternalExternal.selectInternalExternal.rawValue, state: externalInternal == .selectInternalExternal ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.externalInternal = .selectInternalExternal
                self.internalExternalOptionXIB.optionXIB.dummyTF.text = InternalExternal.selectInternalExternal.rawValue
                self.setInternalExternalXib()
            }
        }))
        actions.append(UIAction(title: InternalExternal.internal.rawValue, state: externalInternal == .internal ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.externalInternal = .internal
                self.internalExternalOptionXIB.optionXIB.dummyTF.text = InternalExternal.internal.rawValue
                self.setInternalExternalXib()
            }
        }))
        actions.append(UIAction(title: InternalExternal.external.rawValue, state: externalInternal == .external ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.externalInternal = .external
                self.internalExternalOptionXIB.optionXIB.dummyTF.text = InternalExternal.external.rawValue
                self.setInternalExternalXib()
            }
        }))
        
        self.internalExternalOptionXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.internalExternalOptionXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func initailizeUI() {
        self.internalExternalOptionXIB.title = "Internal/External"
        self.floorOptionXIB.title = "Floor"
        self.roomOptionXIB.title = "Room"
        
        self.internalExternalOptionXIB.optionXIB.dummyTF.text = InternalExternal.selectInternalExternal.rawValue
        self.floorOptionXIB.optionXIB.dummyTF.text = "Floor"
        self.roomOptionXIB.optionXIB.dummyTF.text = "Room"
        
        self.internalExternalOptionXIB.optionXIB.lblText.text = ""
        self.floorOptionXIB.optionXIB.lblText.text = ""
        self.roomOptionXIB.optionXIB.lblText.text = ""
        
        self.enterNotsTV1.text = "Enter Notes..."
        self.enterNotsTV1.addBorder(color: .gray.withAlphaComponent(0.6))
        self.enterNotsTV1.addCorner()
        self.enterNotsTV1.delegate = self
        
        self.enterNotesTV2.text = "Enter Notes..."
        self.enterNotesTV2.addBorder(color: .gray.withAlphaComponent(0.6))
        self.enterNotesTV2.addCorner()
        self.enterNotesTV2.delegate = self
        
        self.cancelBtn.titleLabel?.font = UIFont(name: .MontserratSemiBold, size: 15)
        self.saveBtn.titleLabel?.font = UIFont(name: .MontserratSemiBold, size: 15)
        
        if self.preActionType == .createNew || self.preActionType == .viewOnly {
            self.enterNotesTV2Height.constant = 0.0
            self.enterNotesTV2Top.constant = 0.0
        }
        
        addCornerToView(self.cancelBtn)
        addCornerToView(self.saveBtn)
        
        let bgColor = self.preActionType == .createNew ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        //delegate datasource
        self.relatedAssetCV.delegate = self
        self.relatedAssetCV.dataSource = self
        self.relatedAssetTF_XIB.textField.placeholder = "Tag Asset"
        self.relatedAssetTF_XIB.textField.backgroundColor = bgColor
        self.relatedAssetTF_XIB.textField.delegate = self
        self.relatedAssetTF_XIB.delegate = self
        if self.preActionType != .createNew {
            self.relatedAssetTF_XIB.textField.isEnabled = false
        }
        setUpOverlayImage()
        reloadRelatedAssetCV(assetId: nil)
        
        self.setInternalExternalXib()
        
        if self.preActionType == .viewOnly || self.preActionType == .markAsClosed || self.preActionType == .markAsApproved {
            self.getPreActionDetails()
            self.getSiteAssetsBySiteId()
        }else {
            //api setup
            self.getSiteAssetsFromSiteId()
            self.loadLayoutsData()
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
    
    @objc func hideTagAssetsTableView() {
        self.tagAssetOverlayView.isHidden = true
        self.tagAssetTableView?.isHidden = true
        self.tagAssetTableView?.hideTableView()
    }
    
    func showTagAssetsTableView() {
        self.tagAssetOverlayView.isHidden = false
        self.tagAssetTableView?.isHidden = false
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
    
    func reloadRelatedAssetCV(assetId: Int?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let assetId, let item = self.assetsItemArray.first(where: { $0.assetId == assetId }) {
                self.selectedAssetsItemArray.insert(item, at: 0)
            }
            
            if self.selectedAssetsItemArray.isEmpty {
                let height: CGFloat = CGFloat.zero
                self.relatedAssetCVMainview.isHidden = true
                self.relatedAssetCVMainViewHeight.constant = height
                self.relatedAssetCVMainview.frame.size.height = height
            }else {
                let height: CGFloat = 50
                self.relatedAssetCVMainview.isHidden = false
                self.relatedAssetCVMainViewHeight.constant = height
                self.relatedAssetCVMainview.frame.size.height = height
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.relatedAssetCV.reloadData()
                completion?()
            }
        }
    }
    
    func setupViewOnlyView(preActionsResponse: [PreAction]) {
        self.preActionResponse = preActionsResponse.first
        let viewOnlyBGColor = UIColor(appColor: .GrayStatusBG)
        self.internalExternalOptionXIB.optionXIB.dummyTF.backgroundColor = viewOnlyBGColor
        self.floorOptionXIB.optionXIB.dummyTF.backgroundColor = viewOnlyBGColor
        self.roomOptionXIB.optionXIB.dummyTF.backgroundColor = viewOnlyBGColor
        self.enterNotsTV1.backgroundColor = viewOnlyBGColor
        self.cancelBtn.titleLabel?.text = "Back"
        
        self.internalExternalOptionXIB.optionXIB.dummyTF.text = "External"
        self.floorOptionXIB.optionXIB.dummyTF.text = preActionsResponse.first?.floor
        self.roomOptionXIB.optionXIB.dummyTF.text = preActionsResponse.first?.room
        self.enterNotsTV1.text = preActionsResponse.first?.description
        self.uploadFileMainView.isHidden = true
        self.uploadFileHeight.constant = 200.0
        self.preActionID = preActionsResponse.first?.actionId
        
        if let image = preActionsResponse.first?.image, let url = URL(string: image) {
            downloadAndSaveImage(from: url) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch result {
                    case .success(let image):
                        self.uploadImageView.image = image
                    case .failure(let error):
                        print("Error downloading the image: \(error)")
                    }
                }
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
                        if let tagAssets = self.preActionResponse?.taggedAsset {
                            let filteredAssetNames = array.compactMap { asset -> String? in
                                if let assetId = asset.assetId, let assetName = asset.assetName {
                                    if tagAssets.contains(String(assetId)) {
                                        return assetName
                                    }
                                }
                                return nil
                            }
                            let result = filteredAssetNames.joined(separator: ", ")
                            self.relatedAssetTF_XIB.textField.text = result
                        }
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
    
    func getPreActionDetails() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        
        let apiService = ApiService.getPreActionSummaryDetail(taggedSiteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<PreActionsResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    break
                case .single(let single):
                    if let array = single.preActions {
                        if array.isEmpty {
                        }else {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.setupViewOnlyView(preActionsResponse: array.filter({$0.actionId == self.actionId}))
                            }
                        }
                    }
                    break
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getSiteAssetsFromSiteId() {
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
                    self.assetsItemArray = single.assets ?? []
                    break
                case .array:
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func loadLayoutsData() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        
        let apiService = ApiService.siteLayoutAPI(siteId: siteID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteLayoutModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    if !array.isEmpty {
                        strongSelf.siteLayoutDataArray = array
                        strongSelf.setAssetFloorXib()
                        strongSelf.setAssetRoomXib()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func setAssetFloorXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Floor", state: searchAssetFloorInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.floorOptionXIB.optionXIB.dummyTF.text = "Floor"
                self.searchAssetFloorInd = 0
                self.setAssetFloorXib()
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.siteLayoutDataArray.enumerated() {
            if item.nodeType == .floor {
                let floor = item.nodeName ?? "No floor"
                
                if seenAreas.contains(floor) {
                    continue
                }
                
                seenAreas.insert(floor)
                
                actions.append(UIAction(title: floor, state: searchAssetFloorInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchAssetFloorInd = key + 1
                        self.floorOptionXIB.optionXIB.dummyTF.text = item.nodeName
                        self.setAssetFloorXib()
                    }
                }))
            }
        }
        self.floorOptionXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.floorOptionXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setAssetRoomXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Room", state: searchAssetRoomInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.roomOptionXIB.optionXIB.dummyTF.text = "Room"
                self.searchAssetRoomInd = 0
                self.setAssetRoomXib()
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.siteLayoutDataArray.enumerated() {
            if item.nodeType == .room {
                let room = item.nodeName ?? "No Room"
                
                if seenAreas.contains(room) {
                    continue
                }
                
                seenAreas.insert(room)
                
                actions.append(UIAction(title: room, state: searchAssetRoomInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchAssetRoomInd = key + 1
                        self.roomOptionXIB.optionXIB.dummyTF.text = item.nodeName
                        self.setAssetRoomXib()
                    }
                }))
            }
        }
        self.roomOptionXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.roomOptionXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func saveBtnActionClicked(_ sender: Any) {
        if self.preActionType == .createNew {
            guard self.internalExternalOptionXIB.optionXIB.dummyTF.text != InternalExternal.selectInternalExternal.rawValue else {
                SCLAlertView().showError("Error", subTitle: "Please select category")
                return
            }
            
            guard self.floorOptionXIB.optionXIB.dummyTF.text?.lowercased() != "Floor".lowercased() else {
                SCLAlertView().showError("Error", subTitle: "Please select floor")
                return
            }
            
            guard self.roomOptionXIB.optionXIB.dummyTF.text?.lowercased() != "room".lowercased() else {
                SCLAlertView().showError("Error", subTitle: "Please select room")
                return
            }
            
            if selectedImageFile == nil {
                showAlert(message: "Please select the file")
                return
            }
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let scl = SCLAlertView(appearance: appearance)
            scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
            
            let req = CreatePreActionRequestModel()
            req.category = self.internalExternalOptionXIB.optionXIB.dummyTF.text
            req.floor = self.floorOptionXIB.optionXIB.dummyTF.text
            req.room = self.roomOptionXIB.optionXIB.dummyTF.text
            req.description = self.enterNotsTV1.text != "Enter Notes..." ? self.enterNotsTV1.text : ""
            req.status = "Pending"
            req.raisedByUserId = UserConstants.shared.currentUserID
            req.actionId = nil
            
            var stringsArray = [String]()
            
            stringsArray = self.selectedAssetsItemArray.compactMap { item in
                if let actionId = item.assetId {
                    return String(actionId)
                }
                return nil
            }
            
            let resultString = stringsArray.joined(separator: ", ")
            req.taggedAsset = resultString
            
            guard let selectedSiteID = UserConstants.shared.selectedSiteID else { return }
            guard let fileURL = self.selectedImageFile else { return }
            
            let api = ApiService.createPreAction(actionId: selectedSiteID)
            
            APIClient.requestMultipart(api) { multipartFormData in
                do {
                    let data = try Data(contentsOf: fileURL)
                    multipartFormData.append(data, withName: "actionImage", fileName: "images.jpeg", mimeType: APIClient.mimeType(for: fileURL))
                } catch {
                    print(error.localizedDescription)
                }
                do {
                    var json = req.toJSON()
                    let data = try JSONSerialization.data(withJSONObject: json, options: [])
                    multipartFormData.append(data, withName: "actionRequestString")
                } catch {
                    print(error.localizedDescription)
                }
            } completion: { [weak self] (result: Result<APIClient.MappableResult<CreatePreActrionResponseModel>, Error>) in
                guard let self else { return }
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        print(responseResult.toJSON())
                        scl.hideView()
                        let sclAlertView = SCLAlertView()
                        sclAlertView.showSuccess("", subTitle: "Pre action details has been successfully saved.")
                        self.selectedImageFile = nil
                    }else {
                        scl.hideView()
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }else if self.preActionType == .markAsClosed {
            guard let actionId = self.preActionID else { return }
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let scl = SCLAlertView(appearance: appearance)
            scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
            let api = ApiService.closePreAction(actionId: actionId)
            
            let statusRequestModel = StatusRequestModel()
            statusRequestModel.status = "Closed"
            statusRequestModel.actionTaken = self.enterNotesTV2.text
            
            APIClient.requestMultipart1(api) { multipartFormData in
                let fileURL = self.selectedImageFile
                do {
                    if let fileURL = fileURL {
                        let data = try Data(contentsOf: fileURL)
                        multipartFormData.append(data, withName: "actionImage", fileName: "actionImage", mimeType: APIClient.mimeType(for: fileURL))
                    }
                } catch {
                    print(error.localizedDescription)
                }
                do {
                    var json = statusRequestModel.toJSON()
                    let data = try JSONSerialization.data(withJSONObject: json, options: [])
                    multipartFormData.append(data, withName: "closeActionRequestString")
                } catch {
                    print(error.localizedDescription)
                }
            } completion: { [weak self] (result: Result<Bool, Error>) in
                guard let self else { return }
                switch result {
                case .success(let responseResult):
                    scl.hideView()
                    let sclAlertView = SCLAlertView()
                    sclAlertView.showSuccess("", subTitle: "Successfully closed the pre action.")
                case .failure(let error):
                    print(error.localizedDescription)
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }else if self.preActionType == .markAsApproved {
            let vc = preActionSB.instantiateViewController(withIdentifier: "ApprovePreActionVC") as! ApprovePreActionVC
            vc.preActionResponse = self.preActionResponse
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func cancelBtnActionClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectImageClicked(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images // This ensures only images are shown
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func handlePickedImage(_ pickedImage: UIImage, fromURL fileURL: URL) {
        // Implement the logic you had for handling a single image
        // Fetch the file name from the URL
        let fileName = fileURL.lastPathComponent
        print("Selected image name: \(fileName)")
        
        // Check the image size and proceed similarly to your original code
        if let imageData = pickedImage.jpegData(compressionQuality: 0.8) {
            let imageSize = imageData.count
            let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if imageSize > maxFileSize {
                    // Image size exceeds 1 MB, show an alert
                    showAlert(message: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                } else {
                    print("Image size is within the limit: \(imageSize) bytes")
                    let name = (fileName as NSString).deletingPathExtension
                    let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                    let fileURL = documentDirectory().appendingPathComponent(newfileName)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            showAlert(message: "Please try again")
                            return
                        }
                    }
                    do {
                        try imageData.write(to: fileURL, options: .atomic)
                        self.selectedImageFile = fileURL
                    } catch {
                        showAlert(message: "Please try again")
                        print("Error saving image: \(error)")
                    }
                }
            }
        }
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
                                self?.showAlert(message: "Please try again")
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

}
 
extension CreateNewPreActionVC {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        if tag == 0 {
            let fileName = fileData.fileName
            
            if let image = fileData.image, let fileName = fileName {
                processImage(image, fileName: fileName)
            } else if let fileURL = fileData.fileURL, let fileName =  fileName {
                processFileFromURL(fileURL, fileName: fileName)
            } else {
                showAlert(message: "No valid image or file URL provided.")
                return
            }
            
            self.chooseFileView.fileNameLbl.text = fileData.fileName
        }else {
            let fileName = fileData.fileName ?? ""
            if let imageData = fileData.image?.jpegData(compressionQuality: 0.8) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let name = (fileName as NSString).deletingPathExtension
                    let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                    let fileURL = documentDirectory().appendingPathComponent(newfileName)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            showAlert(message: "Please try again")
                            return
                        }
                    }
                    do {
                        try imageData.write(to: fileURL, options: .atomic)
                        self.selectedImageFile = fileURL
                    } catch {
                        showAlert(message: "Please try again")
                        print("Error saving image: \(error)")
                    }
                }
            }else if let fileURL = fileData.fileURL {
                self.selectedImageFile = fileURL
            }
        }
    }
    
    func filePickerDidClose(tag: Int) {
        
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

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CreateNewPreActionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.relatedAssetCV:
            return self.selectedAssetsItemArray.count
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
                if self.self.preActionType == .createNew {
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
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.relatedAssetCV:
            break
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
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: self.preActionType == .createNew ? 10+5+22+5 : 10+5+5).width
                return CGSize(width: width, height: 40)
            }
        default:
            return CGSize.zero
        }
        return CGSize.zero
    }
    
}

//MARK: - CustomTextFieldDelegate
extension CreateNewPreActionVC: CustomTextFieldDelegate {
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
extension CreateNewPreActionVC: UITextFieldDelegate {
    
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

extension CreateNewPreActionVC: PHPickerViewControllerDelegate {
    
}

extension CreateNewPreActionVC: UITextViewDelegate {
    
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

extension CreateNewPreActionVC {
    
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
