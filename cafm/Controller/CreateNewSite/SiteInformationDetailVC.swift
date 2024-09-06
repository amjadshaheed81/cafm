//
//  SiteInformationDetailVC.swift
//  cafm
//
//  Created by NS on 01/09/24.
//
//

import UIKit

class SiteInformationDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var screenType: SiteInformationEnum = .siteInfo {
        didSet {
            self.itemArray = self.screenType.fields
        }
    }
    var itemArray: [SiteInformationField] = []
    var siteInformationModel: SiteInformationModel?
    var isViewModeEdit: Bool = false
    
    weak var delegate: SiteInformationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func configureNavigationBar() {
        self.title = self.screenType.title
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        if self.isViewModeEdit {
            let downloadBtn = UIButton(type: .system)
            downloadBtn.addCorner()
            downloadBtn.backgroundColor = UIColor(appColor: .AppTint)
            downloadBtn.tintColor = UIColor.white
            downloadBtn.setTitle("Save", for: .normal)
            downloadBtn.titleLabel?.font = UIFont(name: .MontserratMedium, size: 15)
            downloadBtn.frame = CGRect(x: 0, y: 0, width: 8+36+8, height: 32)
            downloadBtn.addTarget(self, action: #selector(self.navSaveBtnClicked(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadBtn)
        }
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func navSaveBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.performSiteInformationSaveAction(modelType: strongSelf.screenType, model: strongSelf.siteInformationModel)
        }
    }
    
}

extension SiteInformationDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiteInformationDetailCell", for: indexPath) as! SiteInformationDetailCell
        cell.delegate = self
        cell.fieldIndex = indexPath.row
        cell.isViewModeEdit = self.isViewModeEdit
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            cell.titleLbl.text = item.rawValue
            self.setValueToFields(index: indexPath.row, cell: cell)
            cell.inputType = item.inputType
        }
        return cell
    }
    
}

extension SiteInformationDetailVC: SiteInformationDetailDelegate {
    
    func siteInformationDetailFieldValueDidChange(index: Int, stringValue: String?, intValue: Int?, doubleValue: Double?, boolValue: Bool?) {
        guard self.isViewModeEdit else { return }
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            switch item {
            case .YearOfBuild:
                self.siteInformationModel?.buildYear = intValue
            case .BuildingUnderClientControl:
                self.siteInformationModel?.buildingUnderClientControl = boolValue
            case .Canteeninbuilding:
                self.siteInformationModel?.canteenInBuilding = boolValue
            case .DedicatedKitchenArea:
                self.siteInformationModel?.dedicatedKitchenArea = boolValue
            case .TotalBuildingAreaSqm:
                self.siteInformationModel?.totalBuildingArea = intValue
            case .ClientOccupiedAreaSqm:
                self.siteInformationModel?.clientOccupiedArea = intValue
            case .TenantOccupiedAreaSqm:
                self.siteInformationModel?.tenantOccupiedArea = intValue
            case .MaximumOccupancyClient:
                self.siteInformationModel?.maxOccupancy = intValue
            case .MeetingConferencesClient:
                self.siteInformationModel?.meetingClients = boolValue
            case .NumberOfStaff:
                self.siteInformationModel?.numberOfStaff = intValue
            case .TenantsinOccupation:
                self.siteInformationModel?.tenantInOccupation = intValue
            case .NameOfTenant:
                self.siteInformationModel?.tenantName = stringValue
            case .VacantAreasinbuilding:
                self.siteInformationModel?.vacantAreaInBuilding = intValue
            case .NumberOfFloors:
                self.siteInformationModel?.numOfFloors = intValue
            case .CarkParkSpacesAboveGround:
                self.siteInformationModel?.carParkSpaceAboveGround = intValue
            case .CarkParkSpacesBelowGround:
                self.siteInformationModel?.carParkSpaceBelowGround = intValue
            case .NumberOfBasementLevels:
                self.siteInformationModel?.numOfBasementLevels = intValue
            case .ExternalFabric:
                self.siteInformationModel?.extFabric = stringValue
            case .ExternalMetallicFireEscapeStaircases:
                self.siteInformationModel?.extMetallicFireEscapeStaircases = intValue
            case .ExternalTimberFireEscapeStaircases:
                self.siteInformationModel?.extTimberFireEscapeStaircases = intValue
            case .VerticalLadder:
                self.siteInformationModel?.verticalLadder = intValue
            case .ConfinedSpaces:
                self.siteInformationModel?.confinedSpaces = boolValue
            case .AccessibleUnguardedRoofAreas:
                self.siteInformationModel?.accessibleUnguardedRoofAreas = boolValue
            case .FragileRoofsorSurfaces:
                self.siteInformationModel?.fragileRoof = boolValue
            case .LightingConductorInstallation:
                self.siteInformationModel?.lightingConductoreInstalltion = boolValue
            case .FireAlarmDetectionSystem:
                self.siteInformationModel?.fireAlarmSystem = boolValue
            case .FirePanelLocation:
                self.siteInformationModel?.firePanelLocation = stringValue
            case .OilPetrolStorageonSite:
                self.siteInformationModel?.oilStorageOnSite = boolValue
            case .LPGStorageonSite:
                self.siteInformationModel?.lpgStorageOnSite = boolValue
            case .LPGBulkStorageonSite:
                self.siteInformationModel?.lpgBulkStorageOnSite = boolValue
            case .LPGCylinderStorageonSite:
                self.siteInformationModel
            case .SprinklerSystem:
                self.siteInformationModel?.sprinklerSystem = boolValue
            case .HoseReels:
                self.siteInformationModel?.hoseReels = boolValue
            case .AreSecurityGuardsEmployed:
                self.siteInformationModel?.securityGuardEmployed = boolValue
            case .InternalCCTV:
                self.siteInformationModel?.internalCCTV = boolValue
            case .ExternalCCTV:
                self.siteInformationModel?.externalCCTV = boolValue
            case .AutomaticBarrier:
                self.siteInformationModel?.automaticBarrier = boolValue
            case .AutomaticGatesSliding:
                self.siteInformationModel?.automaticGatesSliding = boolValue
            case .AutomaticGatesHinged:
                self.siteInformationModel?.automaticGatesHinged = boolValue
            case .ManualSwingGates:
                self.siteInformationModel?.manualSwingGates = boolValue
            case .UtilityGas:
                self.siteInformationModel?.utilGas = boolValue
            case .UtilityElectricity:
                self.siteInformationModel?.utilElectricity = boolValue
            case .UtilityWater:
                self.siteInformationModel?.utilWater = boolValue
            case .UtilityTelecomData:
                self.siteInformationModel?.utilTelecom = boolValue
            case .UtilityMainsDrainage:
                self.siteInformationModel?.utilMainsDrainage = boolValue
            case .AirConditioning:
                self.siteInformationModel?.airConditioning = boolValue
            case .CoolingTower:
                self.siteInformationModel?.coolingTower = boolValue
            case .WaterIsolationValveLocationInternal:
                self.siteInformationModel?.waterIsolationValveInternal = stringValue
            case .WaterTanks:
                self.siteInformationModel?.waterTanks = boolValue
            case .WaterTankLocation:
                self.siteInformationModel?.waterTankLocation = stringValue
            case .HotWaterCalorifier:
                self.siteInformationModel?.hotWaterCalorifier = intValue
            case .HotWaterCalorifierLocation:
                self.siteInformationModel?.hotWaterCalorifierLocation = stringValue
            case .PressureVessel:
                self.siteInformationModel?.pressureVessel = intValue
            case .GasBoiler:
                self.siteInformationModel?.gasBoiler = boolValue
            case .GasBoilerLocation:
                self.siteInformationModel?.gasBoilerLocation = stringValue
            case .GasSupplyIsolationMeterLocation:
                self.siteInformationModel?.gasSupplyIsolation = stringValue
            case .GasSupplyExternalIsolationLocation:
                self.siteInformationModel?.gasSupplyExternalIsolation = stringValue
            case .ElectricnstallationMeterLocation:
                self.siteInformationModel?.electricInstallationLocation = stringValue
            case .ElectricSubStationonSite:
                self.siteInformationModel?.electricSubStationOnSite = boolValue
            case .ExternalLighting:
                self.siteInformationModel?.externalLighting = boolValue
            case .BackUpGenerator:
                self.siteInformationModel?.backupGenerator = boolValue
            case .BackUpGeneratorLocation:
                self.siteInformationModel?.backupGeneratorLocation = stringValue
            case .DisabledHoistLift:
                self.siteInformationModel?.disabledHoistLift = intValue
            case .LiftsGoodsTraction:
                self.siteInformationModel?.goodsTractionLift = intValue
            case .LiftsGoodsHydraulic:
                self.siteInformationModel?.goodsHydraulicLift = intValue
            case .LiftsPassengerTraction:
                self.siteInformationModel?.passengerTractionLift = intValue
            case .LiftsPassengerHydraulic:
                self.siteInformationModel?.passengerHydraulicLift = intValue
            case .LiftsPassengerMonospace:
                self.siteInformationModel?.passengerMonospaceLift = intValue
            case .LiftsFireFighting:
                self.siteInformationModel?.fireFightingLift = intValue
            case .LiftsFireEvacuation:
                self.siteInformationModel?.fireEvacuationLift = intValue
            case .NumberofStairwaysInternal:
                self.siteInformationModel?.internalStairways = intValue
            case .NumberofStairwaysExternal:
                self.siteInformationModel?.externalStairways = intValue
            case .HardLandscaping:
                self.siteInformationModel?.hardLandScaping = boolValue
            case .SoftLandscaping:
                self.siteInformationModel?.softLandScaping = boolValue
            case .RiversPondsLakes:
                self.siteInformationModel?.riverPondLakes = boolValue
            case .TallTrees:
                self.siteInformationModel?.tallTrees = boolValue
            case .DrainageInterceptors:
                self.siteInformationModel?.drainageInterceptors = boolValue
            case .ThirdPartyTelecommsEquipment:
                self.siteInformationModel?.thirdPartyTelEquipment = boolValue
            case .ElectricalOverheadPowerLines:
                self.siteInformationModel?.electricalOverHeadPowerLines = boolValue
            case .DemolitionSiteorVacantLandAdjacent:
                self.siteInformationModel?.vacantLandAdjacent = stringValue
            case .RiskofFlooding:
                self.siteInformationModel?.floodRisk = stringValue
            case .RailwayLineAdjacent:
                self.siteInformationModel?.railwayLineAdjacent = stringValue
            }
        }
    }
    
    func setValueToFields(index: Int, cell: SiteInformationDetailCell) {
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            switch item {
            case .YearOfBuild:
                cell.intValue = self.siteInformationModel?.buildYear
            case .BuildingUnderClientControl:
                cell.boolValue = self.siteInformationModel?.buildingUnderClientControl
            case .Canteeninbuilding:
                cell.boolValue = self.siteInformationModel?.canteenInBuilding
            case .DedicatedKitchenArea:
                cell.boolValue = self.siteInformationModel?.dedicatedKitchenArea
            case .TotalBuildingAreaSqm:
                cell.intValue = self.siteInformationModel?.totalBuildingArea
            case .ClientOccupiedAreaSqm:
                cell.intValue = self.siteInformationModel?.clientOccupiedArea
            case .TenantOccupiedAreaSqm:
                cell.intValue = self.siteInformationModel?.tenantOccupiedArea
            case .MaximumOccupancyClient:
                cell.intValue = self.siteInformationModel?.maxOccupancy
            case .MeetingConferencesClient:
                cell.boolValue = self.siteInformationModel?.meetingClients
            case .NumberOfStaff:
                cell.intValue = self.siteInformationModel?.numberOfStaff
            case .TenantsinOccupation:
                cell.intValue = self.siteInformationModel?.tenantInOccupation
            case .NameOfTenant:
                cell.stringValue = self.siteInformationModel?.tenantName
            case .VacantAreasinbuilding:
                cell.intValue = self.siteInformationModel?.vacantAreaInBuilding
            case .NumberOfFloors:
                cell.intValue = self.siteInformationModel?.numOfFloors
            case .CarkParkSpacesAboveGround:
                cell.intValue = self.siteInformationModel?.carParkSpaceAboveGround
            case .CarkParkSpacesBelowGround:
                cell.intValue = self.siteInformationModel?.carParkSpaceBelowGround
            case .NumberOfBasementLevels:
                cell.intValue = self.siteInformationModel?.numOfBasementLevels
            case .ExternalFabric:
                cell.stringValue = self.siteInformationModel?.extFabric
            case .ExternalMetallicFireEscapeStaircases:
                cell.intValue = self.siteInformationModel?.extMetallicFireEscapeStaircases
            case .ExternalTimberFireEscapeStaircases:
                cell.intValue = self.siteInformationModel?.extTimberFireEscapeStaircases
            case .VerticalLadder:
                cell.intValue = self.siteInformationModel?.verticalLadder
            case .ConfinedSpaces:
                cell.boolValue = self.siteInformationModel?.confinedSpaces
            case .AccessibleUnguardedRoofAreas:
                cell.boolValue = self.siteInformationModel?.accessibleUnguardedRoofAreas
            case .FragileRoofsorSurfaces:
                cell.boolValue = self.siteInformationModel?.fragileRoof
            case .LightingConductorInstallation:
                cell.boolValue = self.siteInformationModel?.lightingConductoreInstalltion
            case .FireAlarmDetectionSystem:
                cell.boolValue = self.siteInformationModel?.fireAlarmSystem
            case .FirePanelLocation:
                cell.stringValue = self.siteInformationModel?.firePanelLocation
            case .OilPetrolStorageonSite:
                cell.boolValue = self.siteInformationModel?.oilStorageOnSite
            case .LPGStorageonSite:
                cell.boolValue = self.siteInformationModel?.lpgStorageOnSite
            case .LPGBulkStorageonSite:
                cell.boolValue = self.siteInformationModel?.lpgBulkStorageOnSite
            case .LPGCylinderStorageonSite:
                self.siteInformationModel
            case .SprinklerSystem:
                cell.boolValue = self.siteInformationModel?.sprinklerSystem
            case .HoseReels:
                cell.boolValue = self.siteInformationModel?.hoseReels
            case .AreSecurityGuardsEmployed:
                cell.boolValue = self.siteInformationModel?.securityGuardEmployed
            case .InternalCCTV:
                cell.boolValue = self.siteInformationModel?.internalCCTV
            case .ExternalCCTV:
                cell.boolValue = self.siteInformationModel?.externalCCTV
            case .AutomaticBarrier:
                cell.boolValue = self.siteInformationModel?.automaticBarrier
            case .AutomaticGatesSliding:
                cell.boolValue = self.siteInformationModel?.automaticGatesSliding
            case .AutomaticGatesHinged:
                cell.boolValue = self.siteInformationModel?.automaticGatesHinged
            case .ManualSwingGates:
                cell.boolValue = self.siteInformationModel?.manualSwingGates
            case .UtilityGas:
                cell.boolValue = self.siteInformationModel?.utilGas
            case .UtilityElectricity:
                cell.boolValue = self.siteInformationModel?.utilElectricity
            case .UtilityWater:
                cell.boolValue = self.siteInformationModel?.utilWater
            case .UtilityTelecomData:
                cell.boolValue = self.siteInformationModel?.utilTelecom
            case .UtilityMainsDrainage:
                cell.boolValue = self.siteInformationModel?.utilMainsDrainage
            case .AirConditioning:
                cell.boolValue = self.siteInformationModel?.airConditioning
            case .CoolingTower:
                cell.boolValue = self.siteInformationModel?.coolingTower
            case .WaterIsolationValveLocationInternal:
                cell.stringValue = self.siteInformationModel?.waterIsolationValveInternal
            case .WaterTanks:
                cell.boolValue = self.siteInformationModel?.waterTanks
            case .WaterTankLocation:
                cell.stringValue = self.siteInformationModel?.waterTankLocation
            case .HotWaterCalorifier:
                cell.intValue = self.siteInformationModel?.hotWaterCalorifier
            case .HotWaterCalorifierLocation:
                cell.stringValue = self.siteInformationModel?.hotWaterCalorifierLocation
            case .PressureVessel:
                cell.intValue = self.siteInformationModel?.pressureVessel
            case .GasBoiler:
                cell.boolValue = self.siteInformationModel?.gasBoiler
            case .GasBoilerLocation:
                cell.stringValue = self.siteInformationModel?.gasBoilerLocation
            case .GasSupplyIsolationMeterLocation:
                cell.stringValue = self.siteInformationModel?.gasSupplyIsolation
            case .GasSupplyExternalIsolationLocation:
                cell.stringValue = self.siteInformationModel?.gasSupplyExternalIsolation
            case .ElectricnstallationMeterLocation:
                cell.stringValue = self.siteInformationModel?.electricInstallationLocation
            case .ElectricSubStationonSite:
                cell.boolValue = self.siteInformationModel?.electricSubStationOnSite
            case .ExternalLighting:
                cell.boolValue = self.siteInformationModel?.externalLighting
            case .BackUpGenerator:
                cell.boolValue = self.siteInformationModel?.backupGenerator
            case .BackUpGeneratorLocation:
                cell.stringValue = self.siteInformationModel?.backupGeneratorLocation
            case .DisabledHoistLift:
                cell.intValue = self.siteInformationModel?.disabledHoistLift
            case .LiftsGoodsTraction:
                cell.intValue = self.siteInformationModel?.goodsTractionLift
            case .LiftsGoodsHydraulic:
                cell.intValue = self.siteInformationModel?.goodsHydraulicLift
            case .LiftsPassengerTraction:
                cell.intValue = self.siteInformationModel?.passengerTractionLift
            case .LiftsPassengerHydraulic:
                cell.intValue = self.siteInformationModel?.passengerHydraulicLift
            case .LiftsPassengerMonospace:
                cell.intValue = self.siteInformationModel?.passengerMonospaceLift
            case .LiftsFireFighting:
                cell.intValue = self.siteInformationModel?.fireFightingLift
            case .LiftsFireEvacuation:
                cell.intValue = self.siteInformationModel?.fireEvacuationLift
            case .NumberofStairwaysInternal:
                cell.intValue = self.siteInformationModel?.internalStairways
            case .NumberofStairwaysExternal:
                cell.intValue = self.siteInformationModel?.externalStairways
            case .HardLandscaping:
                cell.boolValue = self.siteInformationModel?.hardLandScaping
            case .SoftLandscaping:
                cell.boolValue = self.siteInformationModel?.softLandScaping
            case .RiversPondsLakes:
                cell.boolValue = self.siteInformationModel?.riverPondLakes
            case .TallTrees:
                cell.boolValue = self.siteInformationModel?.tallTrees
            case .DrainageInterceptors:
                cell.boolValue = self.siteInformationModel?.drainageInterceptors
            case .ThirdPartyTelecommsEquipment:
                cell.boolValue = self.siteInformationModel?.thirdPartyTelEquipment
            case .ElectricalOverheadPowerLines:
                cell.boolValue = self.siteInformationModel?.electricalOverHeadPowerLines
            case .DemolitionSiteorVacantLandAdjacent:
                cell.stringValue = self.siteInformationModel?.vacantLandAdjacent
            case .RiskofFlooding:
                cell.stringValue = self.siteInformationModel?.floodRisk
            case .RailwayLineAdjacent:
                cell.stringValue = self.siteInformationModel?.railwayLineAdjacent
            }
            cell.setValueToField()
        }
    }
    
}

class SiteInformationDetailCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var textFieldView: DesignableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightSideView: UIView!
    @IBOutlet weak var rightSideViewWidth: NSLayoutConstraint!
    @IBOutlet weak var rightSideImageView: UIImageView!
    @IBOutlet weak var rightSideStepper: UIStepper!
    @IBOutlet weak var actionBtn: UIButton!
    
    weak var delegate: SiteInformationDetailDelegate?
    var inputType: SiteInformationField.InputType = .string {
        didSet {
            self.setViewAsPerFieldType()
        }
    }
    var fieldIndex: Int = -1
    var isViewModeEdit: Bool = false
    
    var stringValue: String?
    var intValue: Int?
    var doubleValue: Double?
    var boolValue: Bool?
    
    func setValueToField() {
        if let stringValue {
            self.textField.text = stringValue
        }else if let intValue {
            self.textField.text = "\(intValue)"
        }else if let doubleValue {
            self.textField.text = "\(doubleValue)"
        }else if let boolValue {
            if boolValue {
                self.textField.text = "Yes"
            }else {
                self.textField.text = "No"
            }
        }else {
            self.textField.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLbl.text = nil
        self.textField.text = nil
        self.fieldIndex = -1
        self.stringValue = nil
        self.intValue = nil
        self.doubleValue = nil
        self.boolValue = nil
    }
    
    func setViewAsPerFieldType() {
        self.textFieldView.backgroundColor = self.isViewModeEdit ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        switch inputType {
        case .intergerPicker(let values):
            if self.isViewModeEdit {
                self.actionBtn.menu = self.intergerPickerMenu(values)
            }
            self.setupPickerMenu()
            break
        case .string:
            self.setupTextField()
            self.textField.keyboardType = .default
            break
        case .boolean:
            self.actionBtn.menu = self.booleanMenu()
            self.setupDropDownMenu()
            break
        case .integer:
            self.setupTextField()
            self.textField.keyboardType = .numberPad
            break
        case .double:
            self.setupTextField()
            self.textField.keyboardType = .decimalPad
            break
        case .integerStepper(let min, let max):
            if self.isViewModeEdit {
                self.setupStepper()
                self.rightSideStepper.stepValue = 1.0
                self.rightSideStepper.minimumValue = Double(min)
                self.rightSideStepper.maximumValue = Double(max)
                self.rightSideStepper.value = Double(self.intValue ?? 0)
                self.textField.keyboardType = .numberPad
            }else {
                self.setupTextField()
            }
            break
        }
    }
    
    func setupTextField() {
        self.hideRightSideViews()
        self.textField.isUserInteractionEnabled = self.isViewModeEdit
        self.actionBtn.isHidden = true
    }
    
    func setupDropDownMenu() {
        self.setupActionBtnForMenu()
        let rightSideViewWidth: CGFloat = 10+20+10
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = false
        self.rightSideStepper.isHidden = true
        self.actionBtn.isHidden = false
        self.textField.isUserInteractionEnabled = false
    }
    
    func setupPickerMenu() {
        self.setupActionBtnForMenu()
        let rightSideViewWidth: CGFloat = 10+20+10
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = false
        self.rightSideStepper.isHidden = true
        self.actionBtn.isHidden = !self.isViewModeEdit
        self.textField.isUserInteractionEnabled = false
    }
    
    func setupStepper() {
        self.setupActionBtnForMenu()
        let rightSideViewWidth: CGFloat = 10+94+4
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = true
        self.rightSideStepper.isHidden = false
        self.actionBtn.isHidden = true
        self.textField.isUserInteractionEnabled = true
    }
    
    func setupActionBtnForMenu() {
        guard self.isViewModeEdit else { return }
        self.actionBtn.showsMenuAsPrimaryAction = true
        self.actionBtn.removeTarget(self, action: #selector(self.actionBtnClicked(_:)), for: .menuActionTriggered)
        self.actionBtn.addTarget(self, action: #selector(self.actionBtnClicked(_:)), for: .menuActionTriggered)
    }
    
    func booleanMenu() -> UIMenu {
        let emptyAction = UIAction(title: "", state: boolValue == nil ? .on : .off) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.boolValue = nil
            strongSelf.setValueToField()
            strongSelf.fieldValueDidChange()
        }
        let yesAction = UIAction(title: "Yes", state: boolValue == true ? .on : .off) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.boolValue = true
            strongSelf.setValueToField()
            strongSelf.fieldValueDidChange()
        }
        let noAction = UIAction(title: "No", state: boolValue == false ? .on : .off) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.boolValue = false
            strongSelf.setValueToField()
            strongSelf.fieldValueDidChange()
        }
        return UIMenu(children: [emptyAction, yesAction, noAction])
    }
    
    func intergerPickerMenu(_ values: [Int]) -> UIMenu {
        var actions: [UIMenuElement] = []
        for value in values {
            let action = UIAction(title: "\(value)", state: self.intValue == value ? .on : .off) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.intValue = value
                strongSelf.setValueToField()
                strongSelf.fieldValueDidChange()
            }
            actions.append(action)
        }
        return UIMenu(title: "Select Year", children: actions)
    }
    
    func hideRightSideViews() {
        let rightSideViewWidth: CGFloat = 15
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = true
        self.rightSideStepper.isHidden = true
    }
    
    @IBAction func textFieldTextDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        switch self.inputType {
        case .intergerPicker, .boolean:
            break
        case .string:
            self.stringValue = text
        case .integer:
            self.intValue = Int(text)
        case .integerStepper:
            if let value = Int(text) {
                self.intValue = value
                self.rightSideStepper.value = Double(value)
            }
        case .double:
            self.doubleValue = Double(text)
        }
        self.fieldValueDidChange()
    }
    
    @objc func actionBtnClicked(_ sender: UIButton) {
        switch self.inputType {
        case .intergerPicker(let values):
            self.actionBtn.menu = self.intergerPickerMenu(values)
        case .boolean:
            self.actionBtn.menu = self.booleanMenu()
        case .string, .integer, .double, .integerStepper:
            break
        }
        self.actionBtn.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func stepperValueDidChange(_ sender: UIStepper) {
        if sender == self.rightSideStepper {
            let value = Int(self.rightSideStepper.value)
            self.intValue = value
            self.textField.text = "\(value)"
            self.fieldValueDidChange()
        }
    }
    
    func fieldValueDidChange() {
        guard self.isViewModeEdit else { return }
        self.delegate?.siteInformationDetailFieldValueDidChange(index: self.fieldIndex, stringValue: self.stringValue, intValue: self.intValue, doubleValue: self.doubleValue, boolValue: self.boolValue)
    }
    
}

protocol SiteInformationDetailDelegate: AnyObject {
    func siteInformationDetailFieldValueDidChange(index: Int, stringValue: String?, intValue: Int?, doubleValue: Double?, boolValue: Bool?)
}

protocol SiteInformationDelegate: AnyObject {
    func performSiteInformationSaveAction(modelType: SiteInformationEnum, model: SiteInformationModel?)
}
