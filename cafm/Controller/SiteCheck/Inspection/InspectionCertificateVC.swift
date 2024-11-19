//
//  InspectionCertificateVC.swift
//  cafm
//
//  Created by NS on 2024-09-23.
//

import UIKit
import SCLAlertView

class InspectionCertificateVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var documentNameXIB: TextFiledDataXib!
    @IBOutlet weak var needReviewByXIB: TextFiledDataXib!
    @IBOutlet weak var issueDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var expiryDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var notesTV: DefaultTextView!
    @IBOutlet weak var imageFileMainView: UIView!
    @IBOutlet weak var imageFileMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadXIB: ClickToUploadXIB!
    @IBOutlet weak var imageFileCVMainView: UIView!
    @IBOutlet weak var imageFileCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageFileCV: UICollectionView!
    @IBOutlet weak var actionBtn: DefaultFontButton!
    @IBOutlet weak var disableUserInteractionView: UIView!
    
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
    
    var isViewModeEdit: Bool = false
    private var isFieldsEditable: Bool {
        return self.isViewModeEdit
    }
    
    var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    var externalUserTypeUserItemArray: [User] = []
    private var filterExternalUserTypeUserItemArray: [User] = []
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    var itemArray: [SiteCheckInspectionModel] = []
    private var selectedNeedToReviewUser: User?
    private var selectedIssueDate: Date? {
        didSet {
            self.issueDateXIB.optionXIB.lblText.text = selectedIssueDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        }
    }
    private var selectedExpiryDate: Date? {
        didSet {
            self.expiryDateXIB.optionXIB.lblText.text = selectedExpiryDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        }
    }
    private var selectedFileModel: FilePickerModel?
    
    private let issueDateTag = 1
    private let expiryDateTag = 2
    private let signOffCertifyTag = 3
    private let downloadCertificateTag = 4
    private let uploadImageFileTag = 5
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    //private let kRequestDateFormat = "yyyy-MM-dd HH:mm:ss"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let certificateSavedStr = "Certificate saved"
    
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
        self.title = "Certificate"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionBtnClicked(_ sender: DefaultFontButton) {
        if self.actionBtn.tag == self.signOffCertifyTag {
            
            let model = SiteCheckInspectionModel()
            model.siteId = UserConstants.shared.selectedSiteID
            model.status = "Open"
            model.checkId = self.siteCheckModel?.checkId
            
            self.documentNameXIB.tfData.endEditing(true)
            if let text = self.documentNameXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
                model.certificateName = text
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please enter document name", cancelButtonTitle: "OK")
                return
            }
            
            self.needReviewByXIB.tfData.endEditing(true)
            if let user = self.selectedNeedToReviewUser, let id = user.id {
                model.reviewerUserId = "\(id)"
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: "Please select reviewer user", cancelButtonTitle: "OK")
                return
            }
            
            model.issueDate = self.selectedIssueDate?.transformToString(dateFormat: kRequestDateFormat)
            model.expiryDate = self.selectedExpiryDate?.transformToString(dateFormat: kRequestDateFormat)
            model.note = self.notesTV.text.trimmingSpacesAndLinesLowercased()
            
            self.uploadSiteCheckFile(model: model) { [weak self] in
                guard self != nil else { return }
            }
        }else if self.actionBtn.tag == self.downloadCertificateTag {
            if var url = self.itemArray.first?.certificateUrl {
                if let sasToken = UserConstants.shared.sasToken {
                    url = url+"?"+sasToken
                }
                CAFMFileUtils.shared.downloadAndShareFile(url, from: self, sender: sender, shouldDeleteAfterSharing: true)
            }
        }
    }
    
}

//MARK: - EmptyViewDelegate
extension InspectionCertificateVC: EmptyViewDelegate {
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
extension InspectionCertificateVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func uploadSiteCheckFile(model: SiteCheckInspectionModel, successCompletion: @escaping SuccessCompletion) {
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckFileUpload
        APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
            let fileModel = self.selectedFileModel
            if let fileName = fileModel?.fileName {
                if let image = fileModel?.image {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: "image/jpeg")
                    }
                }else if let fileURL = fileModel?.fileURL {
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
                model.certificateUrl = success
                self.saveSiteCheckInspection(model: model, successCompletion: successCompletion)
                break
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func saveSiteCheckInspection(model: SiteCheckInspectionModel, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckInspection(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckInspectionModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.certificateId != nil {
                        self.addSiteCheckVC?.getSiteCheckInspectionBySiteId(vc: self)
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
    
    func reloadAfterGetSiteCheckInspectionBySiteId(array: [SiteCheckInspectionModel]) {
        if array.isEmpty {
            self.hideLoadingAndShowError()
        }else {
            self.itemArray = array
            self.reloadViews()
            self.loadingSCLAlertView.hideView()
            SCLAlertView().showSuccess("", subTitle: self.certificateSavedStr)
        }
    }
    
}

//MARK: - setup views
extension InspectionCertificateVC {
    
    func setupViews() {
        self.setUpSearchOverlayImage()
        
        self.documentNameXIB.title = "Document Name"
        self.documentNameXIB.tfData.placeholder = nil
        
        self.needReviewByXIB.title = "Need review by"
        self.needReviewByXIB.tfData.placeholder = nil
        self.needReviewByXIB.tfData.delegate = self
        self.needReviewByXIB.tfData.textChanged { [weak self] in
            guard let self else { return }
            self.reloadSearchTableItemArray()
        }
        
        self.issueDateXIB.title = "Issue Date"
        self.issueDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.issueDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.issueDateXIB.optionXIB.btnDownClick.tag = self.issueDateTag
        self.issueDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.issueDateXIB.optionXIB.btnDownClick
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: self.selectedIssueDate, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedIssueDate = date
            }
        }
        
        self.expiryDateXIB.title = "Expiry Date"
        self.expiryDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.expiryDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.expiryDateXIB.optionXIB.btnDownClick.tag = self.expiryDateTag
        self.expiryDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.expiryDateXIB.optionXIB.btnDownClick
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: self.selectedExpiryDate, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedExpiryDate = date
            }
        }
        
        self.notesTV.placeholder = "Enter notes ..."
        
        self.reloadViews()
    }
    
    func adjustImageFileMainView() {
        self.adjustImageFileCVMainView()
        if self.isFieldsEditable {
            self.imageFileMainViewHeight.constant = 10+160+self.imageFileCVMainViewHeight.constant
            self.imageFileMainView.frame.size.height = self.imageFileMainViewHeight.constant
            self.imageFileMainView.isHidden = false
        }else {
            self.imageFileMainViewHeight.constant = 0
            self.imageFileMainView.frame.size.height = self.imageFileMainViewHeight.constant
            self.imageFileMainView.isHidden = true
        }
    }
    
    func adjustImageFileCVMainView() {
        if selectedFileModel != nil {
            self.imageFileCVMainViewHeight.constant = 60
            self.imageFileCVMainView.frame.size.height = self.imageFileCVMainViewHeight.constant
            self.imageFileCVMainView.isHidden = false
        }else {
            self.imageFileCVMainViewHeight.constant = 0
            self.imageFileCVMainView.frame.size.height = self.imageFileCVMainViewHeight.constant
            self.imageFileCVMainView.isHidden = true
        }
    }
    
    func reloadImageFileCV() {
        self.adjustImageFileMainView()
        self.imageFileCV.reloadData()
    }
    
    func reloadViews() {
        self.isViewModeEdit = self.itemArray.isEmpty
        
        self.disableUserInteractionView.isHidden = self.isFieldsEditable
        let bgColor = self.fieldBGColor
        
        self.documentNameXIB.tfData.backgroundColor = bgColor
        self.needReviewByXIB.tfData.backgroundColor = bgColor
        self.issueDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.expiryDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.notesTV.backgroundColor = bgColor
        self.adjustImageFileMainView()
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.clickToUploadXIB.actionBtn, tag: self.uploadImageFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
            self.imageFileCV.delegate = self
            self.imageFileCV.dataSource = self
            self.actionBtn.tag = self.signOffCertifyTag
            self.actionBtn.setTitle("Sign Off & Certify", for: .normal)
            self.actionBtn.setImage(nil, for: .normal)
        }else {
            self.actionBtn.tag = self.downloadCertificateTag
            self.actionBtn.setTitle(" Download Certificate", for: .normal)
            self.actionBtn.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
        }
        
        guard let model = self.itemArray.first else { return }
        
        self.documentNameXIB.tfData.text = model.certificateName
        if let id = model.reviewerUserId, let user = self.externalUserTypeUserItemArray.first(where: { $0.id == Int(id) }) {
            self.selectedNeedToReviewUser = user
            self.needReviewByXIB.tfData.text = getUserDisplayStr(user)
        }
        if let date = model.issueDate?.transformToDate(dateFormat: kResponseDateFormat) {
            self.selectedIssueDate = date
            self.issueDateXIB.optionXIB.lblText.text = date.transformToString(dateFormat: ddMMyyyyStr)
        }
        if let date = model.expiryDate?.transformToDate(dateFormat: kResponseDateFormat) {
            self.selectedExpiryDate = date
            self.expiryDateXIB.optionXIB.lblText.text = date.transformToString(dateFormat: ddMMyyyyStr)
        }
        if let note = model.note {
            self.notesTV.text = note
        }
    }
    
}

//MARK: - Search Table View
extension InspectionCertificateVC {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        let textField: UITextField! = self.needReviewByXIB.tfData
        if textField.isEditing {
            self.updateSearchTableView(for: textField)
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
        self.searchTableView?.type = .certificateReview
        
        // Safely find the cell containing the text field
        var textFieldFrame = textField.convert(textField.bounds, to: view)
        textFieldFrame.origin.x = 20
        textFieldFrame.size.width = view.frame.width-(20+20)
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - topSafeArea - navigationHeight - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        let desiredTableViewHeight: CGFloat = CGFloat(min(filterExternalUserTypeUserItemArray.count, 5)*50)
        
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
        
        let itemArray: [User] = self.filterExternalUserTypeUserItemArray
        self.searchTableView?.isHidden = itemArray.isEmpty
        self.searchTableView?.itemArray = itemArray
        self.searchTableView?.showTableView(with: itemArray)
        view.addSubview(self.searchTableView!)
        
        self.searchTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? User {
                    self.selectedNeedToReviewUser = item
                    textField.text = getUserDisplayStr(item)
                }
            }
        }
    }
    
    func reloadSearchTableItemArray() {
        let textField: UITextField! = self.needReviewByXIB.tfData
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filterExternalUserTypeUserItemArray = self.externalUserTypeUserItemArray.filter { item in
                return (text.isEmpty || getUserDisplayStr(item)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension InspectionCertificateVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.reloadSearchTableItemArray()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.trimmingSpacesAndLines().isEmpty ?? false {
            self.selectedNeedToReviewUser = nil
        }
        if let user = self.selectedNeedToReviewUser {
            textField.text = getUserDisplayStr(user)
        }else {
            textField.text = ""
        }
        self.hideSearchTableView()
    }
}

//MARK: - CAFMFilePickerDelegate
extension InspectionCertificateVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        self.selectedFileModel = fileData
        self.reloadImageFileCV()
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension InspectionCertificateVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedFileModel != nil ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        if let selectedFileModel {
            cell.lblSiteName.text = selectedFileModel.fileName ?? "file"
            cell.btnRemoveSite.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedFileModel = nil
                    self.reloadImageFileCV()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let selectedFileModel {
            let text = selectedFileModel.fileName ?? "file"
            let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+22+5, maxWidth: collectionView.frame.width/2).width
            return CGSize(width: width, height: 40)
        }
        return CGSize.zero
    }
    
}

