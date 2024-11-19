//
//  MonthlyAuditQuestionResponseVC.swift
//  cafm
//
//  Created by NS on 12/11/24.
//
//

import UIKit
import SCLAlertView

class MonthlyAuditQuestionResponseVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    
    @IBOutlet weak var TotalAssetXIB: TextFiledDataXib!
    @IBOutlet weak var RemainingAssetXIB: TextFiledDataXib!
    @IBOutlet weak var ObservationXIB: TextViewWithTitleXIB!
    @IBOutlet weak var SuggestedActionXIB: TextViewWithTitleXIB!
    @IBOutlet weak var ConsequenceXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var LikelihoodXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var totalRiskScoreLbl: UILabel!
    
    @IBOutlet weak var AssetOKMainView: UIView!
    @IBOutlet weak var AssetOKCV: UICollectionView!
    @IBOutlet weak var AssetOKCVMainView: UIView!
    @IBOutlet weak var AssetOKCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AssetOKXIB: CustomTextField!
    @IBOutlet weak var DefectiveAssetMainView: UIView!
    @IBOutlet weak var DefectiveAssetCV: UICollectionView!
    @IBOutlet weak var DefectiveAssetCVMainView: UIView!
    @IBOutlet weak var DefectiveAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var DefectiveAssetXIB: CustomTextField!
    
    @IBOutlet weak var clickToUploadMainView: UIView!
    @IBOutlet weak var clickToUploadMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadXIB: ClickToUploadXIB!
    @IBOutlet weak var clickToUploadCVMainView: UIView!
    @IBOutlet weak var clickToUploadCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadCV: UICollectionView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadAttachmentBtn: ActionButton!
    @IBOutlet weak var saveContinueBtn: PrimaryButton!
    
    private var searchTableView: CustomTableView?
    private var searchOverlayView: UIView!
    private var keyBoardHeight: CGFloat = 0.0
    
    private var selectedAssetOKItemArray: [AssetDetailsResponse] = []
    private var filteredAssetOKItemArray: [AssetDetailsResponse] = []
    private var selectedDefectiveAssetItemArray: [AssetDetailsResponse] = []
    private var filteredDefectiveAssetItemArray: [AssetDetailsResponse] = []
    
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
    
    private var isFieldsEditable: Bool {
        return self.response?.responseId == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    weak var monthlyAuditQuestionsVC: MonthlyAuditQuestionsVC?
    var question: SiteCheckAssessmentQuestions?
    var response: SiteCheckAssessmentResponse?
    var assetsItemArray: [AssetDetailsResponse] = []
    
    private let uploadImageFileTag = 1
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Assessment response saved successfully"
    
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
        self.title = self.question?.order ?? "Question"
    }
    
    @IBAction func downloadAttachmentBtnClicked(_ sender: ActionButton) {
        if var url = self.response?.file {
            if let sasToken = UserConstants.shared.sasToken {
                url = url+"?"+sasToken
            }
            CAFMFileUtils.shared.downloadAndShareFile(url, from: self, sender: sender, shouldDeleteAfterSharing: true)
        }
    }
    
    @IBAction func saveContinueBtnClicked(_ sender: PrimaryButton) {
        guard let response else { return }
        let model = SiteCheckAssessmentResponse()
        
        if !self.selectedAssetOKItemArray.isEmpty {
            model.assets = self.selectedAssetOKItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
        }
        if !self.selectedDefectiveAssetItemArray.isEmpty {
            model.faultassets = self.selectedDefectiveAssetItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
        }
        
        self.ObservationXIB.textView.hideEditing()
        if let text = self.ObservationXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.observation = text
            //model.position = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Observation.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.SuggestedActionXIB.textView.hideEditing()
        if let text = self.SuggestedActionXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.action = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.SuggestedAction.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        if let selectedFile = response.selectedFile {
            model.selectedFile = selectedFile
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "", cancelButtonTitle: "OK")
            return
        }
        if let value = response.consequence {
            model.consequence = value
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Consequence.errorMessage, cancelButtonTitle: "OK")
            return
        }
        if let value = response.likelihood {
            model.likelihood = value
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Likelihood.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        model.siteId = UserConstants.shared.selectedSiteID
        model.responseDate = Date().transformToString(dateFormat: kRequestDateFormat)
        model.checkId = self.monthlyAuditQuestionsVC?.siteCheckModel?.checkId
        model.qid = self.question?.qid
        model.totalRiskScore = (model.consequence?.intValue ?? 0)*(model.likelihood?.intValue ?? 0)
        
        self.uploadSiteCheckFile(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }
    
}

//MARK: - Fields enum
extension MonthlyAuditQuestionResponseVC {
    enum Fields: String {
        
        case TotalAsset = "Total Asset"
        case RemainingAsset = "Remaining Asset"
        case AssetOK = "Asset OK"
        case DefectiveAsset = "Defective Asset"
        case Observation = "Observation"
        case SuggestedAction = "Suggested Action"
        case Attachment = "Attachment"
        case Consequence = "Consequence"
        case Likelihood = "Likelihood"
        
        var placeholder: String {
            switch self {
            case .TotalAsset: return ""
            case .RemainingAsset: return ""
            case .AssetOK: return "Search Asset"
            case .DefectiveAsset: return "Search Asset"
            case .Observation: return "Enter notes..."
            case .SuggestedAction: return "Enter notes..."
            case .Attachment: return "Click to upload or drag and drop PNG/JPG (max, 1MB)"
            case .Consequence: return "Select"
            case .Likelihood: return "Select"
            }
        }
        
        var errorMessage: String {
            switch self {
            case .TotalAsset: return ""
            case .RemainingAsset: return ""
            case .AssetOK: return "Please select \(self.rawValue)"
            case .DefectiveAsset: return "Please select \(self.rawValue)"
            case .Observation: return "Please enter \(self.rawValue)"
            case .SuggestedAction: return "Please enter \(self.rawValue)"
            case .Attachment: return "Please select \(self.rawValue)"
            case .Consequence: return "Please select \(self.rawValue)"
            case .Likelihood: return "Please select \(self.rawValue)"
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension MonthlyAuditQuestionResponseVC: EmptyViewDelegate {
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
extension MonthlyAuditQuestionResponseVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func uploadSiteCheckFile(model: SiteCheckAssessmentResponse, successCompletion: @escaping SuccessCompletion) {
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckFileUpload
        APIClient.requestMultipartString(apiService, multipartData: { multipartFormData in
            let fileModel = model.selectedFile
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
                model.file = success
                self.saveSiteCheckAssessmentResponse(model: model, successCompletion: successCompletion)
                break
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func saveSiteCheckAssessmentResponse(model: SiteCheckAssessmentResponse, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckAssessmentResponse(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAssessmentResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.responseId != nil {
                        self.response = single
                        self.addSiteCheckVC?.get_lov_SITE_CHECK_AUDIT_HEADER(vc1: self)
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
    
    func reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [SiteCheckAssessmentQuestions], responseItemArray: [SiteCheckAssessmentResponse]) {
        self.monthlyAuditQuestionsVC?.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: questionItemArray, responseItemArray: responseItemArray)
        if let first = questionItemArray.first(where: { $0.qid == self.question?.qid }) {
            self.question = first
        }
        if let first = responseItemArray.first(where: { $0.qid == self.question?.qid }) {
            self.response = first
        }
        self.reloadViews()
        self.loadingSCLAlertView.hideView()
        SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
    }
    
}

//MARK: - setup views
extension MonthlyAuditQuestionResponseVC {
    
    func setupViews() {
        guard let question else { return }
        
        self.titleLbl.text = question.question
        
        self.TotalAssetXIB.title = Fields.TotalAsset.rawValue
        self.RemainingAssetXIB.title = Fields.RemainingAsset.rawValue
        self.ObservationXIB.title = Fields.Observation.rawValue
        self.SuggestedActionXIB.title = Fields.SuggestedAction.rawValue
        self.ConsequenceXIB.title = Fields.Consequence.rawValue
        self.LikelihoodXIB.title = Fields.Likelihood.rawValue
        
        self.AssetOKCV.delegate = self
        self.AssetOKCV.dataSource = self
        self.AssetOKXIB.textField.placeholder = Fields.AssetOK.placeholder
        self.AssetOKXIB.textField.delegate = self
        self.AssetOKXIB.textField.textChanged { [weak self] in
            guard let self else { return }
            self.reloadSearchTableItemArray(textField: self.AssetOKXIB.textField)
        }
        self.setUpSearchOverlayImage()
        self.reloadSearchAssetCV(textField: self.AssetOKXIB.textField, assetId: nil)
        
        self.DefectiveAssetCV.delegate = self
        self.DefectiveAssetCV.dataSource = self
        self.DefectiveAssetXIB.textField.placeholder = Fields.DefectiveAsset.placeholder
        self.DefectiveAssetXIB.textField.delegate = self
        self.DefectiveAssetXIB.textField.textChanged { [weak self] in
            guard let self else { return }
            self.reloadSearchTableItemArray(textField: self.DefectiveAssetXIB.textField)
        }
        self.setUpSearchOverlayImage()
        self.reloadSearchAssetCV(textField: self.DefectiveAssetXIB.textField, assetId: nil)
        
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.clickToUploadXIB.actionBtn, tag: self.uploadImageFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
            self.clickToUploadCV.delegate = self
            self.clickToUploadCV.dataSource = self
        }
        
        self.reloadViews()
    }
    
    func reloadViews() {
        guard let response else { return }
        
        let bgColor = self.fieldBGColor
        self.TotalAssetXIB.isUserInteractionEnabled = false
        self.TotalAssetXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.RemainingAssetXIB.isUserInteractionEnabled = false
        self.RemainingAssetXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.ObservationXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ObservationXIB.bgColor = bgColor
        self.SuggestedActionXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.SuggestedActionXIB.bgColor = bgColor
        self.ConsequenceXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ConsequenceXIB.bgColor = bgColor
        self.LikelihoodXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.LikelihoodXIB.bgColor = bgColor
        self.AssetOKXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.AssetOKXIB.textField.backgroundColor = bgColor
        self.DefectiveAssetXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.DefectiveAssetXIB.textField.backgroundColor = bgColor
        
        var catAsset: [AssetDetailsResponse] = []
        let assetCategory = question?.assetCategory?.split(separator: ",") ?? []
        let siteAssets = self.assetsItemArray
        if assetCategory.count == 3 {
            catAsset = siteAssets.filter {
                ($0.category ?? "") == assetCategory[0] &&
                ($0.subCategory ?? "") == assetCategory[1] &&
                ($0.subCategory2 ?? "") == assetCategory[2]
            }
        } else if assetCategory.count == 2 {
            catAsset = siteAssets.filter {
                ($0.category ?? "") == assetCategory[0] &&
                ($0.subCategory ?? "") == assetCategory[1]
            }
        } else if assetCategory.count == 1 && assetCategory[0] != "" {
            catAsset = siteAssets.filter { ($0.category ?? "") == assetCategory[0] }
        } else {
            catAsset = siteAssets
        }
        
        self.TotalAssetXIB.text = "\(catAsset.count)"
        self.RemainingAssetXIB.text = "\(catAsset.count - (response.assets?.split(separator: ",") ?? []).count - (response.faultassets?.split(separator: ",") ?? []).count)"
        if let assets = response.assets {
            let idArray = assets.components(separatedBy: ",").compactMap({ Int($0) })
            self.selectedAssetOKItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
            self.reloadSearchAssetCV(textField: self.AssetOKXIB.textField, assetId: nil)
        }
        if let assets = response.faultassets {
            let idArray = assets.components(separatedBy: ",").compactMap({ Int($0) })
            self.selectedDefectiveAssetItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
            self.reloadSearchAssetCV(textField: self.DefectiveAssetXIB.textField, assetId: nil)
        }
        self.ObservationXIB.textView.text = response.observation
        self.SuggestedActionXIB.textView.text = response.action
        self.ConsequenceXIB.text = response.consequence?.intValue?.stringValue ?? Fields.Consequence.placeholder
        self.LikelihoodXIB.text = response.likelihood?.intValue?.stringValue ?? Fields.Likelihood.placeholder
        self.setupConsequenceMenu()
        self.setupLikelihoodMenu()
        self.updateRiskScoreCardLbl()
        
        self.adjustClickToUploadMainView()
        self.saveContinueBtn.isHidden = !self.isFieldsEditable
        self.downloadAttachmentBtn.isHidden = !self.saveContinueBtn.isHidden
    }
    
    func reloadClickToUploadCV() {
        self.adjustClickToUploadMainView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.clickToUploadCV.reloadData()
        }
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
        if self.response?.selectedFile != nil {
            self.clickToUploadCVMainViewHeight.constant = 50
            self.clickToUploadCVMainView.frame.size.height = self.clickToUploadCVMainViewHeight.constant
            self.clickToUploadCVMainView.isHidden = false
        }else {
            self.clickToUploadCVMainViewHeight.constant = 0
            self.clickToUploadCVMainView.frame.size.height = self.clickToUploadCVMainViewHeight.constant
            self.clickToUploadCVMainView.isHidden = true
        }
    }
    
    func setupConsequenceMenu() {
        let view: OptionBtnWithTitleXIB = self.ConsequenceXIB
        let defaultStr = Fields.Consequence.placeholder
        
        let performAction: ((Int?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.consequence = item?.stringValue
            view.text = item?.stringValue ?? defaultStr
            self.updateRiskScoreCardLbl()
            self.setupConsequenceMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.response?.consequence?.intValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in [Int](1...5) {
            let action = UIAction(title: item.stringValue, state: self.response?.consequence?.intValue == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupLikelihoodMenu() {
        let view: OptionBtnWithTitleXIB = self.LikelihoodXIB
        let defaultStr = Fields.Likelihood.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((Int?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.likelihood = item?.stringValue
            view.text = item?.stringValue ?? defaultStr
            self.updateRiskScoreCardLbl()
            self.setupLikelihoodMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.response?.likelihood?.intValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in [Int](1...5) {
            let action = UIAction(title: item.stringValue, state: self.response?.likelihood?.intValue == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func updateRiskScoreCardLbl() {
        let fontSize: CGFloat = 25
        let normalAttrStr = NSMutableAttributedString(
            string: "Risk Score Card ",
            attributes: [
                .font: UIFont(name: .MontserratRegular, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: UIColor(appColor: .PrimaryText)
            ]
        )
        
        let consequence = self.response?.consequence?.intValue ?? 0
        let likelihood = self.response?.likelihood?.intValue ?? 0
        let total = consequence*likelihood
        let boldAttrStr = NSMutableAttributedString(
            string: "(Total Risk Score = \(total))",
            attributes: [
                .font: UIFont(name: .MontserratSemiBold, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                .foregroundColor: UIColor(appColor: .PrimaryText)
            ]
        )
        
        let finalAttrStr = NSMutableAttributedString()
        finalAttrStr.append(normalAttrStr)
        finalAttrStr.append(boldAttrStr)
        self.totalRiskScoreLbl.attributedText = finalAttrStr
    }
    
}

//MARK: - Search Table View
extension MonthlyAuditQuestionResponseVC {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        if self.AssetOKXIB.textField.isEditing {
            self.updateSearchTableView(for: self.AssetOKXIB.textField)
        }else if self.DefectiveAssetXIB.textField.isEditing {
            self.updateSearchTableView(for: self.DefectiveAssetXIB.textField)
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
            self.searchTableView?.type = .searchAsset
        }
        
        // Safely find the cell containing the text field
        var textFieldFrame = textField.convert(textField.bounds, to: view)
        if textField == self.AssetOKXIB.textField {
            textFieldFrame.origin.y -= self.AssetOKCVMainViewHeight.constant
        }else if textField == self.DefectiveAssetXIB.textField {
            textFieldFrame.origin.y -= self.DefectiveAssetCVMainViewHeight.constant
        }
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        var desiredTableViewHeight: CGFloat = 0
        if textField == self.AssetOKXIB.textField {
            desiredTableViewHeight = CGFloat(min(filteredAssetOKItemArray.count, 4)*50)
        }else if textField == self.DefectiveAssetXIB.textField {
            desiredTableViewHeight = CGFloat(min(filteredDefectiveAssetItemArray.count, 4)*50)
        }
        
        // Determine whether to show the table view below or above the text field
        if desiredTableViewHeight <= availableSpaceBelowTextField {
            // Show the tableView below the text field
            self.searchTableView?.frame = CGRect(
                x: textFieldFrame.minX,
                y: textFieldFrame.maxY + 5, // Small gap below the text field
                width: textFieldFrame.width,
                height: desiredTableViewHeight
            )
        } else if desiredTableViewHeight <= availableSpaceAboveTextField {
            // Show the tableView above the text field
            self.searchTableView?.frame = CGRect(
                x: textFieldFrame.minX,
                y: textFieldFrame.minY - desiredTableViewHeight - 5, // Small gap above the text field
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
        
        var itemArray: [AssetDetailsResponse] = []
        if textField == self.AssetOKXIB.textField {
            itemArray = self.filteredAssetOKItemArray
        }else if textField == self.DefectiveAssetXIB.textField {
            itemArray = self.filteredDefectiveAssetItemArray
        }
        
        self.searchTableView?.isHidden = itemArray.isEmpty
        self.searchTableView?.tagAssetItemArray = itemArray
        self.searchTableView?.showTableView(with: itemArray)
        view.addSubview(self.searchTableView!)
        
        self.searchTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? AssetDetailsResponse {
                    textField.text = ""
                    self.reloadSearchAssetCV(textField: textField, assetId: item.assetId) { [weak self] in
                        guard let self else { return }
                        reloadSearchTableItemArray(textField: textField)
                    }
                }
            }
        }
    }
    
    func reloadSearchTableItemArray(textField: UITextField) {
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            if textField == self.AssetOKXIB.textField {
                self.filteredAssetOKItemArray = self.assetsItemArray.filter { asset in
                    return !self.selectedAssetOKItemArray.contains { $0.assetId == asset.assetId } && !self.selectedDefectiveAssetItemArray.contains { $0.assetId == asset.assetId } && (text.isEmpty || getAssetDisplayStrForSiteCheck(asset)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
                }
            }else if textField == self.DefectiveAssetXIB.textField {
                self.filteredDefectiveAssetItemArray = self.assetsItemArray.filter { asset in
                    return !self.selectedDefectiveAssetItemArray.contains { $0.assetId == asset.assetId } && !self.selectedAssetOKItemArray.contains { $0.assetId == asset.assetId } && (text.isEmpty || getAssetDisplayStrForSiteCheck(asset)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
                }
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
    func reloadSearchAssetCV(textField: UITextField, assetId: Int?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let assetId, let item = self.assetsItemArray.first(where: { $0.assetId == assetId }) {
                if textField == self.AssetOKXIB.textField {
                    self.selectedAssetOKItemArray.insert(item, at: 0)
                }else if textField == self.DefectiveAssetXIB.textField {
                    self.selectedDefectiveAssetItemArray.insert(item, at: 0)
                }
            }
            
            if textField == self.AssetOKXIB.textField {
                if self.selectedAssetOKItemArray.isEmpty {
                    let height: CGFloat = CGFloat.zero
                    self.AssetOKCVMainView.isHidden = true
                    self.AssetOKCVMainViewHeight.constant = height
                    self.AssetOKCVMainView.frame.size.height = height
                }else {
                    let height: CGFloat = 50
                    self.AssetOKCVMainView.isHidden = false
                    self.AssetOKCVMainViewHeight.constant = height
                    self.AssetOKCVMainView.frame.size.height = height
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.AssetOKCV.reloadData()
                    completion?()
                }
            }else if textField == self.DefectiveAssetXIB.textField {
                if self.selectedDefectiveAssetItemArray.isEmpty {
                    let height: CGFloat = CGFloat.zero
                    self.DefectiveAssetCVMainView.isHidden = true
                    self.DefectiveAssetCVMainViewHeight.constant = height
                    self.DefectiveAssetCVMainView.frame.size.height = height
                }else {
                    let height: CGFloat = 50
                    self.DefectiveAssetCVMainView.isHidden = false
                    self.DefectiveAssetCVMainViewHeight.constant = height
                    self.DefectiveAssetCVMainView.frame.size.height = height
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.DefectiveAssetCV.reloadData()
                    completion?()
                }
            }
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MonthlyAuditQuestionResponseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.AssetOKCV:
            return self.selectedAssetOKItemArray.count
        case self.DefectiveAssetCV:
            return self.selectedDefectiveAssetItemArray.count
        case self.clickToUploadCV:
            return self.response?.selectedFile != nil ? 1 : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.AssetOKCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
            if self.selectedAssetOKItemArray.count > indexPath.row {
                let item = self.selectedAssetOKItemArray[indexPath.row]
                let tag = getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLines()
                cell.lblSiteName.text = tag
                if self.isFieldsEditable {
                    cell.btnRemoveSite.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            self.selectedAssetOKItemArray.remove(at: indexPath.row)
                            self.reloadSearchAssetCV(textField: self.AssetOKXIB.textField, assetId: nil)
                            self.reloadSearchTableItemArray(textField: self.AssetOKXIB.textField)
                        }
                    }
                }else {
                    let width = CGFloat.zero
                    cell.closeImageViewWidth.constant = width
                    cell.closeImageView.frame.size.width = width
                }
            }
            return cell
        case self.DefectiveAssetCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
            if self.selectedDefectiveAssetItemArray.count > indexPath.row {
                let item = self.selectedDefectiveAssetItemArray[indexPath.row]
                let tag = getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLines()
                cell.lblSiteName.text = tag
                if self.isFieldsEditable {
                    cell.btnRemoveSite.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            self.selectedDefectiveAssetItemArray.remove(at: indexPath.row)
                            self.reloadSearchAssetCV(textField: self.DefectiveAssetXIB.textField, assetId: nil)
                            self.reloadSearchTableItemArray(textField: self.DefectiveAssetXIB.textField)
                        }
                    }
                }else {
                    let width = CGFloat.zero
                    cell.closeImageViewWidth.constant = width
                    cell.closeImageView.frame.size.width = width
                }
            }
            return cell
        case self.clickToUploadCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
            if let selectedFileModel = self.response?.selectedFile {
                cell.lblSiteName.text = selectedFileModel.fileName ?? "file"
                cell.btnRemoveSite.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        self.response?.selectedFile = nil
                        self.reloadClickToUploadCV()
                    }
                }
            }
            return cell
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.AssetOKCV:
            if self.selectedAssetOKItemArray.count > indexPath.row {
                let item = self.selectedAssetOKItemArray[indexPath.row]
                let text = getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLines() ?? ""
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: self.isFieldsEditable ? 10+5+22+5 : 10+5+5).width
                return CGSize(width: width, height: 40)
            }
            
        case self.DefectiveAssetCV:
            if self.selectedDefectiveAssetItemArray.count > indexPath.row {
                let item = self.selectedDefectiveAssetItemArray[indexPath.row]
                let text = getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLines() ?? ""
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: self.isFieldsEditable ? 10+5+22+5 : 10+5+5).width
                return CGSize(width: width, height: 40)
            }
        case self.clickToUploadCV:
            if let selectedFileModel = self.response?.selectedFile {
                let text = selectedFileModel.fileName ?? "file"
                let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+22+5, maxWidth: collectionView.frame.width/2).width
                return CGSize(width: width, height: 40)
            }
        default:
            break
        }
        return CGSize.zero
    }
    
}

//MARK: - UITextFieldDelegate
extension MonthlyAuditQuestionResponseVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.AssetOKXIB.textField, self.DefectiveAssetXIB.textField:
            self.reloadSearchTableItemArray(textField: textField)
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.AssetOKXIB.textField, self.DefectiveAssetXIB.textField:
            textField.text = ""
            self.hideSearchTableView()
            break
        default:
            break
        }
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension MonthlyAuditQuestionResponseVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        self.response?.selectedFile = fileData
        self.reloadClickToUploadCV()
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}
