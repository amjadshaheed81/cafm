//
//  AssessmentQuestionResponseVC.swift
//  cafm
//
//  Created by NS on 28/09/24.
//
//

import UIKit
import SCLAlertView
import ImageScrollView

class AssessmentQuestionResponseVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var internalExternalXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var floorXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var roomXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var observationXIB: TextViewWithTitleXIB!
    @IBOutlet weak var searchAssetMainView: UIView!
    @IBOutlet weak var searchAssetCV: UICollectionView!
    @IBOutlet weak var searchAssetCVMainView: UIView!
    @IBOutlet weak var searchAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchAssetXIB: CustomTextField!
    @IBOutlet weak var suggestedActionXIB: TextViewWithTitleXIB!
    @IBOutlet weak var clickToUploadMainView: UIView!
    @IBOutlet weak var clickToUploadMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadXIB: ClickToUploadXIB!
    @IBOutlet weak var clickToUploadCVMainView: UIView!
    @IBOutlet weak var clickToUploadCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadCV: UICollectionView!
    @IBOutlet weak var totalRiskScoreLbl: UILabel!
    @IBOutlet weak var consequenceXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var likelihoodXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var riskScoreImageSV: ImageScrollView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadAttachmentBtn: ActionButton!
    @IBOutlet weak var saveContinueBtn: PrimaryButton!
    
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
    
    private var isFieldsEditable: Bool {
        return self.response?.responseId == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    weak var assessmentQuestionsVC: AssessmentQuestionsVC?
    var questionIndex: Int?
    var question: SiteCheckAssessmentQuestions?
    var response: SiteCheckAssessmentResponse?
    var siteLayoutItemArray: [SiteLayoutModel] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    private lazy var selectedFloorItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .floor }
    }()
    private lazy var selectedRoomItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .room }
    }()
    
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
        let index = (self.questionIndex ?? -1)+1
        self.title = "Q\(index)"
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
        
        if let value = response.position {
            model.position = value
            //model.riskType = value
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.InternalExternal.errorMessage, cancelButtonTitle: "OK")
            return
        }
        if let value = response.floor {
            model.floor = value
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Floor.errorMessage, cancelButtonTitle: "OK")
            return
        }
        if let value = response.room {
            model.room = value
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Room.errorMessage, cancelButtonTitle: "OK")
            return
        }
        self.observationXIB.textView.hideEditing()
        if let text = self.observationXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.observation = text
            //model.position = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Observation.errorMessage, cancelButtonTitle: "OK")
            return
        }
        if !self.selectedAssetsItemArray.isEmpty {
            model.assets = self.selectedAssetsItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
        }
        self.suggestedActionXIB.textView.hideEditing()
        if let text = self.suggestedActionXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
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
        
        model.response = .no
        //model.riskType
        model.siteId = UserConstants.shared.selectedSiteID
        model.responseDate = Date().transformToString(dateFormat: kRequestDateFormat)
        model.checkId = self.assessmentQuestionsVC?.siteCheckModel?.checkId
        model.qid = self.question?.qid
        model.status = .closed
        model.totalRiskScore = (model.consequence?.intValue ?? 0)*(model.likelihood?.intValue ?? 0)
        
        self.uploadSiteCheckFile(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }
    
}

//MARK: - Fields enum
extension AssessmentQuestionResponseVC {
    enum Fields: String {
        case InternalExternal = "Internal/External"
        case Floor = "Floor"
        case Room = "Room"
        case Observation = "Observation"
        case SearchAsset = "Search Asset"
        case SuggestedAction = "Suggested Action"
        case Attachment = "Attachment"
        case Consequence = "Consequence"
        case Likelihood = "Likelihood"
        
        var placeholder: String {
            switch self {
            case .InternalExternal: return "Select"
            case .Floor: return "Select"
            case .Room: return "Select"
            case .Observation: return "Enter notes..."
            case .SearchAsset: return "Search Asset"
            case .SuggestedAction: return "Enter notes..."
            case .Attachment: return "Click to upload or drag and drop PNG/JPG (max, 1MB)"
            case .Consequence: return "Select"
            case .Likelihood: return "Select"
            }
        }
        
        var errorMessage: String {
            switch self {
            case .InternalExternal: return "Please select \(self.rawValue)"
            case .Floor: return "Please select \(self.rawValue)"
            case .Room: return "Please select \(self.rawValue)"
            case .Observation: return "Please enter \(self.rawValue)"
            case .SearchAsset: return "Please select \(self.rawValue)"
            case .SuggestedAction: return "Please enter \(self.rawValue)"
            case .Attachment: return "Please select \(self.rawValue)"
            case .Consequence: return "Please select \(self.rawValue)"
            case .Likelihood: return "Please select \(self.rawValue)"
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension AssessmentQuestionResponseVC: EmptyViewDelegate {
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
extension AssessmentQuestionResponseVC {
    
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
                        self.addSiteCheckVC?.getSiteCheckAssessmentQuestionsAssessmentFireRisk(vc: self)
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
        self.assessmentQuestionsVC?.reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: questionItemArray, responseItemArray: responseItemArray)
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
extension AssessmentQuestionResponseVC {
    
    func setupViews() {
        guard let question else { return }
        
        self.titleLbl.text = question.question
        
        self.internalExternalXIB.title = Fields.InternalExternal.rawValue
        self.floorXIB.title = Fields.Floor.rawValue
        self.roomXIB.title = Fields.Room.rawValue
        self.observationXIB.title = Fields.Observation.rawValue
        self.observationXIB.textView.placeholder = Fields.Observation.placeholder
        self.observationXIB.textView.delegate = self
        
        self.searchAssetCV.delegate = self
        self.searchAssetCV.dataSource = self
        self.searchAssetXIB.textField.placeholder = "Tag Asset"
        self.searchAssetXIB.textField.delegate = self
        self.searchAssetXIB.textField.textChanged { [weak self] in
            guard let self else { return }
            self.reloadSearchTableItemArray()
        }
        self.setUpSearchOverlayImage()
        self.reloadSearchAssetCV(assetId: nil)
        
        self.suggestedActionXIB.title = Fields.SuggestedAction.rawValue
        self.suggestedActionXIB.textView.placeholder = Fields.SuggestedAction.placeholder
        self.suggestedActionXIB.textView.delegate = self
        
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.clickToUploadXIB.actionBtn, tag: self.uploadImageFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
            self.clickToUploadCV.delegate = self
            self.clickToUploadCV.dataSource = self
        }
        
        self.consequenceXIB.title = Fields.Consequence.rawValue
        self.likelihoodXIB.title = Fields.Likelihood.rawValue
        
        self.riskScoreImageSV.setup()
        if let image = UIImage(named: "img_risk_scorecard_assessment") {
            self.riskScoreImageSV.imageContentMode = .heightFill
            self.riskScoreImageSV.display(image: image)
        }
        self.reloadViews()
    }
    
    func reloadViews() {
        guard let response else { return }
        
        let bgColor = self.fieldBGColor
        
        self.internalExternalXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.internalExternalXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.floorXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.floorXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.roomXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.roomXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.observationXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.observationXIB.textView.backgroundColor = bgColor
        self.searchAssetXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.searchAssetXIB.textField.backgroundColor = bgColor
        self.suggestedActionXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.suggestedActionXIB.textView.backgroundColor = bgColor
        self.consequenceXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.consequenceXIB.optionXIB.dummyTF.backgroundColor = bgColor
        self.likelihoodXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.likelihoodXIB.optionXIB.dummyTF.backgroundColor = bgColor
        
        if let value = response.position {
            self.internalExternalXIB.optionXIB.lblText.text = value
            self.setupInternalExternalMenu()
        }else {
            self.reloadInternalExternalXIB()
        }
        if let value = response.floor?.intValue, let item = self.selectedFloorItemArray.first(where: { $0.id == value }) {
            self.floorXIB.optionXIB.lblText.text = item.nodeName ?? Fields.Floor.placeholder
            self.setupFloorMenu()
        }else {
            self.reloadFloorXIB()
        }
        if let value = response.room?.intValue, let item = self.selectedRoomItemArray.first(where: { $0.id == value }) {
            self.roomXIB.optionXIB.lblText.text = item.nodeName ?? Fields.Room.placeholder
            self.setupRoomMenu()
        }else {
            self.reloadRoomXIB()
        }
        
        self.observationXIB.textView.text = response.observation
        if let assets = response.assets {
            let idArray = assets.components(separatedBy: ",").compactMap({ Int($0) })
            self.selectedAssetsItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
            self.reloadSearchAssetCV(assetId: nil)
        }
        self.suggestedActionXIB.textView.text = response.action
        
        self.adjustClickToUploadMainView()
        self.consequenceXIB.optionXIB.lblText.text = response.consequence?.intValue?.stringValue ?? Fields.Consequence.placeholder
        self.likelihoodXIB.optionXIB.lblText.text = response.likelihood?.intValue?.stringValue ?? Fields.Likelihood.placeholder
        self.setupConsequenceMenu()
        self.setupLikelihoodMenu()
        self.updateRiskScoreCardLbl()
        
        self.saveContinueBtn.isHidden = !self.isFieldsEditable
        self.downloadAttachmentBtn.isHidden = !self.saveContinueBtn.isHidden
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
    
    func reloadClickToUploadCV() {
        self.adjustClickToUploadMainView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.clickToUploadCV.reloadData()
        }
    }
    
    func reloadInternalExternalXIB() {
        self.internalExternalXIB.text = Fields.InternalExternal.placeholder
        self.response?.position = nil
        self.setupInternalExternalMenu()
    }
    
    func setupInternalExternalMenu() {
        let view: OptionBtnWithTitleXIB = self.internalExternalXIB
        let defaultStr = Fields.InternalExternal.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.position = item
            view.text = item ?? defaultStr
            self.setupInternalExternalMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.response?.position?.intValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in positionItemArray {
            let action = UIAction(title: item, state: self.response?.position == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadFloorXIB() {
        self.floorXIB.optionXIB.lblText.text = Fields.Floor.placeholder
        self.response?.floor = nil
        self.setupFloorMenu()
    }
    
    func setupFloorMenu() {
        let view: OptionBtnWithTitleXIB = self.floorXIB
        let defaultStr = Fields.Floor.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.floor = item?.id?.stringValue
            view.optionXIB.lblText.text = item?.nodeName ?? defaultStr
            self.setupFloorMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.response?.floor?.intValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedFloorItemArray {
            let action = UIAction(title: item.nodeName ?? "", state: self.response?.floor?.intValue == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadRoomXIB() {
        self.roomXIB.optionXIB.lblText.text = Fields.Room.placeholder
        self.response?.room = nil
        self.setupRoomMenu()
    }
    
    func setupRoomMenu() {
        let view: OptionBtnWithTitleXIB = self.roomXIB
        let defaultStr = Fields.Room.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.room = item?.id?.stringValue
            view.optionXIB.lblText.text = item?.nodeName ?? defaultStr
            self.setupRoomMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.response?.room?.intValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.selectedRoomItemArray {
            let action = UIAction(title: item.nodeName ?? "", state: self.response?.room?.intValue == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupConsequenceMenu() {
        let view: OptionBtnWithTitleXIB = self.consequenceXIB
        let defaultStr = Fields.Consequence.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((Int?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.consequence = item?.stringValue
            view.optionXIB.lblText.text = item?.stringValue ?? defaultStr
            self.updateRiskScoreCardLbl()
            self.setupConsequenceMenu()
        }
        
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
        let view: OptionBtnWithTitleXIB = self.likelihoodXIB
        let defaultStr = Fields.Likelihood.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((Int?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.likelihood = item?.stringValue
            view.optionXIB.lblText.text = item?.stringValue ?? defaultStr
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
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AssessmentQuestionResponseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.searchAssetCV:
            return self.selectedAssetsItemArray.count
        case self.clickToUploadCV:
            return self.response?.selectedFile != nil ? 1 : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.searchAssetCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
            if self.selectedAssetsItemArray.count > indexPath.row {
                let item = self.selectedAssetsItemArray[indexPath.row]
                let tag = getAssetDisplayStrForSiteCheck(item)?.trimmingSpacesAndLines()
                cell.lblSiteName.text = tag
                if self.isFieldsEditable {
                    cell.btnRemoveSite.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            self.selectedAssetsItemArray.remove(at: indexPath.row)
                            self.reloadSearchAssetCV(assetId: nil)
                            self.reloadSearchTableItemArray()
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
        case self.searchAssetCV:
            if self.selectedAssetsItemArray.count > indexPath.row {
                let item = self.selectedAssetsItemArray[indexPath.row]
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

//MARK: - Search Table View
extension AssessmentQuestionResponseVC {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.keyBoardHeight = keyboardFrame.cgRectValue.height
        globalKeyBoradHeight = self.keyBoardHeight
        let textField: UITextField! = self.searchAssetXIB.textField
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
            self.searchTableView?.type = .searchAsset
        }
        
        // Safely find the cell containing the text field
        var textFieldFrame = textField.convert(textField.bounds, to: view)
        textFieldFrame.origin.y -= self.searchAssetCVMainViewHeight.constant
        
        // Calculate available space below and above the text field
        let availableSpaceBelowTextField = view.frame.height - keyBoardHeight - textFieldFrame.maxY - 10 // Padding of 10
        let availableSpaceAboveTextField = textFieldFrame.minY - 10 // Padding of 10
        
        // Calculate the desired height for the tableView
        let desiredTableViewHeight = CGFloat(min(filteredAssetsItemArray.count, 4)*50)
        
        // Determine whether to show the table view below or above the text field
        if desiredTableViewHeight <= availableSpaceBelowTextField {
            // Show the tableView below the text field
            self.searchTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                 y: textFieldFrame.maxY + 5, // Small gap below the text field
                                                 width: textFieldFrame.width,
                                                 height: desiredTableViewHeight)
        } else if desiredTableViewHeight <= availableSpaceAboveTextField {
            // Show the tableView above the text field
            self.searchTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                 y: textFieldFrame.minY - desiredTableViewHeight - 5, // Small gap above the text field
                                                 width: textFieldFrame.width,
                                                 height: desiredTableViewHeight)
        } else {
            // Show the tableView with maximum available space below or above
            if availableSpaceBelowTextField >= availableSpaceAboveTextField {
                // Show the tableView below, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceBelowTextField)
                self.searchTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                     y: textFieldFrame.maxY + 5,
                                                     width: textFieldFrame.width,
                                                     height: tableViewHeight)
            } else {
                // Show the tableView above, but limit its height to the available space
                let tableViewHeight = min(desiredTableViewHeight, availableSpaceAboveTextField)
                self.searchTableView?.frame = CGRect(x: textFieldFrame.minX,
                                                     y: textFieldFrame.minY - tableViewHeight - 5,
                                                     width: textFieldFrame.width,
                                                     height: tableViewHeight)
            }
        }
        
        let itemArray = self.filteredAssetsItemArray
        self.searchTableView?.isHidden = itemArray.isEmpty
        self.searchTableView?.tagAssetItemArray = itemArray
        self.searchTableView?.showTableView(with: itemArray)
        view.addSubview(self.searchTableView!)
        
        self.searchTableView?.didSelectItem = { [weak self] selectedItem in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let item = selectedItem as? AssetDetailsResponse {
                    textField.text = ""
                    self.reloadSearchAssetCV(assetId: item.assetId) { [weak self] in
                        guard let self else { return }
                        reloadSearchTableItemArray()
                    }
                }
            }
        }
    }
    
    func reloadSearchTableItemArray() {
        let textField: UITextField = self.searchAssetXIB.textField
        if let text = textField.text?.trimmingSpacesAndLinesLowercased() {
            self.filteredAssetsItemArray = self.assetsItemArray.filter { asset in
                return !self.selectedAssetsItemArray.contains { $0.assetId == asset.assetId } && (text.isEmpty || getAssetDisplayStrForSiteCheck(asset)?.trimmingSpacesAndLinesLowercased().contains(text) ?? false)
            }
            if textField.isEditing {
                self.updateSearchTableView(for: textField)
            }
        }
    }
    
    func reloadSearchAssetCV(assetId: Int?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let assetId, let item = self.assetsItemArray.first(where: { $0.assetId == assetId }) {
                self.selectedAssetsItemArray.insert(item, at: 0)
            }
            
            if self.selectedAssetsItemArray.isEmpty {
                let height: CGFloat = CGFloat.zero
                self.searchAssetCVMainView.isHidden = true
                self.searchAssetCVMainViewHeight.constant = height
                self.searchAssetCVMainView.frame.size.height = height
            }else {
                let height: CGFloat = 50
                self.searchAssetCVMainView.isHidden = false
                self.searchAssetCVMainViewHeight.constant = height
                self.searchAssetCVMainView.frame.size.height = height
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.searchAssetCV.reloadData()
                completion?()
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension AssessmentQuestionResponseVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.searchAssetXIB.textField:
            self.reloadSearchTableItemArray()
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.searchAssetXIB.textField:
            textField.text = ""
            self.hideSearchTableView()
            break
        default:
            break
        }
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension AssessmentQuestionResponseVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        self.response?.selectedFile = fileData
        self.reloadClickToUploadCV()
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}

//MARK: - UITextViewDelegate
extension AssessmentQuestionResponseVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        switch textView {
        case self.observationXIB.textView:
            self.response?.observation = text
            break
        case self.suggestedActionXIB.textView:
            self.response?.action = text
            break
        default:
            break
        }
    }
    
}
