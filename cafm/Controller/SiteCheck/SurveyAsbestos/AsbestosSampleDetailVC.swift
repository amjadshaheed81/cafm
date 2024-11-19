//
//  AsbestosSampleDetailVC.swift
//  cafm
//
//  Created by NS on 05/10/24.
//
//

import UIKit
import ImageScrollView
import SCLAlertView

class AsbestosSampleDetailVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var clickToUploadMainView: UIView!
    @IBOutlet weak var clickToUploadMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadXIB: ClickToUploadXIB!
    @IBOutlet weak var clickToUploadCVMainView: UIView!
    @IBOutlet weak var clickToUploadCVMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clickToUploadCV: UICollectionView!
    
    @IBOutlet weak var DownloadImageButtonsView: UIView!
    @IBOutlet weak var DownloadImageButtonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var DownloadImageBtn: PrimaryButton!
    
    @IBOutlet weak var SampleNumberXIB: TextFiledDataXib!
    @IBOutlet weak var InternalExternalXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var FloorXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var RoomXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var AreaXIB: TextFiledDataXib!
    @IBOutlet weak var QuantityXIB: TextFiledDataXib!
    @IBOutlet weak var HSENotifiableXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var LicensedMaterialXIB: TextFiledDataXib!
    @IBOutlet weak var IdentificationXIB: TextFiledDataXib!
    @IBOutlet weak var Mark_sample_as_removedXIB: CheckboxLabelXIB!
    @IBOutlet weak var SurveyorCommentsXIB: TextViewWithTitleXIB!
    @IBOutlet weak var ProductTypeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var DamageXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var SurfaceTreatmentXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var AsbestosTypeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Main_type_of_activity_in_areaXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Secondary_activities_in_areaXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var LocationXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var AccessibilityXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var ExtentAmountXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Number_of_occupantsXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Frequency_of_use_of_areaXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Average_useXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Maintenance_activity_typeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Maintenance_activity_freqXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var MatScoreXIB: TextFiledDataXib!
    @IBOutlet weak var PriScoreXIB: TextFiledDataXib!
    @IBOutlet weak var TotalScoreXIB: TextFiledDataXib!
    @IBOutlet weak var Options_for_managing_ACMsXIB: TextViewWithTitleXIB!
    @IBOutlet weak var MeasuresRequiredXIB: TextViewWithTitleXIB!
    @IBOutlet weak var RemedialCostXIB: TextFiledDataXib!
    @IBOutlet weak var NextInspectionDateXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var ApplyLabelsXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Permit_to_Work_RequiredXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var riskScoreImageSV: ImageScrollView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelBtn: ActionButton!
    @IBOutlet weak var saveBtn: PrimaryButton!
    
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
    weak var asbestosSampleVC: AsbestosSampleVC?
    var siteCheckModel: SiteCheckModel?
    var response: SiteCheckAsbestosSample?
    var asbestosLOVDict: [LOVTypeEnum: [LOV_Model]] = [:]
    var siteLayoutItemArray: [SiteLayoutModel] = []
    
    var selectedLOVIds: [LOVTypeEnum: Int?] = [:]
    
    private let Number_of_occupants_ItemArray: [String] = [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        ">10",
    ]
    private lazy var selectedFloorItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .floor }
    }()
    private lazy var selectedRoomItemArray: [SiteLayoutModel] = {
        return self.siteLayoutItemArray.filter { $0.nodeType == .room }
    }()
    
    private var isFieldsEditable: Bool {
        return true
        //return self.response?.sampleId == nil
    }
    private var fieldBGColor: UIColor {
        return self.isFieldsEditable ? UIColor.white : UIColor(appColor: .GrayStatusBG)
    }
    
    private let uploadImageFileTag = 1
    private let NextInspectionDateTag = 2
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let asbestosDataSavedStr = "Asbestos data saved"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = getSiteCheckAsbestosSampleNo(self.response)
        if self.isFieldsEditable {
            let saveBtn = getPrimaryNavigationBtn(title: "Save")
            saveBtn.addTarget(self, action: #selector(self.saveBtnClicked(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getValue<T>(_ model: SiteCheckAsbestosSample, keyPath: AnyKeyPath) -> T? {
        if let keyPath = keyPath as? KeyPath<SiteCheckAsbestosSample, T?> {
            return model[keyPath: keyPath]
        }
        return nil
    }
    
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        guard let response else { return }
        
        response.area = self.AreaXIB.text?.trimmingSpacesAndLines()
        response.quantity = self.QuantityXIB.text?.trimmingSpacesAndLines().intValue
        response.licensedMaterial = self.LicensedMaterialXIB.text?.trimmingSpacesAndLines()
        response.identification = self.IdentificationXIB.text?.trimmingSpacesAndLines()
        response.removedFromSite = self.Mark_sample_as_removedXIB.isOn
        response.comment = self.SurveyorCommentsXIB.text?.trimmingSpacesAndLines()
        response.acmOption = self.Options_for_managing_ACMsXIB.text?.trimmingSpacesAndLines()
        response.measureAction = self.MeasuresRequiredXIB.text?.trimmingSpacesAndLines()
        response.remedialCost = self.RemedialCostXIB.text?.trimmingSpacesAndLines().intValue
        
        for fields in Fields.allCases {
            let valueString: String? = getValue(response, keyPath: fields.keyPath)
            let valueInt: Int? = getValue(response, keyPath: fields.keyPath)
            if fields == .SampleImage {
                if (valueString != nil && !(valueString?.isEmpty ?? true)) || response.selectedFile != nil {
                }else {
                    SCLAlertView.showErrorAlert(title: "Error", message: fields.errorMessage, cancelButtonTitle: "OK")
                    return
                }
            }else if fields == .SampleNumber {
            }else if fields == .Mark_sample_as_removed {
            }else {
                if (valueString != nil && !(valueString?.isEmpty ?? true)) || valueInt != nil {
                    //model[keyPath: fields.keyPath] = value
                }else {
                    SCLAlertView.showErrorAlert(title: "Error", message: fields.errorMessage, cancelButtonTitle: "OK")
                    return
                }
            }
        }
        
        let model = SiteCheckAsbestosSample()
        model.update = true
        model.expanded = false
        model.siteId = UserConstants.shared.selectedSiteID
        model.checkId = self.siteCheckModel?.checkId
        model.status = "Pending"
        
        model.selectedFile = response.selectedFile
        model.sampleNo = "AS00NaN"
        //model.sampleNo = getSiteCheckAsbestosSampleNo(response)
        
        model.sampleFileUrl = response.sampleFileUrl
        //model.sampleId = response.sampleId
        //model.position = response.position
        model.riskType = response.position
        model.floor = response.floor
        model.room = response.room
        model.area = response.area
        model.quantity = response.quantity
        model.hseNotification = response.hseNotification
        model.licensedMaterial = response.licensedMaterial
        model.identification = response.identification
        model.removedFromSite = response.removedFromSite
        model.comment = response.comment
        model.productType = response.productType
        model.damage = response.damage
        model.surfaceTreatment = response.surfaceTreatment
        model.asbestosType = response.asbestosType
        model.mainActivityScore = response.mainActivityScore
        model.secondaryActivityScore = response.secondaryActivityScore
        model.location = response.location
        model.accessibility = response.accessibility
        model.extent = response.extent
        model.occupants = response.occupants
        model.frequencyOfUse = response.frequencyOfUse
        model.avgTimeInUse = response.avgTimeInUse
        model.maintenanceActivityType = response.maintenanceActivityType
        model.maintenanceFrequency = response.maintenanceFrequency
        model.totalMatScore = response.totalMatScore
        model.totalPriScore = response.totalPriScore
        model.totalRiskScore = response.totalRiskScore
        model.acmOption = response.acmOption
        model.measureAction = response.measureAction
        model.remedialCost = response.remedialCost
        model.nextInspectionDate = response.nextInspectionDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: kRequestDateFormat)
        model.labels = response.labels
        model.ptwRequired = response.ptwRequired
        
        self.uploadSiteCheckFile(model: model) { [weak self] in
            guard self != nil else { return }
        }
    }
    
    @IBAction func DownloadImageBtnClicked(_ sender: UIButton) {
        if var url = self.response?.sampleFileUrl {
            if let sasToken = UserConstants.shared.sasToken {
                url = url+"?"+sasToken
            }
            CAFMFileUtils.shared.downloadAndShareFile(url, from: self, sender: sender, shouldDeleteAfterSharing: true)
        }else {
            
        }
    }
    
}

//MARK: - Fields enum
extension AsbestosSampleDetailVC {
    enum FieldGroups: String, CaseIterable {
        case SampleInformation = "Sample Information"
        case MaterialAssessment = "Material Assessment"
        case PriorityAssessment = "Priority Assessment"
        case Outcome = "Outcome"
    }
    
    enum PriorityAssessmentGroups: String, CaseIterable {
        case NORMAL_ACTIVITY = "NORMAL ACTIVITY"
        case DISTURBANCE_LIKELIHOOD = "DISTURBANCE LIKELIHOOD"
        case HUMAN_EXPOSURE_POTENTIAL = "HUMAN EXPOSURE POTENTIAL"
        case HUMAN_EXPOSURE_POTENTIAL_ = "HUMAN EXPOSURE POTENTIAL "
    }
    
    enum Fields: String, CaseIterable {
        case SampleImage = "Sample Image"
        case SampleNumber = "Sample Number"
        case InternalExternal = "Internal/External"
        case Floor = "Floor"
        case Room = "Room"
        case Area = "Area"
        case Quantity = "Quantity"
        case HSENotifiable = "HSE Notifiable"
        case LicensedMaterial = "Licensed Material"
        case Identification = "Identification"
        case Mark_sample_as_removed = "Mark sample as removed"
        case SurveyorComments = "Surveyor Comments"
        
        case ProductType = "Product Type"
        case Damage = "Damage"
        case SurfaceTreatment = "Surface Treatment"
        case AsbestosType = "Asbestos Type"
        
        case Main_type_of_activity_in_area = "Main type of activity in area"
        case Secondary_activities_in_area = "Secondary activities in area"
        
        case Location = "Location"
        case Accessibility = "Accessibility"
        case ExtentAmount = "Extent/Amount"
        
        case Number_of_occupants = "Number of occupants"
        case Frequency_of_use_of_area = "Frequency of use of area"
        case Average_use = "Average use"
        
        case Maintenance_activity_type = "Maintenance activity type"
        case Maintenance_activity_freq = "Maintenance activity freq."
        
        case MatScore = "Mat Score"
        case PriScore = "Pri Score"
        case TotalScore = "Total Score"
        case Options_for_managing_ACMs = "Options for managing ACMs"
        case MeasuresRequired = "Measures Required"
        case RemedialCost = "Remedial Cost"
        case NextInspectionDate = "Next Inspection Date"
        case ApplyLabels = "Apply Labels"
        case Permit_to_Work_Required = "Permit to Work Required"
        
        static var dropDownArray: [Fields] {
            [.InternalExternal, .Floor, .Room, .HSENotifiable, .ProductType, .Damage, .SurfaceTreatment, .AsbestosType, .Main_type_of_activity_in_area, .Secondary_activities_in_area, .Location, .Accessibility, .ExtentAmount, .Number_of_occupants, .Frequency_of_use_of_area, .Average_use, .Maintenance_activity_type, .Maintenance_activity_freq, .NextInspectionDate, .ApplyLabels, .Permit_to_Work_Required]
        }
        
        var placeholder: String {
            if self == .SampleImage {
                return "Click to upload or drag and drop PNG/JPG (max, 1MB)"
            }else if Fields.dropDownArray.contains(self) {
                return "Select \(self.rawValue)"
            }else {
                return "Enter \(self.rawValue)"
            }
        }
        
        var errorMessage: String {
            if self == .SampleImage {
                return "Please select \(self.rawValue)"
            }else if Fields.dropDownArray.contains(self) {
                return "Please select \(self.rawValue)"
            }else {
                return "Please enter \(self.rawValue)"
            }
        }
        
        var lovType: LOVTypeEnum? {
            switch self {
            case .ProductType: return .ASBESTOS_MATERIAL_ASSESSMENT_PRODUCT_TYPE
            case .Damage: return .ASBESTOS_MATERIAL_DAMAGE
            case .SurfaceTreatment: return .ASBESTOS_MATERIAL_SURFACE
            case .AsbestosType: return .ASBESTOS_MATERIAL_ASBESTOS_TYPE
            case .Main_type_of_activity_in_area: return .ASBESTOS_PA_MAIN_ACTIVITY
            case .Secondary_activities_in_area: return .ASBESTOS_PA_SECONDARY_ACTIVITY
            case .Location: return .ASBESTOS_PA_LOCATION
            case .Accessibility: return .ASBESTOS_PA_ACCESSIBILITY
            case .ExtentAmount: return .ASBESTOS_PA_EXTENT_AMOUNT
            case .Frequency_of_use_of_area: return .ASBESTOS_PA_FREQUENCY_OF_USE
            case .Average_use: return .ASBESTOS_PA_AVERAGE_USE
            case .Maintenance_activity_type: return .ASBESTOS_PA_MAINTENANCE_ACTIVITY_TYPE
            case .Maintenance_activity_freq: return .ASBESTOS_PA_MAINTENANCE_ACTIVITY_FREQ
            default: return nil
            }
        }
        
        var keyPath: AnyKeyPath {
            switch self {
                //case .SampleImage: return \SiteCheckAsbestosSample.selectedFile
            case .SampleImage: return \SiteCheckAsbestosSample.sampleFileUrl
            case .SampleNumber: return \SiteCheckAsbestosSample.sampleId
            case .InternalExternal: return \SiteCheckAsbestosSample.position
            case .Floor: return \SiteCheckAsbestosSample.floor
            case .Room: return \SiteCheckAsbestosSample.room
            case .Area: return \SiteCheckAsbestosSample.area
            case .Quantity: return \SiteCheckAsbestosSample.quantity
            case .HSENotifiable: return \SiteCheckAsbestosSample.hseNotification
            case .LicensedMaterial: return \SiteCheckAsbestosSample.licensedMaterial
            case .Identification: return \SiteCheckAsbestosSample.identification
            case .Mark_sample_as_removed: return \SiteCheckAsbestosSample.removedFromSite
            case .SurveyorComments: return \SiteCheckAsbestosSample.comment
            case .ProductType: return \SiteCheckAsbestosSample.productType
            case .Damage: return \SiteCheckAsbestosSample.damage
            case .SurfaceTreatment: return \SiteCheckAsbestosSample.surfaceTreatment
            case .AsbestosType: return \SiteCheckAsbestosSample.asbestosType
            case .Main_type_of_activity_in_area: return \SiteCheckAsbestosSample.mainActivityScore
            case .Secondary_activities_in_area: return \SiteCheckAsbestosSample.secondaryActivityScore
            case .Location: return \SiteCheckAsbestosSample.location
            case .Accessibility: return \SiteCheckAsbestosSample.accessibility
            case .ExtentAmount: return \SiteCheckAsbestosSample.extent
            case .Number_of_occupants: return \SiteCheckAsbestosSample.occupants
            case .Frequency_of_use_of_area: return \SiteCheckAsbestosSample.frequencyOfUse
            case .Average_use: return \SiteCheckAsbestosSample.avgTimeInUse
            case .Maintenance_activity_type: return \SiteCheckAsbestosSample.maintenanceActivityType
            case .Maintenance_activity_freq: return \SiteCheckAsbestosSample.maintenanceFrequency
            case .MatScore: return \SiteCheckAsbestosSample.totalMatScore
            case .PriScore: return \SiteCheckAsbestosSample.totalPriScore
            case .TotalScore: return \SiteCheckAsbestosSample.totalRiskScore
            case .Options_for_managing_ACMs: return \SiteCheckAsbestosSample.acmOption
            case .MeasuresRequired: return \SiteCheckAsbestosSample.measureAction
            case .RemedialCost: return \SiteCheckAsbestosSample.remedialCost
            case .NextInspectionDate: return \SiteCheckAsbestosSample.nextInspectionDate
            case .ApplyLabels: return \SiteCheckAsbestosSample.labels
            case .Permit_to_Work_Required: return \SiteCheckAsbestosSample.ptwRequired
            }
        }
        
    }
}

//MARK: - EmptyViewDelegate
extension AsbestosSampleDetailVC: EmptyViewDelegate {
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
extension AsbestosSampleDetailVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func uploadSiteCheckFile(model: SiteCheckAsbestosSample, successCompletion: @escaping SuccessCompletion) {
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
                model.sampleFileUrl = success
                self.saveSiteCheckAsbestosSample(model: model, successCompletion: successCompletion)
                break
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
    func saveSiteCheckAsbestosSample(model: SiteCheckAsbestosSample, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.postSiteCheckAsbestosSample(model: model)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckAsbestosSample>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if single.sampleId != nil {
                        self.response = single
                        self.addSiteCheckVC?.getSiteCheckAsbestosSampleByCheckId(vc: self)
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
    
    func reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: [SiteCheckAsbestosSample]) {
        self.asbestosSampleVC?.reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: array)
        if let first = array.first(where: { $0.sampleId == self.response?.sampleId }) {
            self.response = first
        }
        self.reloadViews()
        self.loadingSCLAlertView.hideView()
        SCLAlertView().showSuccess("", subTitle: self.asbestosDataSavedStr)
    }
    
}

//MARK: - setup views
extension AsbestosSampleDetailVC {
    
    func setupViews() {
        
        self.SampleNumberXIB.title = Fields.SampleNumber.rawValue
        self.InternalExternalXIB.title = Fields.InternalExternal.rawValue
        self.FloorXIB.title = Fields.Floor.rawValue
        self.RoomXIB.title = Fields.Room.rawValue
        self.AreaXIB.title = Fields.Area.rawValue
        self.QuantityXIB.title = Fields.Quantity.rawValue
        self.HSENotifiableXIB.title = Fields.HSENotifiable.rawValue
        self.LicensedMaterialXIB.title = Fields.LicensedMaterial.rawValue
        self.IdentificationXIB.title = Fields.Identification.rawValue
        self.Mark_sample_as_removedXIB.title = Fields.Mark_sample_as_removed.rawValue
        self.SurveyorCommentsXIB.title = Fields.SurveyorComments.rawValue
        self.ProductTypeXIB.title = Fields.ProductType.rawValue
        self.DamageXIB.title = Fields.Damage.rawValue
        self.SurfaceTreatmentXIB.title = Fields.SurfaceTreatment.rawValue
        self.AsbestosTypeXIB.title = Fields.AsbestosType.rawValue
        self.Main_type_of_activity_in_areaXIB.title = Fields.Main_type_of_activity_in_area.rawValue
        self.Secondary_activities_in_areaXIB.title = Fields.Secondary_activities_in_area.rawValue
        self.LocationXIB.title = Fields.Location.rawValue
        self.AccessibilityXIB.title = Fields.Accessibility.rawValue
        self.ExtentAmountXIB.title = Fields.ExtentAmount.rawValue
        self.Number_of_occupantsXIB.title = Fields.Number_of_occupants.rawValue
        self.Frequency_of_use_of_areaXIB.title = Fields.Frequency_of_use_of_area.rawValue
        self.Average_useXIB.title = Fields.Average_use.rawValue
        self.Maintenance_activity_typeXIB.title = Fields.Maintenance_activity_type.rawValue
        self.Maintenance_activity_freqXIB.title = Fields.Maintenance_activity_freq.rawValue
        self.MatScoreXIB.title = Fields.MatScore.rawValue
        self.PriScoreXIB.title = Fields.PriScore.rawValue
        self.TotalScoreXIB.title = Fields.TotalScore.rawValue
        self.Options_for_managing_ACMsXIB.title = Fields.Options_for_managing_ACMs.rawValue
        self.MeasuresRequiredXIB.title = Fields.MeasuresRequired.rawValue
        self.RemedialCostXIB.title = Fields.RemedialCost.rawValue
        self.NextInspectionDateXIB.title = Fields.NextInspectionDate.rawValue
        self.ApplyLabelsXIB.title = Fields.ApplyLabels.rawValue
        self.Permit_to_Work_RequiredXIB.title = Fields.Permit_to_Work_Required.rawValue
        
        if self.isFieldsEditable {
            CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.clickToUploadXIB.actionBtn, tag: self.uploadImageFileTag, allowPhotos: true, supportedTypes: [.image, .pdf])
            self.clickToUploadCV.delegate = self
            self.clickToUploadCV.dataSource = self
        }
        self.QuantityXIB.tfData.keyboardType = .numberPad
        self.Mark_sample_as_removedXIB.actionHandler = { [weak self] bool in
            guard let self else { return }
            self.response?.removedFromSite = bool
        }
        
        self.riskScoreImageSV.setup()
        if let image = UIImage(named: "img_risk_scorecard_assessment") {
            self.riskScoreImageSV.imageContentMode = .heightFill
            self.riskScoreImageSV.display(image: image)
        }
        self.RemedialCostXIB.tfData.keyboardType = .numberPad
        self.NextInspectionDateXIB.text = ddMMyyyyStr
        self.NextInspectionDateXIB.image = UIImage(systemName: "calendar")
        self.NextInspectionDateXIB.optionXIB.btnDownClick.tag = self.NextInspectionDateTag
        self.NextInspectionDateXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.NextInspectionDateXIB.optionXIB.btnDownClick
            let date = self.response?.nextInspectionDate?.transformToDate(dateFormat: kResponseDateFormat)
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.response?.nextInspectionDate = date?.transformToString(dateFormat: kResponseDateFormat)
                self.NextInspectionDateXIB.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
            }
        }
        
        self.reloadViews()
    }
    
    func reloadViews() {
        if self.response == nil {
            self.response = SiteCheckAsbestosSample()
        }
        guard let response else { return }
        
        let bgColor = self.fieldBGColor
        
        self.SampleNumberXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.SampleNumberXIB.isUserInteractionEnabled = false
        self.InternalExternalXIB.bgColor = bgColor
        self.InternalExternalXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.FloorXIB.bgColor = bgColor
        self.FloorXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.RoomXIB.bgColor = bgColor
        self.RoomXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.AreaXIB.bgColor = bgColor
        self.AreaXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.QuantityXIB.bgColor = bgColor
        self.QuantityXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.HSENotifiableXIB.bgColor = bgColor
        self.HSENotifiableXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.LicensedMaterialXIB.bgColor = bgColor
        self.LicensedMaterialXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.IdentificationXIB.bgColor = bgColor
        self.IdentificationXIB.isUserInteractionEnabled = self.isFieldsEditable
        //self.Mark_sample_as_removedXIB.bgColor = bgColor
        self.Mark_sample_as_removedXIB.isDisabled = !self.isFieldsEditable
        self.Mark_sample_as_removedXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.SurveyorCommentsXIB.bgColor = bgColor
        self.SurveyorCommentsXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ProductTypeXIB.bgColor = bgColor
        self.ProductTypeXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.DamageXIB.bgColor = bgColor
        self.DamageXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.SurfaceTreatmentXIB.bgColor = bgColor
        self.SurfaceTreatmentXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.AsbestosTypeXIB.bgColor = bgColor
        self.AsbestosTypeXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Main_type_of_activity_in_areaXIB.bgColor = bgColor
        self.Main_type_of_activity_in_areaXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Secondary_activities_in_areaXIB.bgColor = bgColor
        self.Secondary_activities_in_areaXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.LocationXIB.bgColor = bgColor
        self.LocationXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.AccessibilityXIB.bgColor = bgColor
        self.AccessibilityXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ExtentAmountXIB.bgColor = bgColor
        self.ExtentAmountXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Number_of_occupantsXIB.bgColor = bgColor
        self.Number_of_occupantsXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Frequency_of_use_of_areaXIB.bgColor = bgColor
        self.Frequency_of_use_of_areaXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Average_useXIB.bgColor = bgColor
        self.Average_useXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Maintenance_activity_typeXIB.bgColor = bgColor
        self.Maintenance_activity_typeXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Maintenance_activity_freqXIB.bgColor = bgColor
        self.Maintenance_activity_freqXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.MatScoreXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.MatScoreXIB.isUserInteractionEnabled = false
        self.PriScoreXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.PriScoreXIB.isUserInteractionEnabled = false
        self.TotalScoreXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.TotalScoreXIB.isUserInteractionEnabled = false
        self.Options_for_managing_ACMsXIB.bgColor = bgColor
        self.Options_for_managing_ACMsXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.MeasuresRequiredXIB.bgColor = bgColor
        self.MeasuresRequiredXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.RemedialCostXIB.bgColor = bgColor
        self.RemedialCostXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.NextInspectionDateXIB.bgColor = bgColor
        self.NextInspectionDateXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.ApplyLabelsXIB.bgColor = bgColor
        self.ApplyLabelsXIB.isUserInteractionEnabled = self.isFieldsEditable
        self.Permit_to_Work_RequiredXIB.bgColor = bgColor
        self.Permit_to_Work_RequiredXIB.isUserInteractionEnabled = self.isFieldsEditable
        
        self.DownloadImageButtonsView.isHidden = response.sampleFileUrl == nil
        self.DownloadImageButtonsViewHeight.constant = self.DownloadImageButtonsView.isHidden ? 0 : 64
        self.DownloadImageButtonsView.frame.size.height = self.DownloadImageButtonsViewHeight.constant
        
        self.SampleNumberXIB.text = getSiteCheckAsbestosSampleNo(response)
        
        if let value = response.position {
            self.InternalExternalXIB.text = value
            self.setupInternalExternalMenu()
        }else {
            self.reloadInternalExternalXIB()
        }
        if let value = response.floor?.intValue, let item = self.selectedFloorItemArray.first(where: { $0.id == value }) {
            self.FloorXIB.text = item.nodeName ?? Fields.Floor.placeholder
            self.setupFloorMenu()
        }else {
            self.reloadFloorXIB()
        }
        if let value = response.room?.intValue, let item = self.selectedRoomItemArray.first(where: { $0.id == value }) {
            self.RoomXIB.text = item.nodeName ?? Fields.Room.placeholder
            self.setupRoomMenu()
        }else {
            self.reloadRoomXIB()
        }
        
        self.AreaXIB.text = response.area
        self.QuantityXIB.text = response.quantity?.stringValue
        self.LicensedMaterialXIB.text = response.licensedMaterial
        self.IdentificationXIB.text = response.identification
        self.Mark_sample_as_removedXIB.isOn = response.removedFromSite ?? false
        self.SurveyorCommentsXIB.text = response.comment
        
        self.Number_of_occupantsXIB.text = response.occupants?.stringValue ?? Fields.Number_of_occupants.placeholder
        self.setupNumber_of_occupantsMenu()
        
        self.Options_for_managing_ACMsXIB.text = response.acmOption
        self.MeasuresRequiredXIB.text = response.measureAction
        
        self.RemedialCostXIB.text = response.remedialCost?.stringValue
        self.NextInspectionDateXIB.text = response.nextInspectionDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
        
        let boolean_pair_ItemArray: [(view: OptionBtnWithTitleXIB, field: Fields, value: String?)] = [
            (view: self.HSENotifiableXIB, field: .HSENotifiable, value: response.hseNotification),
            (view: self.ApplyLabelsXIB, field: .ApplyLabels, value: response.labels),
            (view: self.Permit_to_Work_RequiredXIB, field: .Permit_to_Work_Required, value: response.ptwRequired),
        ]
        for boolean_pair in boolean_pair_ItemArray {
            boolean_pair.view.text = boolean_pair.value ?? boolean_pair.field.placeholder
            self.setupBooleanStringMenu(view: boolean_pair.view, field: boolean_pair.field)
        }
        
        let lov_pair_ItemArray: [(view: OptionBtnWithTitleXIB, field: Fields, value: String?)] = [
            (view: self.ProductTypeXIB, field: .ProductType, value: response.productType),
            (view: self.DamageXIB, field: .Damage, value: response.damage),
            (view: self.SurfaceTreatmentXIB, field: .SurfaceTreatment, value: response.surfaceTreatment),
            (view: self.AsbestosTypeXIB, field: .AsbestosType, value: response.asbestosType),
            (view: self.Main_type_of_activity_in_areaXIB, field: .Main_type_of_activity_in_area, value: response.mainActivityScore?.stringValue),
            (view: self.Secondary_activities_in_areaXIB, field: .Secondary_activities_in_area, value: response.secondaryActivityScore?.stringValue),
            (view: self.LocationXIB, field: .Location, value: response.location),
            (view: self.AccessibilityXIB, field: .Accessibility, value: response.accessibility),
            (view: self.ExtentAmountXIB, field: .ExtentAmount, value: response.extent),
            (view: self.Frequency_of_use_of_areaXIB, field: .Frequency_of_use_of_area, value: response.frequencyOfUse),
            (view: self.Average_useXIB, field: .Average_use, value: response.avgTimeInUse),
            (view: self.Maintenance_activity_typeXIB, field: .Maintenance_activity_type, value: response.maintenanceActivityType),
            (view: self.Maintenance_activity_freqXIB, field: .Maintenance_activity_freq, value: response.maintenanceFrequency),
        ]
        for lov_pair in lov_pair_ItemArray {
            if let lovType = lov_pair.field.lovType, let itemArray = self.asbestosLOVDict[lovType], let item = itemArray.first(where: { $0.lovValue == lov_pair.value }) {
                self.selectedLOVIds[lovType] = item.id
                lov_pair.view.text = getLOVDisplayStr(item) ?? lov_pair.field.placeholder
            }else {
                lov_pair.view.text = lov_pair.field.placeholder
            }
            self.setupLOVMenu(view: lov_pair.view, field: lov_pair.field)
        }
        
        self.updateOutcome()
        self.adjustClickToUploadMainView()
    }
    
    func setupNumber_of_occupantsMenu() {
        let view: OptionBtnWithTitleXIB = self.Number_of_occupantsXIB
        let defaultStr = Fields.Number_of_occupants.placeholder
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.occupants = item?.intValue
            view.text = item ?? defaultStr
            self.updateOutcome()
            self.setupNumber_of_occupantsMenu()
        }
        
        var actions: [UIMenuElement] = []
        let selectedValue = self.response?.occupants?.stringValue
        let titleAction = UIAction(title: defaultStr, state: selectedValue == nil ? .on : .off) { [weak self] _ in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.Number_of_occupants_ItemArray {
            let action = UIAction(title: item, state: selectedValue == item ? .on : .off) { [weak self] _ in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupBooleanStringMenu(view: OptionBtnWithTitleXIB, field: Fields) {
        let defaultStr = field.placeholder
        view.optionXIB.btnDownClick.menu = UIMenu.booleanStringMenu(selectTitle: defaultStr, stringValue: self.response?.hseNotification, actionHandler: { [weak self] value in
            guard let self else { return }
            switch field {
            case .HSENotifiable:
                self.response?.hseNotification = value
                break
            case .ApplyLabels:
                self.response?.labels = value
                break
            case .Permit_to_Work_Required:
                self.response?.ptwRequired = value
                break
            default:
                break
            }
            view.text = value ?? defaultStr
            self.setupBooleanStringMenu(view: view, field: field)
        })
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupLOVMenu(view: OptionBtnWithTitleXIB, field: Fields) {
        guard let lovType = field.lovType else { return }
        let defaultStr = field.placeholder
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self, let response else { return }
            self.selectedLOVIds[lovType] = item?.id
            let stringValue = item?.lovValue
            let intValue = stringValue?.intValue
            switch lovType {
            case .ASBESTOS_MATERIAL_ASSESSMENT_PRODUCT_TYPE:
                response.productType = stringValue
                break
            case .ASBESTOS_MATERIAL_DAMAGE:
                response.damage = stringValue
                break
            case .ASBESTOS_MATERIAL_SURFACE:
                response.surfaceTreatment = stringValue
                break
            case .ASBESTOS_MATERIAL_ASBESTOS_TYPE:
                response.asbestosType = stringValue
                break
            case .ASBESTOS_PA_MAIN_ACTIVITY:
                response.mainActivityScore = intValue
                break
            case .ASBESTOS_PA_SECONDARY_ACTIVITY:
                response.secondaryActivityScore = intValue
                break
            case .ASBESTOS_PA_LOCATION:
                response.location = stringValue
                break
            case .ASBESTOS_PA_ACCESSIBILITY:
                response.accessibility = stringValue
                break
            case .ASBESTOS_PA_EXTENT_AMOUNT:
                response.extent = stringValue
                break
            case .ASBESTOS_PA_FREQUENCY_OF_USE:
                response.frequencyOfUse = stringValue
                break
            case .ASBESTOS_PA_AVERAGE_USE:
                response.avgTimeInUse = stringValue
                break
            case .ASBESTOS_PA_MAINTENANCE_ACTIVITY_TYPE:
                response.maintenanceActivityType = stringValue
                break
            case .ASBESTOS_PA_MAINTENANCE_ACTIVITY_FREQ:
                response.maintenanceFrequency = stringValue
                break
            default:
                break
            }
            view.text = getLOVDisplayStr(item) ?? defaultStr
            self.updateOutcome()
            self.setupLOVMenu(view: view, field: field)
        }
        
        var actions: [UIMenuElement] = []
        let selectedId = self.selectedLOVIds[lovType]
        let titleAction = UIAction(title: defaultStr, state: selectedId == nil ? .on : .off) { [weak self] _ in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        if let itemArray = self.asbestosLOVDict[lovType] {
            for item in itemArray {
                let action = UIAction(title: getLOVDisplayStr(item) ?? "", state: selectedId == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
        }
        
        view.optionXIB.btnDownClick.menu = UIMenu(children: actions)
        view.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func updateOutcome() {
        let matScore = calculatedMatScore(self.response)
        let priScore = calculatedPriScore(self.response)
        
        self.response?.totalMatScore = matScore
        self.response?.totalPriScore = priScore
        self.response?.totalRiskScore = matScore+priScore
        
        self.MatScoreXIB.text = "\(matScore)"
        self.PriScoreXIB.text = "\(priScore)"
        self.TotalScoreXIB.text = "\(matScore+priScore)"
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
        self.InternalExternalXIB.text = Fields.InternalExternal.placeholder
        self.response?.position = nil
        self.setupInternalExternalMenu()
    }
    
    func setupInternalExternalMenu() {
        let view: OptionBtnWithTitleXIB = self.InternalExternalXIB
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
        self.FloorXIB.text = Fields.Floor.placeholder
        self.response?.floor = nil
        self.setupFloorMenu()
    }
    
    func setupFloorMenu() {
        let view: OptionBtnWithTitleXIB = self.FloorXIB
        let defaultStr = Fields.Floor.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.floor = item?.id?.stringValue
            view.text = item?.nodeName ?? defaultStr
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
        self.RoomXIB.text = Fields.Room.placeholder
        self.response?.room = nil
        self.setupRoomMenu()
    }
    
    func setupRoomMenu() {
        let view: OptionBtnWithTitleXIB = self.RoomXIB
        let defaultStr = Fields.Room.placeholder
        var actions: [UIMenuElement] = []
        
        let performAction: ((SiteLayoutModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.response?.room = item?.id?.stringValue
            view.text = item?.nodeName ?? defaultStr
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
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AsbestosSampleDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.response?.selectedFile != nil ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let selectedFileModel = self.response?.selectedFile {
            let text = selectedFileModel.fileName ?? "file"
            let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+22+5, maxWidth: collectionView.frame.width/2).width
            return CGSize(width: width, height: 40)
        }
        return CGSize.zero
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension AsbestosSampleDetailVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        self.response?.selectedFile = fileData
        self.reloadClickToUploadCV()
    }
    
    func filePickerDidClose(tag: Int) {
    }
    
}
