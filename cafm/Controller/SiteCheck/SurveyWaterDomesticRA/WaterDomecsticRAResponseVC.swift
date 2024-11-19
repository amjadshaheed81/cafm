//
//  WaterDomecsticRAResponseVC.swift
//  cafm
//
//  Created by NS on 10/10/24.
//
//

import UIKit
import SCLAlertView

class WaterDomecsticRAResponseVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var DateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var ScoreXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var ObservationXIB: TextViewWithTitleXIB!
    @IBOutlet weak var Score1XIB: TextFiledDataXib!
    @IBOutlet weak var WeightXIB: TextFiledDataXib!
    @IBOutlet weak var WeightedScoreXIB: TextFiledDataXib!
    @IBOutlet weak var SuggestedActionXIB: TextViewWithTitleXIB!
    @IBOutlet weak var searchAssetMainView: UIView!
    @IBOutlet weak var searchAssetCV: UICollectionView!
    @IBOutlet weak var searchAssetCVMainView: UIView!
    @IBOutlet weak var searchAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchAssetXIB: CustomTextField!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
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
        return self.response?.id == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    weak var waterDomecsticRAVC: WaterDomecsticRAVC?
    var question: SiteCheckRASurveyRiskFactors?
    var response: SiteCheckAssessmentResponse?
    var SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray: [LOV_Model] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    
    private let chooseDateTag = 1
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Survey response saved"
    
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
        self.title = "Risk Factors"
    }
    
    func getValue<T>(_ model: SiteCheckAssessmentResponse, keyPath: AnyKeyPath) -> T? {
        if let keyPath = keyPath as? KeyPath<SiteCheckAssessmentResponse, T?> {
            return model[keyPath: keyPath]
        }
        return nil
    }
    
    @IBAction func saveContinueBtnClicked(_ sender: PrimaryButton) {
        guard let response else { return }
        
        for fields in Fields.compulsoryFields {
            let valueString: String? = getValue(response, keyPath: fields.keyPath)
            let valueInt: Int? = getValue(response, keyPath: fields.keyPath)
            if (valueString != nil && !(valueString?.isEmpty ?? true)) || valueInt != nil {
                //model[keyPath: fields.keyPath] = value
            }else {
                SCLAlertView.showErrorAlert(title: "Error", message: fields.errorMessage, cancelButtonTitle: "OK")
                return
            }
        }
        
        let model = SiteCheckAssessmentResponse()
        model.riskFactorId = self.question?.riskFactorID
        model.responseDate = response.responseDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
        model.score = response.score
        model.observation = response.observation
        model.assets = response.assets
        model.action = response.action
        model.checkId = self.siteCheckModel?.checkId
        model.status = .closed
        model.weightedScore = response.weightedScore
        model.totalRiskScore = 0
        
        self.saveSiteCheckDomesticRASurveyResponse(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }
}

//MARK: - Fields enum
extension WaterDomecsticRAResponseVC {
    enum Fields: String, CaseIterable {
        case Date = "Date"
        case Score = "Score"
        case Observation = "Observation"
        case Weight = "Weight"
        case WeightedScore = "Weighted Score"
        case SearchAsset = "Search Asset"
        case SuggestedAction = "Suggested Action"
        
        static var compulsoryFields: [Fields] {
            var allFields: [Fields] = Fields.allCases
            allFields.removeAll { $0 == .Weight || $0 == .WeightedScore || $0 == .SearchAsset }
            return allFields
        }
        
        var placeholder: String {
            switch self {
            case .Date: return "dd/MM/yyyy"
            case .Score: return "Select"
            case .Observation: return "Enter notes..."
            case .Weight: return "0"
            case .WeightedScore: return "0"
            case .SearchAsset: return "Search Asset"
            case .SuggestedAction: return "Enter notes..."
            }
        }
        
        var errorMessage: String {
            switch self {
            case .Date: return "Please select \(self.rawValue)"
            case .Score: return "Please select \(self.rawValue)"
            case .Observation: return "Please enter \(self.rawValue)"
            case .Weight: return ""
            case .WeightedScore: return ""
            case .SearchAsset: return ""
            case .SuggestedAction: return "Please enter \(self.rawValue)"
            }
        }
        
        var keyPath: AnyKeyPath {
            switch self {
            case .Date: return \SiteCheckAssessmentResponse.responseDate
            case .Score: return \SiteCheckAssessmentResponse.score
            case .Observation: return \SiteCheckAssessmentResponse.observation
            case .Weight: return \SiteCheckAssessmentResponse.weight
            case .WeightedScore: return \SiteCheckAssessmentResponse.weightedScore
            case .SearchAsset: return \SiteCheckAssessmentResponse.assets
            case .SuggestedAction: return \SiteCheckAssessmentResponse.action
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension WaterDomecsticRAResponseVC: EmptyViewDelegate {
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
extension WaterDomecsticRAResponseVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func saveSiteCheckDomesticRASurveyResponse(model: SiteCheckAssessmentResponse, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckDomesticRASurvey(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAssessmentResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.id != nil {
                        self.response = single
                        self.addSiteCheckVC?.getSiteCheckRASurveyRiskFactors(vc: self)
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
    
    func reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [SiteCheckRASurveyRiskFactors], domesticRASurveyItemArray: [SiteCheckAssessmentResponse]) {
        self.waterDomecsticRAVC?.reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: raSurveyRiskFactorsItemArray, domesticRASurveyItemArray: domesticRASurveyItemArray)
        if let first = raSurveyRiskFactorsItemArray.first(where: { $0.riskFactorID == self.question?.riskFactorID }) {
            self.question = first
        }
        if let first = domesticRASurveyItemArray.first(where: { $0.riskFactorId == self.question?.riskFactorID }) {
            self.response = first
        }
        self.reloadViews()
        self.loadingSCLAlertView.hideView()
        SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
    }
    
}

//MARK: - setup views
extension WaterDomecsticRAResponseVC {
    
    func setupViews() {
        guard let question else { return }
        
        self.titleLbl.text = question.riskFactor

        self.DateXIB.title = Fields.Date.rawValue
        self.ScoreXIB.title = Fields.Score.rawValue
        self.ObservationXIB.title = Fields.Observation.rawValue
        self.ObservationXIB.placeholder = Fields.Observation.placeholder
        self.ObservationXIB.textView.delegate = self
        self.Score1XIB.title = Fields.Score.rawValue
        self.WeightXIB.title = Fields.Weight.rawValue
        self.WeightedScoreXIB.title = Fields.WeightedScore.rawValue
        self.Score1XIB.lblTFName.numberOfLines = 0
        self.WeightXIB.lblTFName.numberOfLines = 0
        self.WeightedScoreXIB.lblTFName.numberOfLines = 0
        self.Score1XIB.lblTFNameHeight.constant = 42
        self.WeightXIB.lblTFNameHeight.constant = 42
        self.WeightedScoreXIB.lblTFNameHeight.constant = 42
        self.SuggestedActionXIB.title = Fields.SuggestedAction.rawValue
        self.SuggestedActionXIB.placeholder = Fields.SuggestedAction.placeholder
        self.SuggestedActionXIB.textView.delegate = self
        
        self.DateXIB.text = ddMMyyyyStr
        self.DateXIB.image = UIImage(systemName: "calendar")
        self.DateXIB.optionXIB.btnDownClick.tag = self.chooseDateTag
        self.DateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.DateXIB.optionXIB.btnDownClick
            let date = self.response?.responseDate?.transformToDate(dateFormat: kResponseDateFormat)
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.response?.responseDate = date?.transformToString(dateFormat: kResponseDateFormat)
                self.DateXIB.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
            }
        }
        
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

        self.ScoreXIB.text = Fields.Score.placeholder
        self.setupScoreMenu()
        
        self.reloadViews()
    }
    
    func reloadViews() {
        guard let response else { return }
        
        let bgColor = self.fieldBGColor
        
        self.DateXIB.bgColor = bgColor
        self.DateXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ScoreXIB.bgColor = bgColor
        self.ScoreXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ObservationXIB.bgColor = bgColor
        self.ObservationXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Score1XIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.Score1XIB.isUserInteractionEnabled = false
        self.WeightXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.WeightXIB.isUserInteractionEnabled = false
        self.WeightedScoreXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.WeightedScoreXIB.isUserInteractionEnabled = false
        self.SuggestedActionXIB.bgColor = bgColor
        self.SuggestedActionXIB.isUserInteractionEnabled = self.isFieldsEditable
        
        self.buttonsView.isHidden = !self.isFieldsEditable
        self.buttonsViewHeight.constant = self.buttonsView.isHidden ? 0 : 64
        self.buttonsView.frame.size.height = self.buttonsViewHeight.constant
        
        self.DateXIB.text = response.responseDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        self.ScoreXIB.text = Fields.Score.placeholder
        self.setupScoreMenu()
        self.ObservationXIB.text = response.observation
        if let assets = response.assets {
            let idArray = assets.components(separatedBy: ",").compactMap({ Int($0) })
            self.selectedAssetsItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
            self.reloadSearchAssetCV(assetId: nil)
        }
        self.SuggestedActionXIB.textView.text = response.action
        self.updateWeightedScore()
    }
    
    func setupScoreMenu() {
        let view: OptionBtnWithTitleXIB = self.ScoreXIB
        let defaultStr = Fields.Score.placeholder
        
        let itemArray: [LOV_Model] = self.SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray.filter({ $0.attribite1 == self.question?.riskFactorID?.stringValue })
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.score = item?.lovValue?.intValue
            view.text = getLOVDisplayStr(item) ?? defaultStr
            self.updateWeightedScore()
            self.setupScoreMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.response?.score?.stringValue == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in itemArray {
            let action = UIAction(title: getLOVDisplayStr(item) ?? "", state: self.response?.score?.stringValue == item.lovValue ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func updateWeightedScore() {
        let score = self.response?.score ?? 0
        let weight = self.question?.weight ?? 0
        let weightedScore = score*weight
        
        self.response?.weightedScore = weightedScore
        
        self.Score1XIB.text = "\(score)"
        self.WeightXIB.text = "\(weight)"
        self.WeightedScoreXIB.text = "\(weightedScore)"
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension WaterDomecsticRAResponseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.searchAssetCV:
            return self.selectedAssetsItemArray.count
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
        default:
            break
        }
        return CGSize.zero
    }
    
}

//MARK: - Search Table View
extension WaterDomecsticRAResponseVC {
    
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
            self.response?.assets = self.selectedAssetsItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.searchAssetCV.reloadData()
                completion?()
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension WaterDomecsticRAResponseVC: UITextFieldDelegate {
    
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

//MARK: - UITextViewDelegate
extension WaterDomecsticRAResponseVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        switch textView {
        case self.ObservationXIB.textView:
            self.response?.observation = text
            break
        case self.SuggestedActionXIB.textView:
            self.response?.action = text
            break
        default:
            break
        }
    }
    
}
