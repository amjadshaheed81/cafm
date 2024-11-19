//
//  AsbestosSurveyVC.swift
//  cafm
//
//  Created by NS on 29/09/24.
//
//

import UIKit
import SCLAlertView

class AsbestosSurveyVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var surveyCompanyXIB: TextFiledDataXib!
    @IBOutlet weak var ukasLaboratoryXIB: TextFiledDataXib!
    @IBOutlet weak var reportDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var surveyReferenceNumberXIB: TextFiledDataXib!
    @IBOutlet weak var clickToUploadMainView: UIView!
    @IBOutlet weak var clickToUploadMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadXIB: ClickToUploadXIB!
    @IBOutlet weak var clickToUploadCVMainView: UIView!
    @IBOutlet weak var clickToUploadCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadCV: UICollectionView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: PrimaryButton!
    @IBOutlet weak var downloadCertificateBtn: ActionButton!
    
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
    var itemArray: [SiteCheckAsbestosSurvey] = []
    
    private var selectedReportDate: Date? {
        didSet {
            self.reportDateXIB.optionXIB.lblText.text = selectedReportDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        }
    }
    private var selectedFile: FilePickerModel?
    
    private var isFieldsEditable: Bool {
        return self.itemArray.first?.id == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    private let uploadImageFileTag = 1
    private let reportDateTag = 2
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Survey saved successfully"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Asbestos Survey"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveBtnClicked(_ sender: PrimaryButton) {
        let model = SiteCheckAsbestosSurvey()
        model.checkId = self.siteCheckModel?.checkId
        model.siteId = UserConstants.shared.selectedSiteID
        
        self.surveyCompanyXIB.tfData.endEditing(true)
        if let text = self.surveyCompanyXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.surveyCompany = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.SurveyCompany.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.ukasLaboratoryXIB.tfData.endEditing(true)
        if let text = self.ukasLaboratoryXIB.tfData.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.ukasLab = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.UKASLaboratory.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        if let text = self.selectedReportDate?.transformToString(dateFormat: kRequestDateFormat), !text.isEmpty {
            model.reportDate = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.ReportDate.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.surveyReferenceNumberXIB.tfData.endEditing(true)
        model.surveyReference = self.surveyReferenceNumberXIB.tfData.text?.trimmingSpacesAndLines() ?? "S001"
        
        if self.selectedFile != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Attachment.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.uploadSiteCheckFile(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }
    
    @IBAction func downloadCertificateBtnCicked(_ sender: ActionButton) {
        if var url = self.itemArray.first?.reportUrl {
            if let sasToken = UserConstants.shared.sasToken {
                url = url+"?"+sasToken
            }
            CAFMFileUtils.shared.downloadAndShareFile(url, from: self, sender: sender, shouldDeleteAfterSharing: true)
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "No files available to download", cancelButtonTitle: "OK")
        }
    }
    
}

//MARK: - Fields enum
extension AsbestosSurveyVC {
    enum Fields: String {
        case SurveyCompany = "Survey Company"
        case UKASLaboratory = "UKAS Laboratory"
        case ReportDate = "Report Date"
        case SurveyReferenceNumber = "Survey Reference Number"
        case Attachment = "Attachment"
        
        var placeholder: String {
            switch self {
            case .SurveyCompany: return "Enter \(self.rawValue)"
            case .UKASLaboratory: return "Enter \(self.rawValue)"
            case .ReportDate: return "dd/MM/yyyy"
            case .SurveyReferenceNumber: return "Enter \(self.rawValue)"
            case .Attachment: return "Click to upload or drag and drop PNG/JPG (max, 1MB)"
            }
        }
        
        var errorMessage: String {
            switch self {
            case .SurveyCompany: return "Please enter \(self.rawValue)"
            case .UKASLaboratory: return "Please enter \(self.rawValue)"
            case .ReportDate: return "Please enter \(self.rawValue)"
            case .SurveyReferenceNumber: return "Please enter \(self.rawValue)"
            case .Attachment: return "Please select \(self.rawValue)"
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension AsbestosSurveyVC: EmptyViewDelegate {
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
extension AsbestosSurveyVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func uploadSiteCheckFile(model: SiteCheckAsbestosSurvey, successCompletion: @escaping SuccessCompletion) {
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckFileUpload
        APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
            let fileModel = self.selectedFile
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
                model.reportUrl = success
                self.saveSiteCheckInspection(model: model, successCompletion: successCompletion)
                break
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func saveSiteCheckInspection(model: SiteCheckAsbestosSurvey, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckAsbestosSurvey(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAsbestosSurvey>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.id != nil {
                        self.addSiteCheckVC?.getSiteCheckAsbestosSurveyByCheckId(vc: self)
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
    
    func reloadAfterGetSiteCheckAsbestosSurveyByCheckId(array: [SiteCheckAsbestosSurvey]) {
        if array.isEmpty {
            self.hideLoadingAndShowError()
        }else {
            self.itemArray = array
            self.reloadViews()
            self.loadingSCLAlertView.hideView()
            SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
        }
    }
    
}

//MARK: - setup views
extension AsbestosSurveyVC {
    
    func setupViews() {
        self.surveyCompanyXIB.title = Fields.SurveyCompany.rawValue
        self.ukasLaboratoryXIB.title = Fields.UKASLaboratory.rawValue
        self.reportDateXIB.title = Fields.ReportDate.rawValue
        self.surveyReferenceNumberXIB.title = Fields.SurveyReferenceNumber.rawValue
        
        self.reportDateXIB.optionXIB.lblText.text = ddMMyyyyStr
        self.reportDateXIB.optionXIB.imageView.image = UIImage(systemName: "calendar")
        self.reportDateXIB.optionXIB.btnDownClick.tag = self.reportDateTag
        self.reportDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.reportDateXIB.optionXIB.btnDownClick
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: self.selectedReportDate, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedReportDate = date
            }
        }
        
        self.surveyReferenceNumberXIB.isUserInteractionEnabled = false
        self.surveyReferenceNumberXIB.tfData.backgroundColor = UIColor(appColor: .GrayStatusBG)
        self.surveyReferenceNumberXIB.tfData.text = "S001"
        
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.clickToUploadXIB.actionBtn, tag: self.uploadImageFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
            self.clickToUploadCV.delegate = self
            self.clickToUploadCV.dataSource = self
        }
        
        self.reloadViews()
    }
    
    func reloadViews() {
        let bgColor = self.fieldBGColor
        
        self.surveyCompanyXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.surveyCompanyXIB.tfData.backgroundColor = bgColor
        self.ukasLaboratoryXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ukasLaboratoryXIB.tfData.backgroundColor = bgColor
        self.reportDateXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.reportDateXIB.optionXIB.dummyTF.backgroundColor = bgColor
        
        self.adjustClickToUploadMainView()
        
        self.saveBtn.isHidden = !self.isFieldsEditable
        self.downloadCertificateBtn.isHidden = !self.saveBtn.isHidden
        
        guard let model = self.itemArray.first else { return }
        self.surveyCompanyXIB.tfData.text = model.surveyCompany
        self.ukasLaboratoryXIB.tfData.text = model.ukasLab
        if let date = model.reportDate?.transformToDate(dateFormat: kResponseDateFormat) {
            self.selectedReportDate = date
            self.reportDateXIB.optionXIB.lblText.text = date.transformToString(dateFormat: ddMMyyyyStr)
        }
        self.surveyReferenceNumberXIB.tfData.text = model.surveyReference
    }
    
    func adjustClickToUploadMainView() {
        self.adjustClickToUploadCVMainView()
        if self.isFieldsEditable {
            self.clickToUploadMainViewHeight.constant = 10+160+self.clickToUploadCVMainViewHeight.constant
            self.clickToUploadMainView.frame.size.height = self.clickToUploadMainViewHeight.constant
            self.clickToUploadMainView.isHidden = false
        }else {
            self.clickToUploadMainViewHeight.constant = 0
            self.clickToUploadMainView.frame.size.height = self.clickToUploadMainViewHeight.constant
            self.clickToUploadMainView.isHidden = true
        }
    }
    
    func adjustClickToUploadCVMainView() {
        if self.selectedFile != nil {
            self.clickToUploadCVMainViewHeight.constant = 50
            self.clickToUploadCVMainView.frame.size.height = self.clickToUploadCVMainViewHeight.constant
            self.clickToUploadCVMainView.isHidden = false
        }else {
            self.clickToUploadCVMainViewHeight.constant = 0
            self.clickToUploadCVMainView.frame.size.height = self.clickToUploadCVMainViewHeight.constant
            self.clickToUploadCVMainView.isHidden = true
        }
    }
    
    func reloadClickToUploadCV() {
        self.adjustClickToUploadMainView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.clickToUploadCV.reloadData()
        }
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension AsbestosSurveyVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        self.selectedFile = fileData
        self.reloadClickToUploadCV()
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AsbestosSurveyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedFile != nil ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        if let selectedFileModel = self.selectedFile {
            cell.lblSiteName.text = selectedFileModel.fileName ?? "file"
            cell.btnRemoveSite.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedFile = nil
                    self.reloadClickToUploadCV()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let selectedFileModel = self.selectedFile {
            let text = selectedFileModel.fileName ?? "file"
            let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+22+5, maxWidth: collectionView.frame.width/2).width
            return CGSize(width: width, height: 40)
        }
        return CGSize.zero
    }
    
}
