//
//  WaterOutletTempActionVC.swift
//  cafm
//
//  Created by NS on 13/10/24.
//  
//

import UIKit
import SCLAlertView
import ImageScrollView

class WaterOutletTempActionVC: UIViewController {

    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var ConsequenceXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var LikelihoodXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var ObservationXIB: TextViewWithTitleXIB!
    @IBOutlet weak var RequiredActionXIB: TextViewWithTitleXIB!
    @IBOutlet weak var riskScoreImageSV: ImageScrollView!

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
    weak var waterOutletTempVC: WaterOutletTempVC?
    weak var waterOutletTempAddReadingVC: WaterOutletTempAddReadingVC?
    var siteCheckModel: SiteCheckModel?
    var siteCheckWaterOutletTemp: SiteCheckWaterOutletTemp?
    var assetsItemArray: [AssetDetailsResponse] = []
    
    var selectedConsequence: Int?
    var selectedLikelihood: Int?
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Water outlet temperature data saved."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Add Reading"
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        let saveBtn = getPrimaryNavigationBtn(title: "Save")
        saveBtn.addTarget(self, action: #selector(self.saveBtnClicked(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.waterOutletTempAddReadingVC?.continueSave()
        }
    }
    
    @objc func saveBtnClicked(_ sender: UIButton) {
        if !self.buttonsView.isHidden {
            self.navCloseBtnClicked(UIBarButtonItem())
            return
        }
        
        let model = ActionModel()
        
        if selectedConsequence != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Consequence.errorMessage, cancelButtonTitle: "OK")
            return
        }
        if selectedLikelihood != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Likelihood.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.ObservationXIB.textView.endEditing(true)
        if let text = self.ObservationXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.observation = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.Observation.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        self.RequiredActionXIB.textView.endEditing(true)
        if let text = self.RequiredActionXIB.textView.text?.trimmingSpacesAndLines(), !text.isEmpty {
            model.requiredAction = text
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: Fields.RequiredAction.errorMessage, cancelButtonTitle: "OK")
            return
        }
        
        model.type = "Survey"
        model.status = .reported
        model.desc = "Surevy Water - Outlet Temprature - \(Date().transformToString(dateFormat: ddMMyyyyStr))"
        if let selectedConsequence, let selectedLikelihood {
            model.riskScore = selectedConsequence*selectedLikelihood
        }
        model.dueDate = Date().transformToString(dateFormat: kRequestDateFormat)
        model.siteId = UserConstants.shared.selectedSiteID
        model.userId = UserConstants.shared.currentUserID
        
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.waterOutletTempVC?.actionModel = model
            self.waterOutletTempAddReadingVC?.continueSave()
        }
    }
    
    @IBAction func addActionBtnClicked(_ sender: UIButton) {
        self.waterOutletTempVC?.action = false
        self.waterOutletTempVC?.action2 = true

        self.setHiddenButtonsView()
    }
    
    func setHiddenButtonsView(_ isHidden: Bool = true) {
        self.buttonsView.isHidden = isHidden
        self.addView.isHidden = !self.buttonsView.isHidden
        self.scrollView.isScrollEnabled = !self.addView.isHidden
    }
    
}

//MARK: - Fields enum
extension WaterOutletTempActionVC {
    enum Fields: String {
        case Consequence = "Consequence"
        case Likelihood = "Likelihood"
        case Observation = "Observation"
        case RequiredAction = "Required Action"
        
        var placeholder: String {
            switch self {
            case .Consequence, .Likelihood:
                return "Select \(self.rawValue)"
            case .Observation, .RequiredAction:
                return "Enter \(self.rawValue)"
            }
        }
        
        var errorMessage: String {
            switch self {
            case .Consequence, .Likelihood:
                return "Please select \(self.rawValue)"
            case .Observation, .RequiredAction:
                return "Please enter \(self.rawValue)"
            }
        }
        
    }
}

//MARK: - EmptyViewDelegate
extension WaterOutletTempActionVC: EmptyViewDelegate {
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
extension WaterOutletTempActionVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
}

extension WaterOutletTempActionVC {
    
    func setupViews() {
        self.setHiddenButtonsView(false)
        
        self.ConsequenceXIB.title = Fields.Consequence.rawValue
        self.LikelihoodXIB.title = Fields.Likelihood.rawValue
        self.ObservationXIB.title = Fields.Observation.rawValue
        self.RequiredActionXIB.title = Fields.RequiredAction.placeholder
        
        self.ConsequenceXIB.text = Fields.Consequence.placeholder
        self.LikelihoodXIB.text = Fields.Likelihood.placeholder
        self.setupConsequenceMenu()
        self.setupLikelihoodMenu()
        
        self.riskScoreImageSV.setup()
        if let image = UIImage(named: "img_risk_scorecard_assessment") {
            self.riskScoreImageSV.imageContentMode = .heightFill
            self.riskScoreImageSV.display(image: image)
        }
        self.reloadViews()
    }
    
    func reloadViews() {
        guard let response = self.siteCheckWaterOutletTemp else { return }
        
        if let assetId = response.assetId, let asset = self.assetsItemArray.first(where: { $0.assetId == Int(assetId) }) {
            self.titleLbl.text = getAssetDisplayStrForSiteCheck(asset)
        }
        
    }
    
    func setupConsequenceMenu() {
        let view: OptionBtnWithTitleXIB = self.ConsequenceXIB
        let defaultStr = Fields.Consequence.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((Int?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedConsequence = item
            view.optionXIB.lblText.text = item?.stringValue ?? defaultStr
            self.setupConsequenceMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedConsequence == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in [Int](1...5) {
            let action = UIAction(title: item.stringValue, state: self.selectedConsequence == item ? .on : .off) { [weak self] action in
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
            self.selectedLikelihood = item
            view.optionXIB.lblText.text = item?.stringValue ?? defaultStr
            self.setupLikelihoodMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedLikelihood == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in [Int](1...5) {
            let action = UIAction(title: item.stringValue, state: self.selectedLikelihood == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
}
