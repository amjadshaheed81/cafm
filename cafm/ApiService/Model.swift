//
//  Model.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import ObjectMapper

class TaggedSite: Mappable {
    var id: Int?
    var name: String?
    var siteImageUrl: String?
    
    required init?(map: Map) {}
    
    init() {
        
    }
    
    func mapping(map: Map) {
        id   <- map["id"]
        name <- map["name"]
        siteImageUrl <- map["siteImageUrl"]
    }
}

class ProjectContractsResponse: Mappable {
    var projectContracts: [ProjectContract]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        projectContracts <- map["projectContracts"]
    }
}

class ProjectContract: Mappable {
    var projectContractId: Int?
    var summary: String?
    var category: String?
    var subCategory: String?
    var contractorCompanyName: String?
    var siteName: String?
    var startDate: String?
    var endDate: String?
    var cost: String?
    var status: String?
    var siteId: Int?
    var contractorCompanyId: Int?
    var budget: String?
    var projectManagerUserId: Int?
    var description: String?
    var siteEntity: String?
    var companyEntity: CompanyEntity?
    var userEntity: User?
    var siteProjectContractsFoldersEntity: [SiteProjectContractsFoldersEntity]?
    var siteProjectContractsAssetEntity: [SiteProjectContractsFoldersEntity]?
    var siteScheduleVisitEntity: [SiteScheduleVisitEntity]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        projectContractId <- map["projectContractId"]
        summary <- map["summary"]
        category <- map["category"]
        subCategory <- map["subCategory"]
        contractorCompanyName <- map["contractorCompanyName"]
        siteName <- map["siteName"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        cost <- map["cost"]
        status <- map["status"]
        siteId <- map["siteId"]
        contractorCompanyId <- map["contractorCompanyId"]
        budget <- map["budget"]
        projectManagerUserId <- map["projectManagerUserId"]
        description <- map["description"]
        siteEntity <- map["siteEntity"]
        companyEntity <- map["companyEntity"]
        userEntity <- map["userEntity"]
        siteProjectContractsFoldersEntity <- map["siteProjectContractsFoldersEntity"]
        siteProjectContractsAssetEntity <- map["siteProjectContractsAssetEntity"]
        siteScheduleVisitEntity <- map["siteScheduleVisitEntity"]
    }
}

class PreActionsResponse: Mappable {
    var preActions: [PreAction]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        preActions <- map["preActions"]
    }
}

class PreAction: Mappable {
    enum Status: String {
        case pendingAction = "Pending Action"
        case closed = "Closed"
        
        func textColor() -> UIColor {
            switch self {
            case .pendingAction:
                return UIColor(appColor: .GreenStatus)
            case .closed:
                return UIColor(appColor: .AmberStatus)
            }
        }
        
        func textBGColor() -> UIColor {
            switch self {
            case .pendingAction:
                return UIColor(appColor: .GreenStatusBG)
            case .closed:
                return UIColor(appColor: .AmberStatusBG)
            }
        }
    }
    
    var raisedDate: String?
    var taggedAsset: String?
    var actionId: Int?
    var category: String?
    var floor: String?
    var room: String?
    var image: String?
    var description: String?
    var raisedByUserId: Int?
    var raisedByUserName: String?
    var status: String?
    
    var siteId: Int?
    var closedDate: String?
    var actionTaken: String?
    var approverNotes: String?
    var evidence: String?
    var siteEntity: String?
    var raisedUserEntity: User?
    var preActionAssetsEntity: [String]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        raisedDate <- map["raisedDate"]
        taggedAsset <- map["taggedAsset"]
        actionId <- map["actionId"]
        category <- map["category"]
        floor <- map["floor"]
        room <- map["room"]
        image <- map["image"]
        description <- map["description"]
        raisedByUserId <- map["raisedByUserId"]
        raisedByUserName <- map["raisedByUserName"]
        status <- map["status"]
        
        siteId <- map["siteId"]
        closedDate <- map["closedDate"]
        actionTaken <- map["actionTaken"]
        approverNotes <- map["approverNotes"]
        evidence <- map["evidence"]
        siteEntity <- map["siteEntity"]
        raisedUserEntity <- map["raisedUserEntity"]
        preActionAssetsEntity <- map["preActionAssetsEntity"]
    }
}

class CalendarEvent: Mappable {
    var calendarId: Int?
    var siteId: Int?
    var siteName: String?
    var startDate: String?
    var endDate: String?
    var shortText: String?
    var section: String?
    var sectionId: Int?
    var eventType: String?
    var userId: String?
    var userName: String?
    var includeCompanyUsers: Bool?
    
    var start_date: Date?
    var end_date: Date?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        calendarId <- map["calendarId"]
        siteId <- map["siteId"]
        siteName <- map["siteName"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        shortText <- map["shortText"]
        section <- map["section"]
        sectionId <- map["sectionId"]
        eventType <- map["eventType"]
        userId <- map["userId"]
        userName <- map["userName"]
        includeCompanyUsers <- map["includeCompanyUsers"]
        
        //start_date <- (map["start_date"], DateTransform())
        //end_date <- (map["end_date"], DateTransform())
    }
}

class RiskScoreResponse: Mappable {
    var riskScores: [String: RiskScore]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        var tempRiskScores: [String: RiskScore] = [:]
        
        for (key, value) in map.JSON {
            if let riskScoreMap = value as? [String: Any],
               let riskScore = RiskScore(JSON: riskScoreMap) {
                tempRiskScores[key] = riskScore
            }
        }
        
        riskScores = tempRiskScores
    }
}

class RiskScore: Mappable {
    var riskScoreRed: Int?
    var riskScoreAmber: Int?
    var riskScoreYellow: Int?
    var riskScoreGreen: Int?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        riskScoreRed     <- map["riskScoreRed"]
        riskScoreAmber   <- map["riskScoreAmber"]
        riskScoreYellow  <- map["riskScoreYellow"]
        riskScoreGreen   <- map["riskScoreGreen"]
    }
}

class ActionModel: Mappable {
    
    enum Status: String, CaseIterable {
        case `default` = "Status"
        case reported = "Reported"
        case reassessed = "Reassessed"
        case completed = "Completed"
        
        func textColor() -> UIColor {
            switch self {
            case .reported, .reassessed:
                return UIColor(appColor: .AmberStatus)
            case .completed, .default:
                return UIColor(appColor: .GreenStatus)
            }
        }
        
        func textBGColor() -> UIColor {
            switch self {
            case .reported, .reassessed:
                return UIColor(appColor: .AmberStatusBG)
            case .completed, .default:
                return UIColor(appColor: .GreenStatusBG)
            }
        }
    }
    
    var actionId: Int?
    var type: String?
    var status: Status?
    var observation: String?
    var desc: String?
    var requiredAction: String?
    var riskScore: Int?
    var dueDate: String?
    var siteId: Int?
    var userId: Int?
    var competentPersons: Int?
    var serviceProvider: Int?
    var stakeholder: Int?
    var assignedTo: Int?
    var comments: String?
    var internalExternal: String?
    var floor: String?
    var actionImage: String?
    var room: String?
    var taggedAsset: String?
    var createdAt: String?
    var completedAt: String?
    var completedBy: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        actionId <- map["actionId"]
        type <- map["type"]
        status <- map["status"]
        observation <- map["observation"]
        desc <- map["desc"]
        requiredAction <- map["requiredAction"]
        riskScore <- map["riskScore"]
        dueDate <- map["dueDate"]
        siteId <- map["siteId"]
        userId <- map["userId"]
        competentPersons <- map["competentPersons"]
        serviceProvider <- map["serviceProvider"]
        stakeholder <- map["stakeholder"]
        assignedTo <- map["assignedTo"]
        comments <- map["comments"]
        internalExternal <- map["internalExternal"]
        floor <- map["floor"]
        actionImage <- map["actionImage"]
        room <- map["room"]
        taggedAsset <- map["taggedAsset"]
        createdAt <- map["createdAt"]
        completedAt <- map["completedAt"]
        completedBy <- map["completedBy"]
    }
}

class CreateSiteRequestModel: Mappable {
    var buildingCode: String?
    var siteId: Int?
    var siteName: String?
    var address1: String?
    var address2: String?
    var area: String?
    var city: String?
    var postCode: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var status: String?
    var mapViewUrl: String?
    var streetViewUrl: String?
    var monStartTime: String?
    var tuesStartTime: String?
    var wedStartTime: String?
    var thurStartTime: String?
    var friStartTime: String?
    var satStartTime: String?
    var sunStartTime: String?
    var monEndTime: String?
    var tuesEndTime: String?
    var wedEndTime: String?
    var thurEndTime: String?
    var friEndTime: String?
    var satEndTime: String?
    var sunEndTime: String?
    var localAuthority: String?
    var siteImageUrl: String?
    var clientResponsibility: String?
    var siteImage: String?
    var clientResponsiblity: Bool?
    var siteDocumentsEntity: [SiteDocumentsEntity]?
    var userEntity: User?
    var documentsEntity: [CreateFolderReq]?
    var userSitesEntity: [UserSitesEntity]?
    var siteChecks: [String]?
    var siteProjectContractsEntity: [ProjectContract]?
    var siteEnergySurvey: [SiteEnergySurvey]?
    var assetEntity: [AssetDetailsResponse]?
    var riskScores: [Int] = [0,0,0,0]
    
    var riskScoreModel: RiskScore?
    
    var siteAreaOccupancyData : SiteAreaOccupancyData?
    var siteInfoData : SiteInfoData?
    var siteLandScapeData : SiteLandScapeData?
    var siteLiftsData : SiteLiftsData?
    var siteSafetyData : SiteSafetyData?
    var siteEnergyData : SiteEnergyData?
    
    required init?(map: Map) {
        // Initialize if needed
    }
    
    init() { }
    
    func mapping(map: Map) {
        buildingCode        <- map["buildingCode"]
        siteId              <- map["siteId"]
        siteName            <- map["siteName"]
        address1            <- map["address1"]
        address2            <- map["address2"]
        area                <- map["area"]
        city                <- map["city"]
        postCode            <- map["postCode"]
        country             <- map["country"]
        status              <- map["status"]
        mapViewUrl          <- map["mapViewUrl"]
        streetViewUrl       <- map["streetViewUrl"]
        monStartTime        <- map["monStartTime"]
        tuesStartTime       <- map["tuesStartTime"]
        wedStartTime        <- map["wedStartTime"]
        thurStartTime       <- map["thurStartTime"]
        friStartTime        <- map["friStartTime"]
        satStartTime        <- map["satStartTime"]
        sunStartTime        <- map["sunStartTime"]
        monEndTime          <- map["monEndTime"]
        tuesEndTime         <- map["tuesEndTime"]
        wedEndTime          <- map["wedEndTime"]
        thurEndTime         <- map["thurEndTime"]
        friEndTime          <- map["friEndTime"]
        satEndTime          <- map["satEndTime"]
        sunEndTime          <- map["sunEndTime"]
        localAuthority      <- map["localAuthority"]
        siteImageUrl        <- map["siteImageUrl"]
        clientResponsibility <- map["clientResponsibility"]
        siteImage           <- map["siteImage"]
        latitude           <- map["latitude"]
        longitude           <- map["longitude"]
        clientResponsiblity <- map["clientResponsiblity"]
        siteDocumentsEntity <- map["siteDocumentsEntity"]
        userEntity <- map["userEntity"]
        documentsEntity <- map["documentsEntity"]
        userSitesEntity <- map["userSitesEntity"]
        siteChecks <- map["siteChecks"]
        siteProjectContractsEntity <- map["siteProjectContractsEntity"]
        siteEnergySurvey <- map["siteEnergySurvey"]
        assetEntity <- map["assetEntity"]
        riskScores <- map["riskScores"]
        siteAreaOccupancyData <- map["siteAreaOccupancyData"]
        siteInfoData <- map["siteInfoData"]
        siteLandScapeData <- map["siteLandScapeData"]
        siteLiftsData <- map["siteLiftsData"]
        siteSafetyData <- map["siteSafetyData"]
        siteEnergyData <- map["siteEnergyData"]
    }
}

class SiteAreaOccupancyData : Mappable {
    var siteId : Int?
    var totalBuildingArea : Double?
    var clientOccupiedArea : Double?
    var tenantOccupiedArea : Double?
    var maxOccupancy : String?
    var numberOfStaff : Int?
    var tenantInOccupation : Bool?
    var tenantName : String?
    var vacantAreaInBuilding : Bool?
    var numOfFloors : Int?
    var carParkSpaceAboveGround : Int?
    var carParkSpaceBelowGround : Int?
    var numOfBasementLevels : Int?
    var meetingClients : String?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        siteId <- map["siteId"]
        totalBuildingArea <- map["totalBuildingArea"]
        clientOccupiedArea <- map["clientOccupiedArea"]
        tenantOccupiedArea <- map["tenantOccupiedArea"]
        maxOccupancy <- map["maxOccupancy"]
        numberOfStaff <- map["numberOfStaff"]
        tenantInOccupation <- map["tenantInOccupation"]
        tenantName <- map["tenantName"]
        vacantAreaInBuilding <- map["vacantAreaInBuilding"]
        numOfFloors <- map["numOfFloors"]
        carParkSpaceAboveGround <- map["carParkSpaceAboveGround"]
        carParkSpaceBelowGround <- map["carParkSpaceBelowGround"]
        numOfBasementLevels <- map["numOfBasementLevels"]
        meetingClients <- map["meetingClients"]
    }
    
}

class SiteEnergyData : Mappable {
    var siteId : Int?
    var utilGas : Bool?
    var utilElectricity : Bool?
    var utilWater : Bool?
    var utilTelecom : Bool?
    var utilMainsDrainage : Bool?
    var airConditioning : Bool?
    var coolingTower : Bool?
    var waterIsolationValveInternal : String?
    var waterTankLocation : String?
    var waterTanks : Bool?
    var hotWaterCalorifier : Int?
    var hotWaterCalorifierLocation : String?
    var pressureVessel : Int?
    var gasBoiler : Bool?
    var gasBoilerLocation : String?
    var gasSupplyIsolation : String?
    var gasSupplyExternalIsolation : String?
    var electricInstallationLocation : String?
    var electricSubStationOnSite : Bool?
    var externalLighting : Bool?
    var backupGenerator : Bool?
    var backupGeneratorLocation : String?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        
        siteId <- map["siteId"]
        utilGas <- map["utilGas"]
        utilElectricity <- map["utilElectricity"]
        utilWater <- map["utilWater"]
        utilTelecom <- map["utilTelecom"]
        utilMainsDrainage <- map["utilMainsDrainage"]
        airConditioning <- map["airConditioning"]
        coolingTower <- map["coolingTower"]
        waterIsolationValveInternal <- map["waterIsolationValveInternal"]
        waterTankLocation <- map["waterTankLocation"]
        waterTanks <- map["waterTanks"]
        hotWaterCalorifier <- map["hotWaterCalorifier"]
        hotWaterCalorifierLocation <- map["hotWaterCalorifierLocation"]
        pressureVessel <- map["pressureVessel"]
        gasBoiler <- map["gasBoiler"]
        gasBoilerLocation <- map["gasBoilerLocation"]
        gasSupplyIsolation <- map["gasSupplyIsolation"]
        gasSupplyExternalIsolation <- map["gasSupplyExternalIsolation"]
        electricInstallationLocation <- map["electricInstallationLocation"]
        electricSubStationOnSite <- map["electricSubStationOnSite"]
        externalLighting <- map["externalLighting"]
        backupGenerator <- map["backupGenerator"]
        backupGeneratorLocation <- map["backupGeneratorLocation"]
    }
    
}

class SiteInfoData : Mappable {
    var siteId : Int?
    var buildYear : String?
    var buildingUnderClientControl : Bool?
    var canteenInBuilding : Bool?
    var dedicatedKitchenArea : Bool?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        
        siteId <- map["siteId"]
        buildYear <- map["buildYear"]
        buildingUnderClientControl <- map["buildingUnderClientControl"]
        canteenInBuilding <- map["canteenInBuilding"]
        dedicatedKitchenArea <- map["dedicatedKitchenArea"]
    }
    
}

class SiteLandScapeData : Mappable {
    var siteId : Int?
    var hardLandScaping : Bool?
    var softLandScaping : Bool?
    var riverPondLakes : Bool?
    var tallTrees : Bool?
    var drainageInterceptors : Bool?
    var thirdPartyTelEquipment : Bool?
    var electricalOverHeadPowerLines : Bool?
    var vacantLandAdjacent : String?
    var floodRisk : String?
    var railwayLineAdjacent : String?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        
        siteId <- map["siteId"]
        hardLandScaping <- map["hardLandScaping"]
        softLandScaping <- map["softLandScaping"]
        riverPondLakes <- map["riverPondLakes"]
        tallTrees <- map["tallTrees"]
        drainageInterceptors <- map["drainageInterceptors"]
        thirdPartyTelEquipment <- map["thirdPartyTelEquipment"]
        electricalOverHeadPowerLines <- map["electricalOverHeadPowerLines"]
        vacantLandAdjacent <- map["vacantLandAdjacent"]
        floodRisk <- map["floodRisk"]
        railwayLineAdjacent <- map["railwayLineAdjacent"]
    }
    
}

class SiteLiftsData : Mappable {
    var siteId : Int?
    var disabledHoistLift : Int?
    var goodsTractionLift : Int?
    var goodsHydraulicLift : Int?
    var passengerTractionLift : Int?
    var passengerHydraulicLift : Int?
    var passengerMonospaceLift : Int?
    var fireFightingLift : Int?
    var fireEvacuationLift : Int?
    var internalStairways : Int?
    var externalStairways : Int?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        
        siteId <- map["siteId"]
        disabledHoistLift <- map["disabledHoistLift"]
        goodsTractionLift <- map["goodsTractionLift"]
        goodsHydraulicLift <- map["goodsHydraulicLift"]
        passengerTractionLift <- map["passengerTractionLift"]
        passengerHydraulicLift <- map["passengerHydraulicLift"]
        passengerMonospaceLift <- map["passengerMonospaceLift"]
        fireFightingLift <- map["fireFightingLift"]
        fireEvacuationLift <- map["fireEvacuationLift"]
        internalStairways <- map["internalStairways"]
        externalStairways <- map["externalStairways"]
    }
    
}

class SiteSafetyData : Mappable {
    var siteId : Int?
    var extFabric : String?
    var extMetallicFireEscapeStaircases : Int?
    var extTimberFireEscapeStaircases : Int?
    var verticalLadder : Int?
    var confinedSpaces : Bool?
    var accessibleUnguardedRoofAreas : Bool?
    var fragileRoof : Bool?
    var lightingConductoreInstalltion : Bool?
    var fireAlarmSystem : Bool?
    var firePanelLocation : String?
    var oilStorageOnSite : Bool?
    var lpgCylinderStorageOnSite : Bool?
    var lpgStorageOnSite : Bool?
    var lpgBulkStorageOnSite : Bool?
    var sprinklerSystem : Bool?
    var hoseReels : Bool?
    var securityGuardEmployed : Bool?
    var internalCCTV : Bool?
    var externalCCTV : Bool?
    var automaticBarrier : Bool?
    var automaticGatesSliding : Bool?
    var automaticGatesHinged : Bool?
    var manualSwingGates : Bool?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        
        siteId <- map["siteId"]
        extFabric <- map["extFabric"]
        extMetallicFireEscapeStaircases <- map["extMetallicFireEscapeStaircases"]
        extTimberFireEscapeStaircases <- map["extTimberFireEscapeStaircases"]
        verticalLadder <- map["verticalLadder"]
        confinedSpaces <- map["confinedSpaces"]
        accessibleUnguardedRoofAreas <- map["accessibleUnguardedRoofAreas"]
        fragileRoof <- map["fragileRoof"]
        lightingConductoreInstalltion <- map["lightingConductoreInstalltion"]
        fireAlarmSystem <- map["fireAlarmSystem"]
        firePanelLocation <- map["firePanelLocation"]
        oilStorageOnSite <- map["oilStorageOnSite"]
        lpgCylinderStorageOnSite <- map["lpgCylinderStorageOnSite"]
        lpgStorageOnSite <- map["lpgStorageOnSite"]
        lpgBulkStorageOnSite <- map["lpgBulkStorageOnSite"]
        sprinklerSystem <- map["sprinklerSystem"]
        hoseReels <- map["hoseReels"]
        securityGuardEmployed <- map["securityGuardEmployed"]
        internalCCTV <- map["internalCCTV"]
        externalCCTV <- map["externalCCTV"]
        automaticBarrier <- map["automaticBarrier"]
        automaticGatesSliding <- map["automaticGatesSliding"]
        automaticGatesHinged <- map["automaticGatesHinged"]
        manualSwingGates <- map["manualSwingGates"]
    }
    
}

class Suggestion: Mappable {
    var address: String?
    var url: String?
    var id: String?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        address <- map["address"]
        url     <- map["url"]
        id      <- map["id"]
    }
}

// Model for the suggestions array
class SuggestionsResponse: Mappable {
    var suggestions: [Suggestion]?
    
    required init?(map: Map) {
        // Initialization if needed
    }
    
    func mapping(map: Map) {
        suggestions <- map["suggestions"]
    }
}

class AddressResponse: Mappable {
    var postcode: String?
    var latitude: Double?
    var longitude: Double?
    var formattedAddress: [String]?
    var thoroughfare: String?
    var buildingName: String?
    var subBuildingName: String?
    var subBuildingNumber: String?
    var buildingNumber: String?
    var line1: String?
    var line2: String?
    var line3: String?
    var line4: String?
    var locality: String?
    var townOrCity: String?
    var county: String?
    var district: String?
    var country: String?
    var residential: Bool?
    
    // Required initializer
    required init?(map: Map) { }
    
    init() { }
    
    // Mapping function
    func mapping(map: Map) {
        postcode            <- map["postcode"]
        latitude            <- map["latitude"]
        longitude           <- map["longitude"]
        formattedAddress    <- map["formatted_address"]
        thoroughfare        <- map["thoroughfare"]
        buildingName        <- map["building_name"]
        subBuildingName     <- map["sub_building_name"]
        subBuildingNumber   <- map["sub_building_number"]
        buildingNumber      <- map["building_number"]
        line1               <- map["line_1"]
        line2               <- map["line_2"]
        line3               <- map["line_3"]
        line4               <- map["line_4"]
        locality            <- map["locality"]
        townOrCity          <- map["town_or_city"]
        county              <- map["county"]
        district            <- map["district"]
        country             <- map["country"]
        residential         <- map["residential"]
    }
}

class keyContacts: Mappable {
    var updateKeyContactRequestModel: [GetKeyContactsDetailResponse]?
    
    // Default initializer
    init() {}
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        updateKeyContactRequestModel             <- map["updateKeyContactRequestModel"]
    }
    
}

class GetKeyContactsDetailResponse: Mappable {
    var id: Int?
    var siteId: Int?
    var contactName: String?
    var phone: String?
    var email: String?
    var actionManager: String?
    
    // Default initializer
    init() {}
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to properties
    func mapping(map: Map) {
        id             <- map["id"]
        siteId         <- map["siteId"]
        contactName    <- map["contactName"]
        phone          <- map["phone"]
        email          <- map["email"]
        actionManager  <- map["actionManager"]
    }
}

class UpdateCreateSiteLocalDetailsRequestModel: Mappable {
    var siteId: Int?
    var localAuthority: String?
    var status: String?
    var clientResponsibility: Bool?
    
    // Default initializer
    init() {}
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to properties
    func mapping(map: Map) {
        siteId              <- map["siteId"]
        localAuthority      <- map["localAuthority"]
        status              <- map["status"]
        clientResponsibility <- map["clientResponsibility"]
    }
}

class SiteScheduleRequestModel: Mappable {
    var siteId: Int?
    var monStartTime: String? = nil
    var tuesStartTime: String? = nil
    var wedStartTime: String? = nil
    var thurStartTime: String? = nil
    var friStartTime: String? = nil
    var satStartTime: String? = nil
    var sunStartTime: String? = nil
    var monEndTime: String? = nil
    var tuesEndTime: String? = nil
    var wedEndTime: String? = nil
    var thurEndTime: String? = nil
    var friEndTime: String? = nil
    var satEndTime: String? = nil
    var sunEndTime: String? = nil
    
    // Default initializer
    init() {}
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to properties
    func mapping(map: Map) {
        siteId         <- map["siteId"]
        monStartTime   <- map["monStartTime"]
        tuesStartTime  <- map["tuesStartTime"]
        wedStartTime   <- map["wedStartTime"]
        thurStartTime  <- map["thurStartTime"]
        friStartTime   <- map["friStartTime"]
        satStartTime   <- map["satStartTime"]
        sunStartTime   <- map["sunStartTime"]
        monEndTime     <- map["monEndTime"]
        tuesEndTime    <- map["tuesEndTime"]
        wedEndTime     <- map["wedEndTime"]
        thurEndTime    <- map["thurEndTime"]
        friEndTime     <- map["friEndTime"]
        satEndTime     <- map["satEndTime"]
        sunEndTime     <- map["sunEndTime"]
    }
}

class SiteImageResponse: Mappable {
    var url: String?
    var siteId: Int?
    
    // Initializer for ObjectMapper
    required init?(map: Map) {
    }
    
    // Mapping function to map JSON keys to properties
    func mapping(map: Map) {
        url <- map["url"]
        siteId <- map["siteId"]
    }
}

class SiteLayoutModel: Mappable {
    
    enum NodeType: String {
        case `default` = "default"
        case MasterNode = "MasterNode"
        case position = "position"
        case floor = "floor"
        case room = "room"
        
        case building = "building"
        case type = "type"
        
        var title: String {
            switch self {
            case .default:
                return "Select Node Type"
            case .MasterNode, .building:
                return "Main Building"
            case .position, .floor, .room, .type:
                return self.rawValue.capitalized
            }
        }
    }
    
    var id: Int?
    var siteId: Int?
    var nodeName: String?
    var nodeType: NodeType?
    var parentNode: Int?
    var floorPlanUrl: String?
    var fileName: String?
    
    var nodeId: Int?
    var response: String?
    
    var selectedFloorPlanFileName: String?
    var selectedFloorPlanImage: UIImage?
    var selectedFloorPlanFileURL: URL?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        siteId <- map["siteId"]
        nodeName <- map["nodeName"]
        nodeType <- map["nodeType"]
        parentNode <- map["parentNode"]
        floorPlanUrl <- map["floorPlanUrl"]
        fileName <- map["fileName"]
        nodeId <- map["nodeId"]
        response <- map["response"]
    }
}

class MarkerModel: Mappable {
    var id: Int?
    var label: String?
    var roomId: Int?
    var siteId: Int?
    var leftPosition: String?
    var topPosition: String?
    var leftPositionDouble: CGFloat?
    var topPositionDouble: CGFloat?
    
    var xPos: CGFloat? {
        if let leftPosition, let value = Double(leftPosition) {
            return value
        }else {
            return leftPositionDouble
        }
    }
    
    var yPos: CGFloat? {
        if let topPosition, let value = Double(topPosition) {
            return value
        }else {
            return topPositionDouble
        }
    }
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        label <- map["label"]
        roomId <- map["roomId"]
        siteId <- map["siteId"]
        leftPosition <- map["leftPosition"]
        topPosition <- map["topPosition"]
        leftPositionDouble <- map["leftPosition"]
        topPositionDouble <- map["topPosition"]
    }
}

class SiteInformationModel: Mappable {
    var siteId: Int?
    var utilGas: Bool?
    var utilElectricity: Bool?
    var utilWater: Bool?
    var utilTelecom: Bool?
    var utilMainsDrainage: Bool?
    var airConditioning: Bool?
    var coolingTower: Bool?
    var waterIsolationValveInternal: String?
    var waterTankLocation: String?
    var waterTanks: Bool?
    var hotWaterCalorifier: Int?
    var hotWaterCalorifierLocation: String?
    var pressureVessel: Int?
    var gasBoiler: Bool?
    var gasBoilerLocation: String?
    var gasSupplyIsolation: String?
    var gasSupplyExternalIsolation: String?
    var electricInstallationLocation: String?
    var electricSubStationOnSite: Bool?
    var externalLighting: Bool?
    var backupGenerator: Bool?
    var backupGeneratorLocation: String?
    var disabledHoistLift: Int?
    var goodsTractionLift: Int?
    var goodsHydraulicLift: Int?
    var passengerTractionLift: Int?
    var passengerHydraulicLift: Int?
    var passengerMonospaceLift: Int?
    var fireFightingLift: Int?
    var fireEvacuationLift: Int?
    var internalStairways: Int?
    var externalStairways: Int?
    var extFabric: String?
    var extMetallicFireEscapeStaircases: Int?
    var extTimberFireEscapeStaircases: Int?
    var verticalLadder: Int?
    var confinedSpaces: Bool?
    var accessibleUnguardedRoofAreas: Bool?
    var fragileRoof: Bool?
    var lightingConductoreInstalltion: Bool?
    var fireAlarmSystem: Bool?
    var firePanelLocation: String?
    var oilStorageOnSite: Bool?
    var lpgStorageOnSite: Bool?
    var lpgBulkStorageOnSite: Bool?
    var sprinklerSystem: Bool?
    var hoseReels: Bool?
    var securityGuardEmployed: Bool?
    var internalCCTV: Bool?
    var externalCCTV: Bool?
    var automaticBarrier: Bool?
    var automaticGatesSliding: Bool?
    var automaticGatesHinged: Bool?
    var manualSwingGates: Bool?
    var hardLandScaping: Bool?
    var softLandScaping: Bool?
    var riverPondLakes: Bool?
    var tallTrees: Bool?
    var drainageInterceptors: Bool?
    var thirdPartyTelEquipment: Bool?
    var electricalOverHeadPowerLines: Bool?
    var vacantLandAdjacent: String?
    var floodRisk: String?
    var railwayLineAdjacent: String?
    var buildYear: Int?
    var buildingUnderClientControl: Bool?
    var canteenInBuilding: Bool?
    var dedicatedKitchenArea: Bool?
    var totalBuildingArea: Int?
    var clientOccupiedArea: Int?
    var tenantOccupiedArea: Int?
    var maxOccupancy: Int?
    var numberOfStaff: Int?
    var tenantInOccupation: Int?
    var tenantName: String?
    var vacantAreaInBuilding: Int?
    var numOfFloors: Int?
    var carParkSpaceAboveGround: Int?
    var carParkSpaceBelowGround: Int?
    var numOfBasementLevels: Int?
    var meetingClients: Bool?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        siteId <- map["siteId"]
        utilGas <- map["utilGas"]
        utilElectricity <- map["utilElectricity"]
        utilWater <- map["utilWater"]
        utilTelecom <- map["utilTelecom"]
        utilMainsDrainage <- map["utilMainsDrainage"]
        airConditioning <- map["airConditioning"]
        coolingTower <- map["coolingTower"]
        waterIsolationValveInternal <- map["waterIsolationValveInternal"]
        waterTankLocation <- map["waterTankLocation"]
        waterTanks <- map["waterTanks"]
        hotWaterCalorifier <- map["hotWaterCalorifier"]
        hotWaterCalorifierLocation <- map["hotWaterCalorifierLocation"]
        pressureVessel <- map["pressureVessel"]
        gasBoiler <- map["gasBoiler"]
        gasBoilerLocation <- map["gasBoilerLocation"]
        gasSupplyIsolation <- map["gasSupplyIsolation"]
        gasSupplyExternalIsolation <- map["gasSupplyExternalIsolation"]
        electricInstallationLocation <- map["electricInstallationLocation"]
        electricSubStationOnSite <- map["electricSubStationOnSite"]
        externalLighting <- map["externalLighting"]
        backupGenerator <- map["backupGenerator"]
        backupGeneratorLocation <- map["backupGeneratorLocation"]
        disabledHoistLift <- map["disabledHoistLift"]
        goodsTractionLift <- map["goodsTractionLift"]
        goodsHydraulicLift <- map["goodsHydraulicLift"]
        passengerTractionLift <- map["passengerTractionLift"]
        passengerHydraulicLift <- map["passengerHydraulicLift"]
        passengerMonospaceLift <- map["passengerMonospaceLift"]
        fireFightingLift <- map["fireFightingLift"]
        fireEvacuationLift <- map["fireEvacuationLift"]
        internalStairways <- map["internalStairways"]
        externalStairways <- map["externalStairways"]
        extFabric <- map["extFabric"]
        extMetallicFireEscapeStaircases <- map["extMetallicFireEscapeStaircases"]
        extTimberFireEscapeStaircases <- map["extTimberFireEscapeStaircases"]
        verticalLadder <- map["verticalLadder"]
        confinedSpaces <- map["confinedSpaces"]
        accessibleUnguardedRoofAreas <- map["accessibleUnguardedRoofAreas"]
        fragileRoof <- map["fragileRoof"]
        lightingConductoreInstalltion <- map["lightingConductoreInstalltion"]
        fireAlarmSystem <- map["fireAlarmSystem"]
        firePanelLocation <- map["firePanelLocation"]
        oilStorageOnSite <- map["oilStorageOnSite"]
        lpgStorageOnSite <- map["lpgStorageOnSite"]
        lpgBulkStorageOnSite <- map["lpgBulkStorageOnSite"]
        sprinklerSystem <- map["sprinklerSystem"]
        hoseReels <- map["hoseReels"]
        securityGuardEmployed <- map["securityGuardEmployed"]
        internalCCTV <- map["internalCCTV"]
        externalCCTV <- map["externalCCTV"]
        automaticBarrier <- map["automaticBarrier"]
        automaticGatesSliding <- map["automaticGatesSliding"]
        automaticGatesHinged <- map["automaticGatesHinged"]
        manualSwingGates <- map["manualSwingGates"]
        hardLandScaping <- map["hardLandScaping"]
        softLandScaping <- map["softLandScaping"]
        riverPondLakes <- map["riverPondLakes"]
        tallTrees <- map["tallTrees"]
        drainageInterceptors <- map["drainageInterceptors"]
        thirdPartyTelEquipment <- map["thirdPartyTelEquipment"]
        electricalOverHeadPowerLines <- map["electricalOverHeadPowerLines"]
        vacantLandAdjacent <- map["vacantLandAdjacent"]
        floodRisk <- map["floodRisk"]
        railwayLineAdjacent <- map["railwayLineAdjacent"]
        buildYear <- map["buildYear"]
        buildingUnderClientControl <- map["buildingUnderClientControl"]
        canteenInBuilding <- map["canteenInBuilding"]
        dedicatedKitchenArea <- map["dedicatedKitchenArea"]
        totalBuildingArea <- map["totalBuildingArea"]
        clientOccupiedArea <- map["clientOccupiedArea"]
        tenantOccupiedArea <- map["tenantOccupiedArea"]
        maxOccupancy <- map["maxOccupancy"]
        numberOfStaff <- map["numberOfStaff"]
        tenantInOccupation <- map["tenantInOccupation"]
        tenantName <- map["tenantName"]
        vacantAreaInBuilding <- map["vacantAreaInBuilding"]
        numOfFloors <- map["numOfFloors"]
        carParkSpaceAboveGround <- map["carParkSpaceAboveGround"]
        carParkSpaceBelowGround <- map["carParkSpaceBelowGround"]
        numOfBasementLevels <- map["numOfBasementLevels"]
        meetingClients <- map["meetingClients"]
    }
}

class ParentFolder: Mappable {
    var id: Int?
    var name: String?
    var required: String?
    var status: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        required <- map["required"]
        status <- map["status"]
    }
}

class ParentFoldersResponse: Mappable {
    var parentFolders: [ParentFolder]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        parentFolders <- map["parentFolders"]
    }
}

class AssetPATItem: Mappable {
    var patId: Int?
    var assetId: Int?
    var assetName: String?
    var patUserId: Int?
    var patUserName: String?
    var patDate: String?
    var patNextDate: String?
    var patStatus: String?
    
    init() { }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        patId <- map["patId"]
        assetId <- map["assetId"]
        assetName <- map["assetName"]
        patUserId <- map["patUserId"]
        patUserName <- map["patUserName"]
        patDate <- map["patDate"]
        patNextDate <- map["patNextDate"]
        patStatus <- map["patStatus"]
    }
}

class AssetPFPItem: Mappable {
    var assetId: Int?
    var product: String?
    var material: String?
    var access: String?
    var service: String?
    var dimension: String?
    var quantity: String?
    var area: String?
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        assetId <- map["assetId"]
        product <- map["product"]
        material <- map["material"]
        access <- map["access"]
        service <- map["service"]
        dimension <- map["dimension"]
        quantity <- map["quantity"]
        area <- map["area"]
    }
}

// Sub-model for Door Specifications
class AssetDoorSpecifications: Mappable {
    var assetId: Int?
    var width: String?
    var height: String?
    var depth: String?
    var fireRating: String?
    var finish: String?
    var visionPanel: String?
    var frameMaterial: String?
    var frameFinish: String?
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        assetId         <- map["assetId"]
        width           <- map["width"]
        height          <- map["height"]
        depth           <- map["depth"]
        fireRating      <- map["fireRating"]
        finish          <- map["finish"]
        visionPanel     <- map["visionPanel"]
        frameMaterial   <- map["frameMaterial"]
        frameFinish     <- map["frameFinish"]
    }
}

class LOV_Model: Mappable {
    var id: Int?
    var lovType: String?
    var lovValue: String?
    var lovDesc: String?
    var attribite1: String?
    var attribite2: String?
    var attribite3: String?
    var attribite4: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        lovType <- map["lovType"]
        lovValue <- map["lovValue"]
        lovDesc <- map["lovDesc"]
        attribite1 <- map["attribite1"]
        attribite2 <- map["attribite2"]
        attribite3 <- map["attribite3"]
        attribite4 <- map["attribite4"]
    }
}

class AssetDetailsResponse: Mappable, Equatable {
    var assetId: Int?
    var siteId: Int?
    var siteName: String?
    var assetName: String?
    var manufacturer: String?
    var category: String?
    var subCategory: String?
    var subCategory2: String?
    var subCategory3: String?
    var model: String?
    var serialNumber: String?
    var relatedAssetId: String?
    var relatedAssetName: String?
    var folderId: Int?
    var folderName: String?
    var image: String?
    var patItem: Bool?
    var pfpItem: Bool?
    var doorItem: Bool?
    var barcode: String?
    var position: String?
    var floor: String?
    var room: String?
    var purchaseDate: String?
    var invoiceFile: String?
    var supplier: String?
    var transactionId: String?
    var cost: String?
    var valuationDate: String?
    var valuationValue: String?
    var valuationUserId: Int?
    var valuationUserName: String?
    var disposalDate: String?
    var disposalValue: String?
    var disposalTo: String?
    
    var assetPATItems: [AssetPATItem]?
    var assetPFPItem: AssetPFPItem?
    var assetDoorSpecifications: AssetDoorSpecifications?
    
    var isSelected: Bool? = false
    
    var assetPATEntityList: [AssetPATItem]?
    var assetPFPEntity: AssetPFPItem?
    var assetDoorSpecificationEntity: AssetDoorSpecifications?
    var siteEntity: String?
    var documentsEntity: CreateFolderReq?
    var userEntity: User?
    var preActionAssetsEntity: [PreActionAssetsEntity]?
    var siteProjectContractsAssetEntity: [SiteProjectContractsFoldersEntity]?
    
    required init?(map: Map) {}
    
    init() { }
    
    static func == (lhs: AssetDetailsResponse, rhs: AssetDetailsResponse) -> Bool {
        return lhs.assetId == rhs.assetId
    }
    
    func mapping(map: Map) {
        assetId                 <- map["assetId"]
        siteId                  <- map["siteId"]
        siteName                <- map["siteName"]
        assetName               <- map["assetName"]
        manufacturer            <- map["manufacturer"]
        category                <- map["category"]
        subCategory             <- map["subCategory"]
        subCategory2            <- map["subCategory2"]
        subCategory3            <- map["subCategory3"]
        model                   <- map["model"]
        serialNumber            <- map["serialNumber"]
        relatedAssetId          <- map["relatedAssetId"]
        relatedAssetName        <- map["relatedAssetName"]
        folderId                <- map["folderId"]
        folderName              <- map["folderName"]
        image                   <- map["image"]
        patItem                 <- map["patItem"]
        pfpItem                 <- map["pfpItem"]
        doorItem                <- map["doorItem"]
        barcode                 <- map["barcode"]
        position                <- map["position"]
        floor                   <- map["floor"]
        room                    <- map["room"]
        purchaseDate            <- map["purchaseDate"]
        invoiceFile             <- map["invoiceFile"]
        supplier                <- map["supplier"]
        transactionId           <- map["transactionId"]
        cost                    <- map["cost"]
        valuationDate           <- map["valuationDate"]
        valuationValue          <- map["valuationValue"]
        valuationUserId         <- map["valuationUserId"]
        valuationUserName       <- map["valuationUserName"]
        disposalDate            <- map["disposalDate"]
        disposalValue           <- map["disposalValue"]
        disposalTo              <- map["disposalTo"]
        
        assetPATItems           <- map["assetPATItems"]
        assetPFPItem            <- map["assetPFPItem"]
        assetDoorSpecifications <- map["assetDoorSpecifications"]
        
        isSelected              <- map["isSelected"]
        
        assetPATEntityList <- map["assetPATEntityList"]
        assetPFPEntity <- map["assetPFPEntity"]
        assetDoorSpecificationEntity <- map["assetDoorSpecificationEntity"]
        siteEntity <- map["siteEntity"]
        documentsEntity <- map["documentsEntity"]
        userEntity <- map["userEntity"]
        preActionAssetsEntity <- map["preActionAssetsEntity"]
        siteProjectContractsAssetEntity <- map["siteProjectContractsAssetEntity"]
    }
}

class AssetsResponse: Mappable {
    var assets: [AssetDetailsResponse]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        assets <- map["assets"]
    }
}

class PATDetailsRequest: Mappable {
    var assetPATItems: [AssetPATItem]?
    var deletedPatIds: [Int]?
    
    init() { }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        assetPATItems <- map["assetPATItems"]
        deletedPatIds <- map["deletedPatIds"]
    }
}

class SiteContractsCategotyResponse: Mappable {
    var id: Int?
    var lovType: String?
    var lovValue: String?
    var lovDesc: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        lovType <- map["lovType"]
        lovValue <- map["lovValue"]
        lovDesc <- map["attribite1"]
    }
}

class CompanyDetails: Mappable {
    var companyId: Int?
    var companyName: String?
    var email: String?
    var phone: String?
    
    // Required initializer
    required init?(map: Map) {}
    
    init() {}
    
    // Mapping function
    func mapping(map: Map) {
        companyId   <- map["companyId"]
        companyName <- map["companyName"]
        email       <- map["email"]
        phone       <- map["phone"]
    }
}

// Response Model
class UsersResponse: Mappable {
    var users: [User]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        users <- map["users"]
    }
}

class ContractDetailsModel: Mappable {
    
    var projectContractId: Int?
    var summary: String?
    var siteId: Int?
    var category: String?
    var subCategory: String?
    var contractorCompanyId: Int?
    var status: String?
    var budget: String?
    var startDate: String?
    var endDate: String?
    var projectManagerUserId: Int?
    var description: String?
    var contractorQuotes: [ContractorQuote]?
    var frequency: String?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        projectContractId     <- map["projectContractId"]
        summary               <- map["summary"]
        siteId                <- map["siteId"]
        category              <- map["category"]
        subCategory           <- map["subCategory"]
        contractorCompanyId    <- map["contractorCompanyId"]
        status                <- map["status"]
        budget                <- map["budget"]
        startDate             <- map["startDate"]
        endDate               <- map["endDate"]
        projectManagerUserId   <- map["projectManagerUserId"]
        description           <- map["description"]
        contractorQuotes      <- map["contractorQuotes"]
        frequency             <- map["frequency"]
    }
}

class FolderRequest: Mappable {
    
    var mandatoryFolders: [Int]?
    var removeMandatoryFolders: [Int]?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        mandatoryFolders        <- map["mandatoryFolders"]
        removeMandatoryFolders  <- map["removeMandatoryFolders"]
    }
}

class AssetRequest: Mappable {
    
    var addAssets: [Int]?
    var removeAssets: [Int]?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        addAssets      <- map["addAssets"]
        removeAssets   <- map["removeAssets"]
    }
}

class ScheduleRequest: Mappable {
    
    var scheduleId: Int?
    var projectContractId: Int?
    var visitPurpose: String?
    var status: String?
    var visitDate: String?
    var rescheduleDate: String?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        scheduleId        <- map["scheduleId"]
        projectContractId <- map["projectContractId"]
        visitPurpose      <- map["visitPurpose"]
        status            <- map["status"]
        visitDate         <- map["visitDate"]
        rescheduleDate    <- map["rescheduleDate"]
    }
}

class CalenderEventRequest: Mappable {
    
    var siteId: Int?
    var startDate: String?
    var endDate: String?
    var shortText: String?
    var eventType: String?
    var userId: Int?
    var includeCompanyUsers: Bool?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        siteId              <- map["siteId"]
        startDate           <- map["startDate"]
        endDate             <- map["endDate"]
        shortText           <- map["shortText"]
        eventType           <- map["eventType"]
        userId              <- map["userId"]
        includeCompanyUsers <- map["includeCompanyUsers"]
    }
}

class CalendarEventResponse: Mappable {
    var calendarId: Int?
    var siteId: Int?
    var siteName: String?
    var startDate: String?
    var endDate: String?
    var shortText: String?
    var section: String?
    var sectionId: Int?
    var eventType: String?
    var userId: String?  // Notice that userId is a String here
    var userName: String?
    
    // Default initializer
    init() {}
    
    // Required initializer for mapping JSON to the object
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to variables
    func mapping(map: Map) {
        calendarId     <- map["calendarId"]
        siteId         <- map["siteId"]
        siteName       <- map["siteName"]
        startDate      <- map["startDate"]
        endDate        <- map["endDate"]
        shortText      <- map["shortText"]
        section        <- map["section"]
        sectionId      <- map["sectionId"]
        eventType      <- map["eventType"]
        userId         <- map["userId"]
        userName       <- map["userName"]
    }
}

class InspectionFaultModel: Mappable {
    
    enum Status: String, CaseIterable {
        case `default` = "Status"
        case open = "Open"
        case closed = "Closed"
        
        func textColor() -> UIColor {
            switch self {
            case .open:
                return UIColor(appColor: .AmberStatus)
            case .closed, .default:
                return UIColor(appColor: .GreenStatus)
            }
        }
        
        func textBGColor() -> UIColor {
            switch self {
            case .open:
                return UIColor(appColor: .AmberStatusBG)
            case .closed, .default:
                return UIColor(appColor: .GreenStatusBG)
            }
        }
    }
    
    var faultId: Int?
    var checkId: Int?
    var faultDescription: String?
    var dateRaised: String?
    var rating: Int?
    var assetId: String?
    var imageUrl: String?
    var action: String?
    var riskType: String?
    var closedByUserId: String?
    var closedDate: String?
    var status: Status?
    var siteCheck: String?
    
    var auditId: Int?
    var summary: String?
    
    var add: Bool?
    var siteId: Int?
    var folderName: String?
    
    var isEditing: Bool?
    var isForAddNew: Bool?
    var selectedFile: FilePickerModel?
    
    init() { }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        faultId <- map["faultId"]
        checkId <- map["checkId"]
        faultDescription <- map["faultDescription"]
        dateRaised <- map["dateRaised"]
        rating <- map["rating"]
        assetId <- map["assetId"]
        imageUrl <- map["imageUrl"]
        action <- map["action"]
        riskType <- map["riskType"]
        closedByUserId <- map["closedByUserId"]
        closedDate <- map["closedDate"]
        status <- map["status"]
        siteCheck <- map["siteCheck"]
        
        auditId <- map["auditId"]
        summary <- map["summary"]
        
        add <- map["add"]
        siteId <- map["siteId"]
        folderName <- map["folderName"]
    }
}

class SiteCheckInspectionModel: Mappable {
    var certificateId: Int?
    var checkId: Int?
    var certificateName: String?
    var reviewerUserId: String?
    var issueDate: String?
    var expiryDate: String?
    var note: String?
    var certificateUrl: String?
    var status: String?
    var siteCheck: SiteCheckModel?
    
    var siteId: Int?
    var folderName: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        certificateId <- map["certificateId"]
        checkId <- map["checkId"]
        certificateName <- map["certificateName"]
        reviewerUserId <- map["reviewerUserId"]
        issueDate <- map["issueDate"]
        expiryDate <- map["expiryDate"]
        note <- map["note"]
        certificateUrl <- map["certificateUrl"]
        status <- map["status"]
        siteCheck <- map["siteCheck"]
        
        siteId <- map["siteId"]
        folderName <- map["folderName"]
    }
}

class SiteModel: Mappable {
    var siteId: Int?
    var siteName: String?
    var address1: String?
    var address2: String?
    var postCode: String?
    var status: String?
    var area: String?
    var city: String?
    var riskScores: [Int] = [0,0,0,0]
    
    required init?(map: Map) { }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        siteId <- map["siteId"]
        siteName <- map["siteName"]
        address1 <- map["address1"]
        address2 <- map["address2"]
        postCode <- map["postCode"]
        status <- map["status"]
        area <- map["area"]
        city <- map["city"]
        riskScores <- map["riskScores"]
    }
}

class LoginRequestModel: Mappable {
    
    var email: String?
    var password: String?
    
    required init?(map: Map) { }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        password <- map["password"]
    }
    
}

class ProjectContractResponse: Mappable {
    
    var frequency: String?
    var projectContractId: Int?
    var summary: String?
    var siteId: Int?
    var category: String?
    var subCategory: String?
    var contractorCompanyId: String?
    var status: String?
    var budget: String?
    var cost: String?
    var startDate: String?
    var endDate: String?
    var projectManagerUserId: Int?
    var description: String?
    var siteName: String?
    var projectManagerName: String?
    var contractorCompanyName: String?
    var contractorQuotes: [ContractorQuote]?
    var projectContractFolders: [ProjectContractFolderModel]?
    var projectContractAssets: [ProjectContractAsset]?
    var projectContractScheduleVisits: [ProjectContractScheduleVisit]?
    
    // Initialize the mapping function
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        frequency                    <- map["frequency"]
        contractorQuotes             <- map["contractorQuotes"]
        projectContractId            <- map["projectContractId"]
        summary                      <- map["summary"]
        siteId                       <- map["siteId"]
        category                     <- map["category"]
        subCategory                  <- map["subCategory"]
        contractorCompanyId          <- map["contractorCompanyId"]
        status                       <- map["status"]
        budget                       <- map["budget"]
        cost                         <- map["cost"]
        startDate                    <- map["startDate"]
        endDate                      <- map["endDate"]
        projectManagerUserId         <- map["projectManagerUserId"]
        description                  <- map["description"]
        siteName                     <- map["siteName"]
        projectManagerName           <- map["projectManagerName"]
        contractorCompanyName        <- map["contractorCompanyName"]
        projectContractFolders       <- map["projectContractFolders"]
        projectContractAssets        <- map["projectContractAssets"]
        projectContractScheduleVisits <- map["projectContractScheduleVisits"]
    }
}

class ProjectContractAsset: Mappable {
    
    var assetId: Int?
    var assetName: String?
    var category: String?
    var subCategory: String?
    var subCategory2: String?
    var manufacturer: String?
    var model: String?
    var serialNumber: String?
    var position: String?
    var floor: String?
    var room: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        assetId        <- map["assetId"]
        assetName      <- map["assetName"]
        category       <- map["category"]
        subCategory    <- map["subCategory"]
        subCategory2   <- map["subCategory2"]
        manufacturer   <- map["manufacturer"]
        model          <- map["model"]
        serialNumber   <- map["serialNumber"]
        position       <- map["position"]
        floor          <- map["floor"]
        room           <- map["room"]
    }
}

class ProjectContractScheduleVisit: Mappable {
    
    var scheduleId: Int?
    var visitPurpose: String?
    var status: String?
    var visitDate: String?
    var rescheduleDate: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        scheduleId      <- map["scheduleId"]
        visitPurpose    <- map["visitPurpose"]
        status          <- map["status"]
        visitDate       <- map["visitDate"]
        rescheduleDate  <- map["rescheduleDate"]
    }
}

class ProjectContractFolderModel: Mappable {
    var id: Int?
    var name: String?
    var files: [FileModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id    <- map["id"]
        name  <- map["name"]
        files <- map["files"]
    }
}

class FileModel: Mappable {
    var id: Int?
    var version: Int?
    var name: String?
    var url: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id      <- map["id"]
        version <- map["version"]
        name    <- map["name"]
        url     <- map["url"]
    }
}

class ContractorQuote: Mappable {
    var quoteId: Int?
    var contractor: String?
    var company: String?
    var quote: Double?
    var quoteDate: String?
    var status: String?
    var notes: String?
    var managerNotes: String?
    var projectContractId: Int?
    
    init() {
        
    }
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {
    }
    
    // Mapping function
    func mapping(map: Map) {
        quoteId            <- map["quoteId"]
        contractor         <- map["contractor"]
        company            <- map["company"]
        quote              <- map["quote"]
        quoteDate          <- map["quoteDate"]
        status             <- map["status"]
        notes              <- map["notes"]
        managerNotes       <- map["managerNotes"]
        projectContractId  <- map["projectContractId"]
    }
}

// PreAction Model
class PreActionResponseModel: Mappable {
    var raisedDate: String?
    var taggedAsset: String?
    var actionId: Int?
    var category: String?
    var floor: String?
    var room: String?
    var image: String?
    var description: String?
    var raisedByUserId: Int?
    var raisedByUserName: String?
    var status: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        raisedDate <- map["raisedDate"]
        taggedAsset <- map["taggedAsset"]
        actionId <- map["actionId"]
        category <- map["category"]
        floor <- map["floor"]
        room <- map["room"]
        image <- map["image"]
        description <- map["description"]
        raisedByUserId <- map["raisedByUserId"]
        raisedByUserName <- map["raisedByUserName"]
        status <- map["status"]
    }
}

class CreatePreActionRequestModel: Mappable {
    var category: String?
    var floor: String?
    var room: String?
    var description: String?
    var status: String?
    var actionId: Int?
    var raisedByUserId: Int?
    var taggedAsset: String?
    
    init() { }
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {
        // This can be left empty or used to validate mandatory fields
    }
    
    // Mapping function that maps the JSON keys to the properties
    func mapping(map: Map) {
        category          <- map["category"]
        floor             <- map["floor"]
        room              <- map["room"]
        description       <- map["description"]
        status            <- map["status"]
        actionId          <- map["actionId"]
        raisedByUserId    <- map["raisedByUserId"]
        taggedAsset       <- map["taggedAsset"]
    }
}

class CreatePreActrionResponseModel: Mappable {
    var taggedAsset: String?
    var actionId: Int?
    var siteId: Int?
    var category: String?
    var floor: String?
    var room: String?
    var image: String?
    var description: String?
    var raisedByUserId: Int?
    var status: String?
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {
        // This can be left empty or used to validate mandatory fields
    }
    
    // Mapping function that maps the JSON keys to the properties
    func mapping(map: Map) {
        taggedAsset      <- map["taggedAsset"]
        actionId         <- map["actionId"]
        siteId           <- map["siteId"]
        category         <- map["category"]
        floor            <- map["floor"]
        room             <- map["room"]
        image            <- map["image"]
        description      <- map["description"]
        raisedByUserId   <- map["raisedByUserId"]
        status           <- map["status"]
    }
}

class StatusRequestModel: Mappable {
    var status: String?
    var actionTaken: String?
    
    init() { }
    
    // Default initializer
    init(status: String?, actionTaken: String?) {
        self.status = status
        self.actionTaken = actionTaken
    }
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function for ObjectMapper
    func mapping(map: Map) {
        status      <- map["status"]
        actionTaken <- map["actionTaken"]
    }
}

class StatusModel: Mappable {
    var status: String?
    var approverNotes: String?
    
    init() { }
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function to map JSON fields to model properties
    func mapping(map: Map) {
        status        <- map["status"]
        approverNotes <- map["approverNotes"]
    }
}

class ClientAction: Mappable {
    var type: String?
    var status: String?
    var observation: String?
    var desc: String?
    var requiredAction: String?
    var riskScore: Int?
    var dueDate: String?
    var siteId: Int?
    var userId: Int?
    
    init() { }
    
    // Initialize mapping
    required init?(map: Map) {}
    
    // Mapping function
    func mapping(map: Map) {
        type           <- map["type"]
        status         <- map["status"]
        observation    <- map["observation"]
        desc           <- map["desc"]
        requiredAction <- map["requiredAction"]
        riskScore      <- map["riskScore"]
        dueDate        <- map["dueDate"]
        siteId         <- map["siteId"]
        userId         <- map["userId"]
    }
}

class ClientActionResponse: Mappable {
    var actionId: Int?
    var type: String?
    var status: String?
    var observation: String?
    var desc: String?
    var requiredAction: String?
    var riskScore: Int?
    var dueDate: String?
    var siteId: Int?
    var userId: Int?
    var competentPersons: String?
    var serviceProvider: String?
    var stakeholder: String?
    var assignedTo: String?
    var comments: String?
    var internalExternal: String?
    var floor: String?
    var actionImage: String?
    var room: String?
    var taggedAsset: String?
    var createdAt: String?
    var completedAt: String?
    var completedBy: String?
    
    // Initialize mapping
    required init?(map: Map) {}
    
    // Mapping function
    func mapping(map: Map) {
        actionId           <- map["actionId"]
        type               <- map["type"]
        status             <- map["status"]
        observation        <- map["observation"]
        desc               <- map["desc"]
        requiredAction     <- map["requiredAction"]
        riskScore          <- map["riskScore"]
        dueDate            <- map["dueDate"]
        siteId             <- map["siteId"]
        userId             <- map["userId"]
        competentPersons   <- map["competentPersons"]
        serviceProvider    <- map["serviceProvider"]
        stakeholder        <- map["stakeholder"]
        assignedTo         <- map["assignedTo"]
        comments           <- map["comments"]
        internalExternal   <- map["internalExternal"]
        floor              <- map["floor"]
        actionImage        <- map["actionImage"]
        room               <- map["room"]
        taggedAsset        <- map["taggedAsset"]
        createdAt          <- map["createdAt"]
        completedAt        <- map["completedAt"]
        completedBy        <- map["completedBy"]
    }
    
}

class CategoryModel: Mappable {
    var categoryList: [String?]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        categoryList <- map["categoryList"]
    }
}

class DropDownModel: Mappable {
    var id: Int?
    var lovType: String?
    var lovValue: String?
    var lovDesc: String?
    var attribite1: String?
    var attribite2: String?
    var attribite3: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id           <- map["id"]
        lovType      <- map["lovType"]
        lovValue     <- map["lovValue"]
        lovDesc      <- map["lovDesc"]
        attribite1   <- map["attribite1"]
        attribite2   <- map["attribite2"]
        attribite3   <- map["attribite3"]
    }
}

class DropDownSubCategory: Mappable {
    var id: Int?
    var add: Bool?
    var edit: Bool?
    var attribite1: String?
    var attribite2: String?
    var attribite3: String?
    var lovDesc: String?
    var lovType: String?
    var lovValue: String?
    
    init() {
        
    }
    
    // Default initializer required by ObjectMapper
    required init?(map: Map) {
        // Initialization code, if necessary
    }
    
    // Mapping function where fields from JSON are mapped to Swift properties
    func mapping(map: Map) {
        id           <- map["id"]
        add        <- map["add"]
        edit        <- map["add"]
        attribite1 <- map["attribite1"]
        attribite2 <- map["attribite2"]
        attribite3 <- map["attribite3"]
        lovDesc    <- map["lovDesc"]
        lovType    <- map["lovType"]
        lovValue   <- map["lovValue"]
    }
}

//class ResetPasswordRequest: Mappable {
//    var email: String?
//    var otp: String?
//    var password: String?
//
//    init() {}
//
//    init(email: String, otp: String, password: String) {
//        self.email = email
//        self.otp = otp
//        self.password = password
//    }
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//        email       <- map["email"]
//        otp         <- map["otp"]
//        password    <- map["password"]
//    }
//}

class EnergyUsage: Mappable {
    var budgetCategory: String?
    var cost: String?
    var energyId: Int?
    var fromDate: String?
    var siteId: Int?
    var submittedUserId: Int?
    var toDate: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        // Initialize any necessary variables or perform checks
    }
    
    func mapping(map: Map) {
        budgetCategory     <- map["budgetCategory"]
        cost               <- map["cost"]
        energyId           <- map["energyId"]
        fromDate           <- map["fromDate"]
        siteId             <- map["siteId"]
        submittedUserId    <- map["submittedUserId"]
        toDate             <- map["toDate"]
    }
}


class ReqEnergyReading: Mappable {
    var energyId: Int?
    var readingDate: String?
    var readingUnit: String?
    var readingValue: String?
    var siteId: Int?
    var submittedUserId: Int?
    
    init() {
        
    }
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {
    }
    
    // Function to map the fields
    func mapping(map: Map) {
        energyId          <- map["energyId"]
        readingDate       <- map["readingDate"]
        readingUnit       <- map["readingUnit"]
        readingValue      <- map["readingValue"]
        siteId            <- map["siteId"]
        submittedUserId   <- map["submittedUserId"]
    }
}

class ResetPasswordRequest: Mappable {
    var email: String?
    var otp: String?
    var password: String?
    
    init() {}
    
    init(email: String, otp: String, password: String) {
        self.email = email
        self.otp = otp
        self.password = password
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        email       <- map["email"]
        otp         <- map["otp"]
        password    <- map["password"]
    }
}

class ActionResponseModel: Mappable {
    var actionId: Int?
    var type: String?
    var status: String?
    var observation: String?
    var desc: String?
    var requiredAction: String?
    var riskScore: Int?
    var dueDate: String?
    var siteId: Int?
    var userId: Int?
    var competentPersons: String?
    var serviceProvider: String?
    var stakeholder: Int?
    var assignedTo: Int?
    var comments: String?
    var internalExternal: String?
    var floor: String?
    var actionImage: String?
    var room: String?
    var taggedAsset: String?
    var createdAt: String?
    var completedAt: String?
    var completedBy: String?
    
    required init?(map: Map) {
        // Empty initializer for Mappable protocol
    }
    
    func mapping(map: Map) {
        actionId           <- map["actionId"]
        type               <- map["type"]
        status             <- map["status"]
        observation        <- map["observation"]
        desc               <- map["desc"]
        requiredAction     <- map["requiredAction"]
        riskScore          <- map["riskScore"]
        dueDate            <- map["dueDate"]
        siteId             <- map["siteId"]
        userId             <- map["userId"]
        competentPersons   <- map["competentPersons"]
        serviceProvider    <- map["serviceProvider"]
        stakeholder        <- map["stakeholder"]
        assignedTo         <- map["assignedTo"]
        comments           <- map["comments"]
        internalExternal   <- map["internalExternal"]
        floor              <- map["floor"]
        actionImage        <- map["actionImage"]
        room               <- map["room"]
        taggedAsset        <- map["taggedAsset"]
        createdAt          <- map["createdAt"]
        completedAt        <- map["completedAt"]
        completedBy        <- map["completedBy"]
    }
}

class AddCommentsRequestModel: Mappable {
    var text: String?
    var date: String?
    var userId: Int?
    var actionId: String?
    var createdAt: String?
    
    required init?(map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        text       <- map["text"]
        date       <- map["date"]
        userId     <- map["userId"]
        actionId   <- map["actionId"]
        createdAt  <- map["createdAt"]
    }
}

class AddedCommentResponseModel: Mappable {
    var commentId: Int?
    var text: String?
    var actionId: Int?
    var userId: Int?
    var image: String?  // Assuming `image` is a URL or base64 encoded string; update type if needed
    var createdAt: String?
    var user: Any?  // Adjust the type if you have a specific model for `user`
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        commentId   <- map["commentId"]
        text        <- map["text"]
        actionId    <- map["actionId"]
        userId      <- map["userId"]
        image       <- map["image"]
        createdAt   <- map["createdAt"]
        user        <- map["user"]
    }
}

class APIErrorResponse: Mappable {
    var timestamp: String?
    var status: Int?
    var error: String?
    var message: String?
    var path: String?
    
    // Required initializer for ObjectMapper
    required init?(map: Map) { }
    
    // Mapping function to bind JSON keys to properties
    func mapping(map: Map) {
        timestamp <- map["timestamp"]
        status    <- map["status"]
        error     <- map["error"]
        message   <- map["message"]
        path      <- map["path"]
    }
}
