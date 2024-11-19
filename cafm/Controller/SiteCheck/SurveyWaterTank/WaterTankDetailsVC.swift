//
//  WaterTankDetailsVC.swift
//  cafm
//
//  Created by NS on 17/10/24.
//
//

import UIKit
import SCLAlertView

class WaterTankDetailsVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var InternalExternalXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var FloorXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var RoomXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var SystemFedFromTankXIB: TextFiledDataXib!
    @IBOutlet weak var ApproxVolumeLitresXIB: TextFiledDataXib!
    @IBOutlet weak var InletOutletTankOrientationXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var TurnoverTimeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var searchAssetMainView: UIView!
    @IBOutlet weak var searchAssetCV: UICollectionView!
    @IBOutlet weak var searchAssetCVMainView: UIView!
    @IBOutlet weak var searchAssetCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchAssetXIB: CustomTextField!
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var questionTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saveContinueBtn: PrimaryButton!

    private var volumeStepper: UIStepper?
    
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
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    var itemArray: [SiteCheckWaterTank] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    var siteLayoutItemArray: [SiteLayoutModel] = []
    
    private var selectedAssetsItemArray: [AssetDetailsResponse] = []
    private var filteredAssetsItemArray: [AssetDetailsResponse] = []
    private let InletOutletTankOrientationItemArray: [String] = ["Satisfactory", "Unsatisfactory"]
    private let TurnoverTimeItemArray: [String] = ["<24 hrs", "24-28 hrs", ">48 hrs"]
    private var questionItemArray: [(quesiton: Questions, answer: Bool?)] = Questions.allCases.compactMap { (quesiton: $0, answer: nil) }
    private lazy var selectedFloorItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .floor }
    }()
    private lazy var selectedRoomItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .room }
    }()
    private var response: SiteCheckWaterTank? {
        return self.itemArray.first
    }
    
    private var isFieldsEditable: Bool {
        return true
        //return self.itemArray.first?.id == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Tank survey saved"
    
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
        self.title = "Tank Details"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func getValue<T>(_ model: SiteCheckWaterTank, keyPath: AnyKeyPath) -> T? {
        if let keyPath = keyPath as? KeyPath<SiteCheckWaterTank, T?> {
            return model[keyPath: keyPath]
        }
        return nil
    }
    
    @IBAction func saveContinueBtnClicked(_ sender: PrimaryButton) {
        guard let response else { return }
        
        for fields in Fields.compulsoryFields {
            if let keyPath = fields.keyPath {
                let valueString: String? = getValue(response, keyPath: keyPath)
                let valueInt: Int? = getValue(response, keyPath: keyPath)
                if (valueString != nil && !(valueString?.isEmpty ?? true)) || valueInt != nil {
                    //model[keyPath: fields.keyPath] = value
                }else {
                    SCLAlertView.showErrorAlert(title: "Error", message: fields.errorMessage, cancelButtonTitle: "OK")
                    return
                }
            }
        }

        let model = SiteCheckWaterTank()
        model.checkId = self.siteCheckModel?.checkId
        model.internalExternal = response.internalExternal
        model.floor = response.floor
        model.room = response.room
        model.systemFed = response.systemFed
        model.volume = response.volume
        model.orientation = response.orientation
        model.turnoverTime = response.turnoverTime
        model.status = "Open"

        for item in self.questionItemArray {
            item.quesiton.assignValue(item.answer?.yesNoValue, to: model)
        }
        
        self.saveSiteCheckTank(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }

}

//MARK: - Fields enum
extension WaterTankDetailsVC {
    enum Fields: String, CaseIterable {
        case InternalExternal = "Internal/External"
        case Floor = "Floor"
        case Room = "Room"
        case SystemFedFromTank = "System Fed from Tank"
        case SearchAsset = "Search Asset"
        case ApproxVolumeLitres = "Approx. Volume (Litres)"
        case InletOutletTankOrientation = "Inlet, outlet & tank orientation"
        case TurnoverTime = "Turnover Time"
        
        static var compulsoryFields: [Fields] {
            var allFields: [Fields] = Fields.allCases
            allFields.removeAll { $0 == .SearchAsset }
            return allFields
        }
        
        var placeholder: String {
            switch self {
            case .InternalExternal, .Floor, .Room, .InletOutletTankOrientation, .TurnoverTime:
                return "Select"
            case .SystemFedFromTank, .ApproxVolumeLitres:
                return ""
            case .SearchAsset:
                return self.rawValue
            }
        }
        
        var errorMessage: String {
            switch self {
            case .InternalExternal, .Floor, .Room, .InletOutletTankOrientation, .TurnoverTime:
                return "Please select \(self.rawValue)"
            case .SystemFedFromTank, .ApproxVolumeLitres:
                return "Please enter \(self.rawValue)"
            case .SearchAsset:
                return ""
            }
        }
        
        var keyPath: AnyKeyPath? {
            switch self {
            case .InternalExternal: return \SiteCheckWaterTank.internalExternal
            case .Floor: return \SiteCheckWaterTank.floor
            case .Room: return \SiteCheckWaterTank.room
            case .SystemFedFromTank: return \SiteCheckWaterTank.systemFed
            case .SearchAsset: return nil
            case .ApproxVolumeLitres: return \SiteCheckWaterTank.volume
            case .InletOutletTankOrientation: return \SiteCheckWaterTank.orientation
            case .TurnoverTime: return \SiteCheckWaterTank.turnoverTime
            }
        }
    }
    
    enum Questions: String, CaseIterable {
        case q1 = "Lid Lining"
        case q2 = "Absence of sludge"
        case q3 = "Insulation"
        case q4 = "Insect/ Vermin Screen"
        case q5 = "Drainage"
        case q6 = "Access for Cleaning"
        case q7 = "Inspection & Cleaning Regime"
        
        var keyPath: KeyPath<SiteCheckWaterTank, String?> {
            switch self {
            case .q1: return \SiteCheckWaterTank.q1
            case .q2: return \SiteCheckWaterTank.q2
            case .q3: return \SiteCheckWaterTank.q3
            case .q4: return \SiteCheckWaterTank.q4
            case .q5: return \SiteCheckWaterTank.q5
            case .q6: return \SiteCheckWaterTank.q6
            case .q7: return \SiteCheckWaterTank.q7
            }
        }
        
        func assignValue(_ value: String?, to model: SiteCheckWaterTank) {
            switch self {
            case .q1: model.q1 = value
            case .q2: model.q2 = value
            case .q3: model.q3 = value
            case .q4: model.q4 = value
            case .q5: model.q5 = value
            case .q6: model.q6 = value
            case .q7: model.q7 = value
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension WaterTankDetailsVC: EmptyViewDelegate {
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
extension WaterTankDetailsVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func saveSiteCheckTank(model: SiteCheckWaterTank, successCompletion: @escaping SuccessCompletion) {
        self.loadingSCLAlertView.showLoading()
        let apiService = ApiService.postSiteCheckTank(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckWaterTank>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.id != nil {
                        self.addSiteCheckVC?.getSiteCheckTank(vc: self)
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
    
    func reloadAfterGetSiteCheckTankByCheckId(itemArray: [SiteCheckWaterTank]) {
        self.itemArray = itemArray
        self.reloadViews()
        self.loadingSCLAlertView.hideView()
        SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
    }
    
}

//MARK: - setup views
extension WaterTankDetailsVC {
    
    func setupViews() {
        self.InternalExternalXIB.title = Fields.InternalExternal.rawValue
        self.FloorXIB.title = Fields.Floor.rawValue
        self.RoomXIB.title = Fields.Room.rawValue
        self.SystemFedFromTankXIB.title = Fields.SystemFedFromTank.rawValue
        self.ApproxVolumeLitresXIB.title = Fields.ApproxVolumeLitres.rawValue
        self.InletOutletTankOrientationXIB.title = Fields.InletOutletTankOrientation.rawValue
        self.TurnoverTimeXIB.title = Fields.TurnoverTime.rawValue
        
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
        
        self.questionTableView.delegate = self
        self.questionTableView.dataSource = self

        self.InternalExternalXIB.text = Fields.InternalExternal.placeholder
        self.setupInternalExternalMenu()
        self.FloorXIB.text = Fields.Floor.placeholder
        self.setupFloorMenu()
        self.RoomXIB.text = Fields.Room.placeholder
        self.setupRoomMenu()
        self.InletOutletTankOrientationXIB.text = Fields.InletOutletTankOrientation.placeholder
        self.setupInletOutletTankOrientationMenu()
        self.TurnoverTimeXIB.text = Fields.TurnoverTime.placeholder
        self.setupTurnoverTimeMenu()
        
        self.volumeStepper = self.ApproxVolumeLitresXIB.tfData.setupStepper(valueHandler: { [weak self] value in
            guard let self else { return }
            let tf: UITextField! = self.ApproxVolumeLitresXIB.tfData
            tf.text = String(value)
            self.response?.volume = value.stringValue
        })
        self.ApproxVolumeLitresXIB.tfData.textChanged { [weak self] in
            guard let self else { return }
            let tf: UITextField! = self.ApproxVolumeLitresXIB.tfData
            if let value = Int(tf.text ?? "") {
                self.volumeStepper?.value = Double(value)
                self.response?.volume = value.stringValue
            }
        }
        self.SystemFedFromTankXIB.tfData.textChanged { [weak self] in
            guard let self else { return }
            let tf: UITextField! = self.SystemFedFromTankXIB.tfData
            self.response?.systemFed = tf.text
        }
        
        self.reloadViews()
    }
    
    func reloadViews() {
        if self.itemArray.isEmpty {
            self.itemArray = [SiteCheckWaterTank()]
        }
        
        guard let response else { return }
        let bgColor = self.fieldBGColor
        
        self.InternalExternalXIB.bgColor = bgColor
        self.InternalExternalXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.FloorXIB.bgColor = bgColor
        self.FloorXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.RoomXIB.bgColor = bgColor
        self.RoomXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.SystemFedFromTankXIB.bgColor = bgColor
        self.SystemFedFromTankXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ApproxVolumeLitresXIB.bgColor = bgColor
        self.ApproxVolumeLitresXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.InletOutletTankOrientationXIB.bgColor = bgColor
        self.InletOutletTankOrientationXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.TurnoverTimeXIB.bgColor = bgColor
        self.TurnoverTimeXIB.isUserInteractionEnabled = self.isFieldsEditable
        
        if let value = response.internalExternal {
            self.InternalExternalXIB.text = value
            self.setupInternalExternalMenu()
        }
        if let value = response.floor?.intValue, let item = self.selectedFloorItemArray.first(where: { $0.id == value }) {
            self.FloorXIB.text = item.nodeName ?? Fields.Floor.placeholder
            self.setupFloorMenu()
        }
        if let value = response.room?.intValue, let item = self.selectedRoomItemArray.first(where: { $0.id == value }) {
            self.RoomXIB.text = item.nodeName ?? Fields.Room.placeholder
            self.setupRoomMenu()
        }
        if let value = response.orientation, let item = self.InletOutletTankOrientationItemArray.first(where: { $0 == value }) {
            self.InletOutletTankOrientationXIB.text = item
            self.setupInletOutletTankOrientationMenu()
        }
        if let value = response.turnoverTime, let item = self.TurnoverTimeItemArray.first(where: { $0 == value }) {
            self.TurnoverTimeXIB.text = item
            self.setupTurnoverTimeMenu()
        }
        self.SystemFedFromTankXIB.text = response.systemFed
        self.ApproxVolumeLitresXIB.text = response.volume?.intValue?.stringValue ?? ""
        
        //if let assets = response.assets {
        //    let idArray = assets.components(separatedBy: ",").compactMap({ Int($0) })
        //    self.selectedAssetsItemArray = self.assetsItemArray.filter({ idArray.contains($0.assetId ?? -1) })
        //    self.reloadSearchAssetCV(assetId: nil)
        //}
        
    }
    
    func setupInletOutletTankOrientationMenu() {
        let view: OptionBtnWithTitleXIB = self.InletOutletTankOrientationXIB
        let defaultStr = Fields.InternalExternal.placeholder
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.orientation = item
            view.text = item ?? defaultStr
            self.setupInletOutletTankOrientationMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.response?.orientation == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.InletOutletTankOrientationItemArray {
            let action = UIAction(title: item, state: self.response?.orientation == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupTurnoverTimeMenu() {
        let view: OptionBtnWithTitleXIB = self.TurnoverTimeXIB
        let defaultStr = Fields.TurnoverTime.placeholder
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.turnoverTime = item
            view.text = item ?? defaultStr
            self.setupTurnoverTimeMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.response?.turnoverTime == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.TurnoverTimeItemArray {
            let action = UIAction(title: item, state: self.response?.turnoverTime == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupInternalExternalMenu() {
        let view: OptionBtnWithTitleXIB = self.InternalExternalXIB
        let defaultStr = Fields.InternalExternal.placeholder
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.internalExternal = item
            view.text = item ?? defaultStr
            self.setupInternalExternalMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.response?.internalExternal == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in positionItemArray {
            let action = UIAction(title: item, state: self.response?.internalExternal == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupFloorMenu() {
        let view: OptionBtnWithTitleXIB = self.FloorXIB
        let defaultStr = Fields.Floor.placeholder
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.floor = item?.id?.stringValue
            view.text = item?.nodeName ?? defaultStr
            self.setupFloorMenu()
        }
        
        var actions: [UIMenuElement] = []
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
    
    func setupRoomMenu() {
        let view: OptionBtnWithTitleXIB = self.RoomXIB
        let defaultStr = Fields.Room.placeholder
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.room = item?.id?.stringValue
            view.text = item?.nodeName ?? defaultStr
            self.setupRoomMenu()
        }
        
        var actions: [UIMenuElement] = []
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
    

}

//MARK: - UITextFieldDelegate
extension WaterTankDetailsVC: UITextFieldDelegate {
    
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

//MARK: - Search Table View
extension WaterTankDetailsVC {
    
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
            
            //self.response?.assets = self.selectedAssetsItemArray.compactMap({ $0.assetId }).compactMap({ String($0) }).joined(separator: ",")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.searchAssetCV.reloadData()
                completion?()
            }
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension WaterTankDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

//MARK: UITableViewDelegate, UITableViewDataSource
extension WaterTankDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentQuestionTableCell", for: indexPath) as! AssessmentQuestionTableCell
        cell.selectionStyle = .none
        
        if self.questionItemArray.count > indexPath.row {
            let item = self.questionItemArray[indexPath.row]
            cell.mainLbl.text = item.quesiton.rawValue
            
            cell.yesXIB.isOn = item.answer == true
            cell.noXIB.isOn = item.answer == false
            cell.yesXIB.isDisabled = false
            cell.noXIB.isDisabled = false
            
            cell.yesXIB.actionBtn.addAction { [weak self] in
                guard let self else { return }
                self.questionItemArray[indexPath.row].answer = true
                cell.yesXIB.isOn = true
                cell.noXIB.isOn = !cell.yesXIB.isOn
            }
            cell.noXIB.actionBtn.addAction { [weak self] in
                guard let self else { return }
                self.questionItemArray[indexPath.row].answer = false
                cell.noXIB.isOn = true
                cell.yesXIB.isOn = !cell.noXIB.isOn
            }
        }
        return cell
    }
    
}
