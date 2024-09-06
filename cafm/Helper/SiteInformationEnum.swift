//
//  SiteInformationEnum.swift
//  cafm
//
//  Created by NS on 01/09/24.
//
//

import Foundation

enum SiteInformationEnum: String, CaseIterable {
    case siteInfo = "siteInfo"
    case siteArea = "siteArea"
    case siteSafety = "siteSafety"
    case siteUtility = "siteUtility"
    case siteLifts = "siteLifts"
    case siteScape = "siteScape"
    
    var title: String {
        switch self {
        case .siteInfo:
            return "Site Information"
        case .siteArea:
            return "Area & Occupancy"
        case .siteSafety:
            return "Safety & Security"
        case .siteUtility:
            return "Utility & Energy"
        case .siteLifts:
            return "Lifts & Stairways"
        case .siteScape:
            return "Landscape"
        }
    }
    
    var fields: [SiteInformationField] {
        switch self {
        case .siteInfo:
            SiteInformationField.siteInformationCases
        case .siteArea:
            SiteInformationField.areaAndOccupancyCases
        case .siteSafety:
            SiteInformationField.safetyAndSecurityCases
        case .siteUtility:
            SiteInformationField.utilityAndEnergyCases
        case .siteLifts:
            SiteInformationField.liftsAndStairwaysCases
        case .siteScape:
            SiteInformationField.landscapeCases
        }
    }
}

enum SiteInformationField: String {
    
    // Site Information
    case YearOfBuild = "Year Of Build"
    case BuildingUnderClientControl = "Building Under Client Control"
    case Canteeninbuilding = "Canteen in building"
    case DedicatedKitchenArea = "Dedicated Kitchen Area"
    
    // Area & Occupancy
    case TotalBuildingAreaSqm = "Total Building Area(Sq.m)"
    case ClientOccupiedAreaSqm = "Client Occupied Area(Sq.m)"
    case TenantOccupiedAreaSqm = "Tenant Occupied Area(Sq.m)"
    case MaximumOccupancyClient = "Maximum Occupancy(Client)"
    case MeetingConferencesClient = "Meeting/Conferences Client"
    case NumberOfStaff = "Number Of Staff"
    case TenantsinOccupation = "Tenants in Occupation"
    case NameOfTenant = "Name Of Tenant"
    case VacantAreasinbuilding = "Vacant Areas in building"
    case NumberOfFloors = "Number Of Floors"
    case CarkParkSpacesAboveGround = "Cark Park Spaces Above Ground"
    case CarkParkSpacesBelowGround = "Cark Park Spaces Below Ground"
    case NumberOfBasementLevels = "Number Of Basement Levels"
    
    // Safety & Security
    case ExternalFabric = "External Fabric"
    case ExternalMetallicFireEscapeStaircases = "External Metallic Fire Escape Staircases"
    case ExternalTimberFireEscapeStaircases = "External Timber Fire Escape Staircases"
    case VerticalLadder = "Vertical Ladder"
    case ConfinedSpaces = "Confined Spaces"
    case AccessibleUnguardedRoofAreas = "Accessible Unguarded Roof Areas"
    case FragileRoofsorSurfaces = "Fragile Roofs or Surfaces"
    case LightingConductorInstallation = "Lighting Conductor Installation"
    case FireAlarmDetectionSystem = "Fire Alarm/Detection System"
    case FirePanelLocation = "Fire Panel Location"
    case OilPetrolStorageonSite = "Oil/Petrol Storage on Site"
    case LPGStorageonSite = "LPG Storage on Site"
    case LPGBulkStorageonSite = "LPG Bulk Storage on Site"
    case LPGCylinderStorageonSite = "LPG Cylinder Storage on Site"
    case SprinklerSystem = "Sprinkler System"
    case HoseReels = "Hose Reels"
    case AreSecurityGuardsEmployed = "Are Security Guards Employed"
    case InternalCCTV = "Internal CCTV"
    case ExternalCCTV = "External CCTV"
    case AutomaticBarrier = "Automatic Barrier"
    case AutomaticGatesSliding = "Automatic Gates (Sliding)"
    case AutomaticGatesHinged = "Automatic Gates (Hinged)"
    case ManualSwingGates = "Manual Swing Gates"
    
    // Utility & Energy
    case UtilityGas = "Utility - Gas"
    case UtilityElectricity = "Utility - Electricity"
    case UtilityWater = "Utility - Water"
    case UtilityTelecomData = "Utility - Telecom/Data"
    case UtilityMainsDrainage = "Utility - Mains Drainage"
    case AirConditioning = "Air Conditioning"
    case CoolingTower = "Cooling Tower"
    case WaterIsolationValveLocationInternal = "Water Isolation Valve Location (Internal)"
    case WaterTanks = "Water Tanks"
    case WaterTankLocation = "Water Tank Location"
    case HotWaterCalorifier = "Hot Water Calorifier"
    case HotWaterCalorifierLocation = "Hot Water Calorifier Location"
    case PressureVessel = "Pressure Vessel"
    case GasBoiler = "Gas Boiler"
    case GasBoilerLocation = "Gas Boiler Location"
    case GasSupplyIsolationMeterLocation = "Gas Supply Isolation/Meter Location"
    case GasSupplyExternalIsolationLocation = "Gas Supply External Isolation Location"
    case ElectricnstallationMeterLocation = "Electric Installation / Meter Location"
    case ElectricSubStationonSite = "Electric Sub-Station on Site"
    case ExternalLighting = "External Lighting"
    case BackUpGenerator = "Back Up Generator"
    case BackUpGeneratorLocation = "Back Up Generator Location"
    
    // Lifts & Stairways
    case DisabledHoistLift = "Disabled Hoist/Lift"
    case LiftsGoodsTraction = "Lifts (Goods-Traction)"
    case LiftsGoodsHydraulic = "Lifts (Goods-Hydraulic)"
    case LiftsPassengerTraction = "Lifts (Passenger-Traction)"
    case LiftsPassengerHydraulic = "Lifts (Passenger-Hydraulic)"
    case LiftsPassengerMonospace = "Lifts (Passenger-Monospace)"
    case LiftsFireFighting = "Lifts (Fire Fighting)"
    case LiftsFireEvacuation = "Lifts (Fire Evacuation)"
    case NumberofStairwaysInternal = "Number of Stairways (Internal)"
    case NumberofStairwaysExternal = "Number of Stairways (External)"
    
    // Landscape
    case HardLandscaping = "Hard Landscaping"
    case SoftLandscaping = "Soft Landscaping"
    case RiversPondsLakes = "Rivers/Ponds/Lakes"
    case TallTrees = "Tall Trees"
    case DrainageInterceptors = "Drainage Interceptors"
    case ThirdPartyTelecommsEquipment = "Third Party Telecomms Equipment"
    case ElectricalOverheadPowerLines = "Electrical Overhead Power Lines"
    case DemolitionSiteorVacantLandAdjacent = "Demolition Site or Vacant Land Adjacent"
    case RiskofFlooding = "Risk of Flooding"
    case RailwayLineAdjacent = "Railway Line Adjacent"
    
    enum InputType {
        case intergerPicker(values: [Int])
        case string
        case boolean
        case integer
        case double
        case integerStepper(min: Int, max: Int)
    }
    
    var inputType: InputType {
        switch self {
        case .YearOfBuild:
            let gregorianCalendar = Calendar(identifier: .gregorian)
            let currentYear = gregorianCalendar.component(.year, from: Date())
            let years = Array(1900...currentYear)
            return .intergerPicker(values: years)
        case .BuildingUnderClientControl: return .boolean
        case .Canteeninbuilding: return .boolean
        case .DedicatedKitchenArea: return .boolean
            
        case .TotalBuildingAreaSqm: return .integer
        case .ClientOccupiedAreaSqm: return .integer
        case .TenantOccupiedAreaSqm: return .integer
        case .MaximumOccupancyClient: return .integer
        case .MeetingConferencesClient: return .boolean
        case .NumberOfStaff: return .integer
        case .TenantsinOccupation: return .integer
        case .NameOfTenant: return .string
        case .VacantAreasinbuilding: return .integer
        case .NumberOfFloors: return .integer
        case .CarkParkSpacesAboveGround: return .integer
        case .CarkParkSpacesBelowGround: return .integer
        case .NumberOfBasementLevels: return .integer
            
        case .ExternalFabric: return .string
        case .ExternalMetallicFireEscapeStaircases: return .integerStepper(min: Int.min, max: Int.max)
        case .ExternalTimberFireEscapeStaircases: return .integerStepper(min: Int.min, max: Int.max)
        case .VerticalLadder: return .integerStepper(min: Int.min, max: Int.max)
        case .ConfinedSpaces: return .boolean
        case .AccessibleUnguardedRoofAreas: return .boolean
        case .FragileRoofsorSurfaces: return .boolean
        case .LightingConductorInstallation: return .boolean
        case .FireAlarmDetectionSystem: return .boolean
        case .FirePanelLocation: return .string
        case .OilPetrolStorageonSite: return .boolean
        case .LPGStorageonSite: return .boolean
        case .LPGBulkStorageonSite: return .boolean
        case .LPGCylinderStorageonSite: return .boolean
        case .SprinklerSystem: return .boolean
        case .HoseReels: return .boolean
        case .AreSecurityGuardsEmployed: return .boolean
        case .InternalCCTV: return .boolean
        case .ExternalCCTV: return .boolean
        case .AutomaticBarrier: return .boolean
        case .AutomaticGatesSliding: return .boolean
        case .AutomaticGatesHinged: return .boolean
        case .ManualSwingGates: return .boolean
            
        case .UtilityGas: return .boolean
        case .UtilityElectricity: return .boolean
        case .UtilityWater: return .boolean
        case .UtilityTelecomData: return .boolean
        case .UtilityMainsDrainage: return .boolean
        case .AirConditioning: return .boolean
        case .CoolingTower: return .boolean
        case .WaterIsolationValveLocationInternal: return .string
        case .WaterTanks: return .boolean
        case .WaterTankLocation: return .string
        case .HotWaterCalorifier: return .integerStepper(min: Int.min, max: Int.max)
        case .HotWaterCalorifierLocation: return .string
        case .PressureVessel: return .integerStepper(min: Int.min, max: Int.max)
        case .GasBoiler: return .boolean
        case .GasBoilerLocation: return .string
        case .GasSupplyIsolationMeterLocation: return .string
        case .GasSupplyExternalIsolationLocation: return .string
        case .ElectricnstallationMeterLocation: return .string
        case .ElectricSubStationonSite: return .boolean
        case .ExternalLighting: return .boolean
        case .BackUpGenerator: return .boolean
        case .BackUpGeneratorLocation: return .string
            
        case .DisabledHoistLift: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsGoodsTraction: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsGoodsHydraulic: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsPassengerTraction: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsPassengerHydraulic: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsPassengerMonospace: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsFireFighting: return .integerStepper(min: Int.min, max: Int.max)
        case .LiftsFireEvacuation: return .integerStepper(min: Int.min, max: Int.max)
        case .NumberofStairwaysInternal: return .integerStepper(min: Int.min, max: Int.max)
        case .NumberofStairwaysExternal: return .integerStepper(min: Int.min, max: Int.max)
            
        case .HardLandscaping: return .boolean
        case .SoftLandscaping: return .boolean
        case .RiversPondsLakes: return .boolean
        case .TallTrees: return .boolean
        case .DrainageInterceptors: return .boolean
        case .ThirdPartyTelecommsEquipment: return .boolean
        case .ElectricalOverheadPowerLines: return .boolean
        case .DemolitionSiteorVacantLandAdjacent: return .string
        case .RiskofFlooding: return .string
        case .RailwayLineAdjacent: return .string
        }
    }
    
    static var siteInformationCases: [SiteInformationField] {
        [
            .YearOfBuild,
            .BuildingUnderClientControl,
            .Canteeninbuilding,
            .DedicatedKitchenArea,
        ]
    }
    
    static var areaAndOccupancyCases: [SiteInformationField] {
        [
            .TotalBuildingAreaSqm,
            .ClientOccupiedAreaSqm,
            .TenantOccupiedAreaSqm,
            .MaximumOccupancyClient,
            .MeetingConferencesClient,
            .NumberOfStaff,
            .TenantsinOccupation,
            .NameOfTenant,
            .VacantAreasinbuilding,
            .NumberOfFloors,
            .CarkParkSpacesAboveGround,
            .CarkParkSpacesBelowGround,
            .NumberOfBasementLevels,
        ]
    }
    
    static var safetyAndSecurityCases: [SiteInformationField] {
        [
            .ExternalFabric,
            .ExternalMetallicFireEscapeStaircases,
            .ExternalTimberFireEscapeStaircases,
            .VerticalLadder,
            .ConfinedSpaces,
            .AccessibleUnguardedRoofAreas,
            .FragileRoofsorSurfaces,
            .LightingConductorInstallation,
            .FireAlarmDetectionSystem,
            .FirePanelLocation,
            .OilPetrolStorageonSite,
            .LPGStorageonSite,
            .LPGBulkStorageonSite,
            .LPGCylinderStorageonSite,
            .SprinklerSystem,
            .HoseReels,
            .AreSecurityGuardsEmployed,
            .InternalCCTV,
            .ExternalCCTV,
            .AutomaticBarrier,
            .AutomaticGatesSliding,
            .AutomaticGatesHinged,
            .ManualSwingGates,
        ]
    }
    
    static var utilityAndEnergyCases: [SiteInformationField] {
        [
            .UtilityGas,
            .UtilityElectricity,
            .UtilityWater,
            .UtilityTelecomData,
            .UtilityMainsDrainage,
            .AirConditioning,
            .CoolingTower,
            .WaterIsolationValveLocationInternal,
            .WaterTanks,
            .WaterTankLocation,
            .HotWaterCalorifier,
            .HotWaterCalorifierLocation,
            .PressureVessel,
            .GasBoiler,
            .GasBoilerLocation,
            .GasSupplyIsolationMeterLocation,
            .GasSupplyExternalIsolationLocation,
            .ElectricnstallationMeterLocation,
            .ElectricSubStationonSite,
            .ExternalLighting,
            .BackUpGenerator,
            .BackUpGeneratorLocation,
        ]
    }
    
    static var liftsAndStairwaysCases: [SiteInformationField] {
        [
            .DisabledHoistLift,
            .LiftsGoodsTraction,
            .LiftsGoodsHydraulic,
            .LiftsPassengerTraction,
            .LiftsPassengerHydraulic,
            .LiftsPassengerMonospace,
            .LiftsFireFighting,
            .LiftsFireEvacuation,
            .NumberofStairwaysInternal,
            .NumberofStairwaysExternal,
        ]
    }
    
    static var landscapeCases: [SiteInformationField] {
        [
            .HardLandscaping,
            .SoftLandscaping,
            .RiversPondsLakes,
            .TallTrees,
            .DrainageInterceptors,
            .ThirdPartyTelecommsEquipment,
            .ElectricalOverheadPowerLines,
            .DemolitionSiteorVacantLandAdjacent,
            .RiskofFlooding,
            .RailwayLineAdjacent,
        ]
    }
}
