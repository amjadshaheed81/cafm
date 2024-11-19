//
//  ViewActionVC.swift
//  cafm
//
//  Created by Savan Lakhani on 20/10/24.
//

import UIKit
import SCLAlertView
import PhotosUI

class ViewActionVC: UIViewController, CustomTextFieldDelegate, PHPickerViewControllerDelegate {

    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!

    @IBOutlet weak var actionIdMainView: UIView!
    @IBOutlet weak var actionIdSubLbl: UILabel!
    @IBOutlet weak var actionIdView: UIView!
    @IBOutlet weak var actionIdLbl: UILabel!
    
    @IBOutlet weak var dateCreatedMainView: UIView!
    @IBOutlet weak var dateCreatedSubLbl: UILabel!
    @IBOutlet weak var dateCreatedView: UIView!
    @IBOutlet weak var dateCreatedLbl: UILabel!
    
    @IBOutlet weak var dueDateMainView: UIView!
    @IBOutlet weak var dueDateSubLbl: UILabel!
    @IBOutlet weak var dueDateView: UIView!
    @IBOutlet weak var dueDatedLbl: UILabel!

    @IBOutlet weak var riskMainView: UIView!
    @IBOutlet weak var riskSubLbl: UILabel!
    @IBOutlet weak var riskView: UIView!
    @IBOutlet weak var riskLbl: UILabel!

    @IBOutlet weak var statusMainView: UIView!
    @IBOutlet weak var statusSubLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!

    @IBOutlet weak var timeRemainingMainView: UIView!
    @IBOutlet weak var timeRemainingSubLbl: UILabel!
    @IBOutlet weak var timeRemainingView: UIView!
    @IBOutlet weak var timeRemainingLbl: UILabel!
    
    @IBOutlet weak var observationTV1: UITextView!
    @IBOutlet weak var observation: DefaultFontLabel!
    
    @IBOutlet weak var requiredActionLbl: DefaultFontLabel!
    @IBOutlet weak var requiredTV2: UITextView!
    
    @IBOutlet weak var stackHolderXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var inspectionNameOptionXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var assignToXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var roomOptionXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var floorOptionXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var internalExternalOptionXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var btnSelectImage: UIButton!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var uploadFileMainView: DesignableCornerView!
    @IBOutlet weak var uploadFileHeight: NSLayoutConstraint!
    
    @IBOutlet weak var relatedAssetCV: UICollectionView!
    @IBOutlet weak var relatedAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var relatedAssetMainView: UIView!
    @IBOutlet weak var relatedAssetCVMainview: UIView!
    @IBOutlet weak var relatedAssetTF_XIB: CustomTextField!
    
    @IBOutlet weak var linkBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var imageNameLblHeight: NSLayoutConstraint!
    @IBOutlet weak var imageNameLbl: UILabel!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var commentCV: UICollectionView!
    @IBOutlet weak var commentCVMainView: UIView!
    @IBOutlet weak var commentCVHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var actionBtnView: ActionBtnViewXIB!
    
    @IBOutlet weak var addQuoteBtn: UIButton!
    
    private var isFromLinkButton = false
    
    private var tagAssetTableView: CustomTableView?
    private var tagAssetOverlayView: UIView!

    var externalInternal: InternalExternal = .selectInternalExternal
    
    private var siteLayoutDataArray: [SiteLayoutModel] = []
    private var preActionDetailArray: [PreAction] = []
    private var actionResponseModel: ActionResponseModel?
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var assetsItemArray: [AssetDetailsResponse] = []
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    private var addedCommentResponseModel: AddedCommentResponseModel?
    private var commentResonse: [CommentResponse]?
    
    private var getAllUserBySiteID: [Int: String] = [:]

    var searchAssetFloorInd = 0
    var searchAssetRoomInd = 0
    var searchAssignToUserInd = 0
    var searchStackholderInd = 0
    
    var selectedImageFile: URL?
    var selectedLinkFile: URL?
    var selectedImageFileName: String?
    
    let appendImageURL = "?sv=2023-11-03&ss=b&srt=o&se=2024-11-01T23%3A13%3A26Z&sp=r&sig=XP8wCQJCrokKmJn8qBCz42S8LKqdr93mS0qVOoY%2FM7c%3D"

    var actionId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Update/View Actions"
        self.initializedUI()
        self.getPreActionDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setScrollViewScrolling()
    }
    
    func setScrollViewScrolling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.actionBtnView.layoutIfNeeded()
            self.mainView.frame.size.height = self.actionBtnView.frame.maxY + 10
            self.scrollView.contentSize.height = self.actionBtnView.frame.maxY + 10
        }
    }
    
    func initializedUI() {
        self.uploadImageView.isHidden = true
        self.commentCV.delegate = self
        self.commentCV.dataSource = self
        
        self.imageNameLblHeight.constant = 0.0
        self.imageNameLbl.text = ""
        // Setting label texts
        let labelTextMapping = [
            actionIdLbl: "Action Id",
            dateCreatedLbl: "Date Created",
            dueDatedLbl: "Due Date",
            riskLbl: "Risk",
            statusLbl: "Status",
            timeRemainingLbl: "Time Remaining"
        ]
        
        for (label, text) in labelTextMapping {
            label?.text = text
            label?.font = UIFont(name: .MontserratRegular, size: 17)
        }
        
        // Setting titles for option XIBs
        internalExternalOptionXIB.title = "Internal/External"
        floorOptionXIB.title = "Floor"
        roomOptionXIB.title = "Room"
        stackHolderXIB.title = "Stackholder"
        assignToXIB.title = "Assign To"
        inspectionNameOptionXIB.title = "Inspection Name"
        
        // Setting default text values
        internalExternalOptionXIB.optionXIB.dummyTF.text = InternalExternal.selectInternalExternal.rawValue
        floorOptionXIB.optionXIB.dummyTF.text = "Select Floor"
        roomOptionXIB.optionXIB.dummyTF.text = "Select Room"
        inspectionNameOptionXIB.optionXIB.dummyTF.text = ""

        // Clearing lblText fields
        [internalExternalOptionXIB.optionXIB, floorOptionXIB.optionXIB, roomOptionXIB.optionXIB].forEach {
            $0.lblText.text = ""
        }
        
        self.inspectionNameOptionXIB.optionXIB.lblText.text = ""
        self.assignToXIB.optionXIB.lblText.text = ""
        self.stackHolderXIB.optionXIB.lblText.text = ""
        
        self.assignToXIB.optionXIB.dummyTF.text = "Select User"
        self.stackHolderXIB.optionXIB.dummyTF.text = "Select User"

        // Set borders and corner radius for text views
        [observationTV1, requiredTV2].forEach {
            $0.addBorder(color: .gray.withAlphaComponent(0.6))
            $0.addCorner()
        }
        
        assignToXIB.optionXIBTrailingCons.constant =  25.0
        stackHolderXIB.optionXIBTrailingCons.constant =  25.0
        
        // Delegate and data source assignments
        relatedAssetCV.delegate = self
        relatedAssetCV.dataSource = self
        relatedAssetTF_XIB.textField.placeholder = "Tag Asset"
        relatedAssetTF_XIB.textField.backgroundColor = UIColor.white
        relatedAssetTF_XIB.textField.delegate = self
        relatedAssetTF_XIB.delegate = self
        
        observationTV1.backgroundColor = UIColor(appColor: .GrayStatusBG)
        requiredTV2.backgroundColor = UIColor(appColor: .GrayStatusBG)
        inspectionNameOptionXIB.backgroundColor = UIColor(appColor: .GrayStatusBG)
        
        inspectionNameOptionXIB.optionXIB.imageView.isHidden = true
        commentCVHeight.constant = 0.0
        
        // Additional setup functions
        setUpOverlayImage()
        reloadRelatedAssetCV(assetId: nil)
        
        addQuoteBtn.addCorner()
        
        linkBtn.addCorner()
        addBtn.addCorner()
        addBtn.backgroundColor = UIColor(appColor: .GrayStatusBG)
        
        self.actionBtnView.saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.actionBtnView.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        
        // Background color and corner radius for views
        let viewsWithBackgroundColor = [
            actionIdView, dateCreatedView, dueDateView, riskView, statusView, timeRemainingView
        ]
        viewsWithBackgroundColor.forEach {
            $0?.backgroundColor = UIColor(appColor: .GrayStatusBG)
            $0?.addCorner()
        }
        
        CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.btnSelectImage, tag: 1, allowPhotos: true, supportedTypes: [.image])
        CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.linkBtn, tag: 2, allowPhotos: true, supportedTypes: [.image])
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
    
    @IBAction func linkBtnAction(_ sender: Any) {
        isFromLinkButton = true
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images // This ensures only images are shown
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        if self.selectedLinkFile != nil {
            let apiService = ApiService.postSiteCheckFileUpload
            APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
                let fileModel = self.selectedLinkFile
                 let fileName = "siteId"
                    if let fileURL = fileModel {
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
                
                if let data = "\(siteId)".data(using: .utf8) {
                    multipartFormData.append(data, withName: "siteId")
                }
            }) { [weak self] (result: Result<String, Error>) in
                guard let self else { return }
                switch result {
                case .success(let success):
                    if let text = self.commentTF.text {
                        addComments(text: text, scl: scl)
                    }else {
                        scl.hideView()
                    }
                    self.selectedLinkFile = nil
                    self.imageNameLbl.text = ""
                    break
                case .failure(let error):
                    self.selectedLinkFile = nil
                    self.imageNameLbl.text = ""
                    scl.hideView()
                }
            }
        }else {
            if let text = self.commentTF.text {
                addComments(text: text, scl: scl)
            }else {
                scl.hideView()
            }
        }
    }
    
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        switch view {
        case self.relatedAssetTF_XIB:
            self.reloadFilteredAssetsItemArray()
            break
        default:
            break
        }
    }
    
    func setUpView() {
        if let actionResponseModel = self.actionResponseModel {
            self.setInternalExternalXib()
            
            if let actionId = actionResponseModel.actionId {
                self.actionIdSubLbl.text = "\(actionId)"
            }
            self.dateCreatedSubLbl.text = actionResponseModel.createdAt
            self.statusSubLbl.text = actionResponseModel.status
            if let riskSubLbl = actionResponseModel.riskScore {
                self.riskSubLbl.text = "\(String(describing: riskSubLbl))"
            }else {
                self.riskSubLbl.text = "0"
            }
            if let dueDate = actionResponseModel.dueDate {
                self.dueDateSubLbl.text = dueDate
            }else {
                if let createdAt = actionResponseModel.createdAt, let riskScore = actionResponseModel.riskScore {
                    if let creationDate = stringToDate(createdAt) {
                        if let dueDate = getDueDate(creationDate: creationDate, riskScore: riskScore) {
                            self.dueDateSubLbl.text = dueDate
                        }
                    }
                }
            }
            if let createdAt = actionResponseModel.createdAt, let riskScore = actionResponseModel.riskScore, let creationDate = stringToDate(createdAt) {
                let (timeRemainingStatus, badgeColor) = getTimeRemaining(creationDate: creationDate, riskScore: riskScore)
                self.timeRemainingSubLbl.text = timeRemainingStatus
            }
            self.observationTV1.font = UIFont(name: .MontserratMedium, size: 15)
            self.requiredTV2.font = UIFont(name: .MontserratMedium, size: 15)
            self.observationTV1.text = actionResponseModel.observation
            self.requiredTV2.text = actionResponseModel.requiredAction
            
            if let desc = actionResponseModel.desc, !desc.isEmpty {
                self.inspectionNameOptionXIB.optionXIB.dummyTF.text = desc
            }
            if let room = actionResponseModel.room, !room.isEmpty {
                self.roomOptionXIB.optionXIB.dummyTF.text = room
            }
            let targetRoomText = self.roomOptionXIB.optionXIB.dummyTF.text
            if let index = self.siteLayoutDataArray.firstIndex(where: { item in
                item.nodeType == .room && (item.nodeName == targetRoomText)
            }) {
                self.searchAssetRoomInd = index
            }
            if let floor = actionResponseModel.floor, !floor.isEmpty {
                self.floorOptionXIB.optionXIB.dummyTF.text = floor
            }
            let targetFloorText = self.floorOptionXIB.optionXIB.dummyTF.text
            if let index = self.siteLayoutDataArray.firstIndex(where: { item in
                item.nodeType == .floor && (item.nodeName == targetFloorText)
            }) {
                self.searchAssetFloorInd = index
            }
            if let internalExternal = actionResponseModel.internalExternal, !internalExternal.isEmpty {
                self.internalExternalOptionXIB.optionXIB.dummyTF.text = internalExternal
            }
            
            if let assignedTo = actionResponseModel.assignedTo {
                self.assignToXIB.optionXIB.lblText.text = getAllUserBySiteID[assignedTo]
            }
            
            if let stakeholder = actionResponseModel.stakeholder {
                self.stackHolderXIB.optionXIB.lblText.text = getAllUserBySiteID[stakeholder]
            }
            
            if let targetString = self.assignToXIB.optionXIB.lblText.text {
                if let userId = getAllUserBySiteID.first(where: { $0.value == targetString })?.key {
                    self.searchAssignToUserInd = userId
                }
            }

            if let targetString = self.stackHolderXIB.optionXIB.lblText.text {
                if let userId = getAllUserBySiteID.first(where: { $0.value == targetString })?.key {
                    self.searchStackholderInd = userId
                }
            }

            self.timeRemainingSubLbl.textColor = .white
            self.riskSubLbl.textColor = .white
            self.statusSubLbl.textColor = .white
            
            if let status = actionResponseModel.status {
                if status.lowercased() == "reported" || status.lowercased() == "reassessed" {
                    self.timeRemainingSubLbl.backgroundColor = UIColor(appColor: .YellowRiskScore)
                    self.statusSubLbl.backgroundColor = UIColor(appColor: .YellowRiskScore)
                }else if status.lowercased() == "completed" || status.lowercased() == "default" {
                    self.timeRemainingSubLbl.backgroundColor = UIColor(appColor: .GreenRiskScore)
                    self.statusSubLbl.backgroundColor = UIColor(appColor: .GreenRiskScore)
                }
            }
            
            self.timeRemainingView.backgroundColor = self.timeRemainingSubLbl.backgroundColor
            self.statusView.backgroundColor = self.statusSubLbl.backgroundColor
            
            if let riskScore = actionResponseModel.riskScore {
                if riskScore > 16 {
                    self.riskSubLbl.backgroundColor = UIColor(appColor: .RedStatusBG)
                }else if riskScore > 9 || riskScore <= 16 {
                    self.riskSubLbl.backgroundColor = UIColor(appColor: .YellowRiskScore)
                }else if riskScore > 4 || riskScore <= 9 {
                    self.riskSubLbl.backgroundColor = UIColor.blue
                }else if riskScore <= 4 {
                    self.riskSubLbl.backgroundColor = UIColor(appColor: .GreenRiskScore)
                }
            }

            self.riskView.backgroundColor = self.riskSubLbl.backgroundColor

            if let image = actionResponseModel.actionImage {
                loadImage(from:image+appendImageURL) { image in
                    DispatchQueue.main.async {
                        if image != nil {
                            self.uploadImageView.isHidden = false
                            self.uploadImageView.image = image
                            self.uploadFileMainView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnSelectImageClicked(_ sender: Any) {
        isFromLinkButton = false
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
        self.selectedImageFileName = fileName
        
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
                        if self.isFromLinkButton {
                            self.selectedLinkFile = fileURL
                            self.imageNameLbl.text = fileName
                            self.imageNameLblHeight.constant = 30
                        }else {
                            self.selectedImageFile = fileURL
                        }
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

extension ViewActionVC {
    //setup xib
    func setAssetFloorXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Select Floor", state: searchAssetFloorInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.floorOptionXIB.optionXIB.dummyTF.text = "Select Floor"
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
    
    func setAssignToUserXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "x", state: searchAssignToUserInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.assignToXIB.optionXIB.dummyTF.text = "Select User"
                self.searchAssignToUserInd = 0
                self.setAssignToUserXib()
            }
        }))

        for (key,item) in self.getAllUserBySiteID.values.enumerated() {
            actions.append(UIAction(title: item, state: searchAssignToUserInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchAssignToUserInd = key + 1
                    self.assignToXIB.optionXIB.dummyTF.text = item
                    self.setAssignToUserXib()
                }
            }))
        }
        self.assignToXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.assignToXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setStackHolderXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Select User", state: searchStackholderInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.stackHolderXIB.optionXIB.dummyTF.text = "Select User"
                self.searchStackholderInd = 0
                self.setStackHolderXib()
            }
        }))

        for (key,item) in self.getAllUserBySiteID.values.enumerated() {
            actions.append(UIAction(title: item, state: searchStackholderInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchStackholderInd = key + 1
                    self.stackHolderXIB.optionXIB.dummyTF.text = item
                    self.setStackHolderXib()
                }
            }))
        }
        self.stackHolderXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.stackHolderXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setAssetRoomXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Select Room", state: searchAssetRoomInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.roomOptionXIB.optionXIB.dummyTF.text = "Select Room"
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
    
    @objc func saveBtnTapped() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        self.actionResponseModel?.internalExternal = self.internalExternalOptionXIB.optionXIB.dummyTF.text ?? ""
        self.actionResponseModel?.floor = self.floorOptionXIB.optionXIB.dummyTF.text ?? ""
        self.actionResponseModel?.room = self.roomOptionXIB.optionXIB.dummyTF.text ?? ""
        if self.stackHolderXIB.optionXIB.dummyTF.text?.lowercased() != "select user" {
            if let userId = self.getAllUserBySiteID.first(where: { $0.value == self.stackHolderXIB.optionXIB.dummyTF.text })?.key {
                self.actionResponseModel?.stakeholder = userId
            } else {
                self.actionResponseModel?.stakeholder = 0
            }
        }else {
            self.actionResponseModel?.stakeholder = 0
        }
        if self.assignToXIB.optionXIB.dummyTF.text?.lowercased() != "select user" {
            if let userId = self.getAllUserBySiteID.first(where: { $0.value == self.assignToXIB.optionXIB.dummyTF.text })?.key {
                self.actionResponseModel?.assignedTo = userId
            } else {
                self.actionResponseModel?.assignedTo = 0
            }
        }else {
            self.actionResponseModel?.assignedTo = 0
        }
        if let actionResponseModel = self.actionResponseModel {
            let apiService = ApiService.uploadAction(model: actionResponseModel)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
                guard let self else { return }
                switch result {
                case .success(let mappableResult):
                    if self.selectedImageFile != nil {
                        self.uploadImageAPI(scl: scl)
                    }else {
                        scl.hideView()
                        SCLAlertView.showSuccessAlert(title: "", message: "Action data saved.", doneButtonTitle: "Done") { [weak self] in
                            guard let self = self else { return }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    break
                case .failure(let error):
                    scl.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    print(apiService.api(), "Error:", error.localizedDescription)
                    //self.hideLoadingAndShowError()
                    break
                }
            }
        }
    }
    
    @objc func cancelBtnTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func uploadImageAPI(scl: SCLAlertView) {
        if selectedImageFile != nil {
            guard let siteId = UserConstants.shared.selectedSiteID else {
                return
            }
            
            let apiService = ApiService.postSiteCheckFileUpload
            APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
                let fileModel = self.selectedImageFile
                let fileName = self.selectedImageFileName
                if let fileURL = fileModel {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: APIClient.mimeType(for: fileURL))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let data = self.selectedImageFileName?.data(using: .utf8) {
                    multipartFormData.append(data, withName: "fileName")
                }
                
                if let data = "\(siteId)".data(using: .utf8) {
                    multipartFormData.append(data, withName: "siteId")
                }
            }) { [weak self] (result: Result<String, Error>) in
                guard let self else { return }
                switch result {
                case .success(let success):
                    scl.hideView()
                    self.selectedImageFile = nil
                    self.selectedImageFileName = nil
                    SCLAlertView.showSuccessAlert(title: "", message: "Action data saved.", doneButtonTitle: "Done") { [weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
                case .failure(let error):
                    scl.hideView()
                    self.selectedImageFile = nil
                    self.selectedImageFileName = nil
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }else {
            scl.hideView()
            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
        }
    }
    
}

extension ViewActionVC {
    
    func getAllUserBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        
        let apiService = ApiService.getAllUserBy(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    var formattedArray: [Int: String] = [:]
                    if let users = single.users {
                        for user in users {
                            let role = user.role ?? ""
                            let name = user.name ?? ""
                            let email = user.email ?? ""
                            let companyName = user.companyName ?? ""
                            let userId = user.id ?? 0
                            let formattedString = "\(role) - \(name) (\(email)) - \(companyName)"
                            formattedArray[userId] = formattedString
                        }
                        self.getAllUserBySiteID = formattedArray
                        if let assignedTo = self.actionResponseModel?.assignedTo {
                            self.assignToXIB.optionXIB.dummyTF.text = getAllUserBySiteID[assignedTo]
                        }
                        
                        if let stakeholder = self.actionResponseModel?.stakeholder {
                            self.stackHolderXIB.optionXIB.dummyTF.text = getAllUserBySiteID[stakeholder]
                        }
                        
                        if let targetString = self.assignToXIB.optionXIB.lblText.text {
                            if let userId = getAllUserBySiteID.first(where: { $0.value == targetString })?.key {
                                self.searchAssignToUserInd = userId
                            }
                        }

                        if let targetString = self.stackHolderXIB.optionXIB.lblText.text {
                            if let userId = getAllUserBySiteID.first(where: { $0.value == targetString })?.key {
                                self.searchStackholderInd = userId
                            }
                        }
                        
                        self.setAssignToUserXib()
                        self.setStackHolderXib()

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
    
    func addComments(text: String, scl: SCLAlertView) {
        
        let addCommentRequest = AddCommentsRequestModel()
        if let actionId = self.actionId {
            addCommentRequest.actionId = "\(actionId)"
        }
        addCommentRequest.createdAt = Date().transformToString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        addCommentRequest.date = Date().transformToString(dateFormat: "dd/MM/yyyy', 'HH:mm:ss'")
        addCommentRequest.text = text
        addCommentRequest.userId = UserConstants.shared.currentUserID ?? 0
        
        let apiService = ApiService.addComments(model: addCommentRequest)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CommentResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                scl.hideView()
                switch mappableResult {
                case .array:
                    break
                case .single(let single):
                    strongSelf.commentResonse?.append(single)
                    if strongSelf.commentCVHeight.constant == .zero {
                        strongSelf.commentCVHeight.constant = 200
                    }
                    strongSelf.commentCV.reloadData()
                    SCLAlertView().showSuccess("", subTitle: "Comment added successfully")
                    break
                }
            case .failure(let error):
                scl.hideView()
                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getSiteActionsDetailsFromIDAPI() {
        if let actionId = self.actionId {
            let apiService = ApiService.getSiteActionsDetailsFromIDAPI(id: actionId)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionResponseModel>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array:
                        break
                    case .single(let single):
                        strongSelf.actionResponseModel = single
                        strongSelf.getActionComments()
                        strongSelf.getAllUserBySiteId()
                        strongSelf.loadLayoutsData()
                        break
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getActionComments() {
        if let actionId = self.actionId {
            let apiService = ApiService.getActionComment(id: actionId)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CommentResponse>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let array):
                        strongSelf.commentResonse = array
                        if array.isEmpty {
                            strongSelf.commentCVHeight.constant = 0
                        }else {
                            strongSelf.commentCVHeight.constant = 200
                        }
                        strongSelf.commentCV.reloadData()
                        strongSelf.setScrollViewScrolling()
                        break
                    case .single(let single):
                        break
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
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
                    self?.getSiteActionsDetailsFromIDAPI()
                    if let array = single.preActions {
                        if array.isEmpty {
                        }else {
                            strongSelf.preActionDetailArray = array
                        }
                    }
                    break
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //api calling
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
                        strongSelf.setScrollViewScrolling()
                        strongSelf.setUpView()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
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
//                self.updateTagAssetTableView(for: textField)
            }
        }
    }
}

extension ViewActionVC: CAFMFilePickerDelegate {
   
   func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
       if tag == 1 {
           let fileName = fileData.fileName ?? ""
           self.selectedImageFileName = fileName
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
       }else if tag == 2 {
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
                       self.selectedLinkFile = fileURL
                       self.imageNameLbl.text = fileName
                       self.imageNameLblHeight.constant = 30
                   } catch {
                       showAlert(message: "Please try again")
                       print("Error saving image: \(error)")
                   }
               }
           }else if let fileURL = fileData.fileURL {
               self.selectedLinkFile = fileURL
               self.imageNameLbl.text = fileName
               self.imageNameLblHeight.constant = 30
           }
       }else {
           let fileName = fileData.fileName
           
           if let image = fileData.image, let fileName = fileName {
               processImage(image, fileName: fileName)
           } else if let fileURL = fileData.fileURL, let fileName =  fileName {
               processFileFromURL(fileURL, fileName: fileName)
           } else {
               showAlert(message: "No valid image or file URL provided.")
               return
           }
           //       self.chooseFileView.fileNameLbl.text = fileData.fileName
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

extension ViewActionVC {
    
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

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewActionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.relatedAssetCV:
            return self.selectedAssetsItemArray.count
        case self.commentCV:
            return self.commentResonse?.count ?? 0
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
                cell.btnRemoveSite.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        self.selectedAssetsItemArray.remove(at: indexPath.row)
                        self.reloadRelatedAssetCV(assetId: nil)
                        self.reloadFilteredAssetsItemArray()
                    }
                }
            }
            return cell
        case self.commentCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCommentsCell", for: indexPath) as! AddCommentsCell
            if let commentResonse = self.commentResonse?[indexPath.row] {
                if let name = commentResonse.user?.name {
                    cell.userNameTitle.text = name
                }
                if let createdAt = commentResonse.createdAt {
                    cell.dateLbl.text = createdAt
                }
                if let text = commentResonse.text {
                    cell.addedCommentLbl.text = text
                }
                if let image = commentResonse.image {
                    loadImage(from:image+appendImageURL) { image in
                        DispatchQueue.main.async {
                            if image != nil {
                                cell.uploadedImage.image = image
                                cell.imageViewHeightCons.constant = cell.frame.size.height - cell.addedCommentLbl.frame.maxY
                            }else {
                                cell.uploadedImage.isHidden = true
                                cell.imageViewHeightCons.constant = 0
                            }
                        }
                    }
                }else {                                cell.uploadedImage.isHidden = true
                    cell.imageViewHeightCons.constant = 0
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
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+22+5).width
                return CGSize(width: width, height: 40)
            }
        case self.commentCV:
            if (self.commentResonse?[indexPath.row].image) != nil {
                let height = getLabelSize(text: self.commentResonse?[indexPath.row].text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+5).height
                if self.commentResonse?.count == 1 {
                    self.commentCVHeight.constant = 200 + height
                }
                return CGSize(width: screenWidth - 20, height: 200 + height)
            }else {
                let height = getLabelSize(text: self.commentResonse?[indexPath.row].text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+5).height
                if self.commentResonse?.count == 1 {
                    self.commentCVHeight.constant = 56+height
                }
                return CGSize(width: screenWidth - 20, height: 56+height)
            }
        default:
            return CGSize.zero
        }
        return CGSize.zero
    }
    
}

//MARK: - UITextFieldDelegate
extension ViewActionVC: UITextFieldDelegate {
    
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

enum ViewActionStatus: String, CaseIterable {
    case `default` = "Status"
    case reported = "Reported"
    case reassessed = "Reassessed"
    case completed = "Completed"
    
    func textColor() -> UIColor {
        switch self {
        case .reported, .reassessed:
            return UIColor(appColor: .AmberStatus)
        case .completed, .default:
            return UIColor(appColor: .GreenStatus)
        }
    }
    
    func textBGColor() -> UIColor {
        switch self {
        case .reported, .reassessed:
            return UIColor(appColor: .AmberStatusBG)
        case .completed, .default:
            return UIColor(appColor: .GreenStatusBG)
        }
    }
}

class AddCommentsCell: UICollectionViewCell {
    
    @IBOutlet weak var addedCommentLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var imageViewHeightCons: NSLayoutConstraint!
}
