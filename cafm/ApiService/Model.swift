//
//  Model.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import ObjectMapper

class UserModel: Mappable {
    var favorite: String?
    var id: Int?
    var name: String?
    var role: String?
    var email: String?
    var companyId: Int?
    var companyName: String?
    var phone: String?
    var status: String?
    var defaultSiteId: Int?
    var defaultSiteName: String?
    var trade: String?
    var userType: String?
    var creationDate: String?
    var taggedSites: [TaggedSite]?
    
    var userId: Int?
    var firstName: String?
    var lastName: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        favorite        <- map["favorite"]
        id              <- map["id"]
        name            <- map["name"]
        role            <- map["role"]
        email           <- map["email"]
        companyId       <- map["companyId"]
        companyName     <- map["companyName"]
        phone           <- map["phone"]
        status          <- map["status"]
        defaultSiteId   <- map["defaultSiteId"]
        defaultSiteName <- map["defaultSiteName"]
        trade           <- map["trade"]
        userType        <- map["userType"]
        creationDate    <- map["creationDate"]
        taggedSites     <- map["taggedSites"]
        userId          <- map["userId"]
        firstName       <- map["firstName"]
        lastName        <- map["lastName"]
    }
}

class TaggedSite: Mappable {
    var id: Int?
    var name: String?
    
    required init?(map: Map) {}
    
    init() {
        
    }
    
    func mapping(map: Map) {
        id   <- map["id"]
        name <- map["name"]
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
    var status: Status?
    
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
    
    var start_date: Date?
    var end_date: Date?
    
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
        start_date <- (map["start_date"], DateTransform())
        end_date <- (map["end_date"], DateTransform())
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

class SiteCheckModel: Mappable {
    var checkId: Int?
    var siteId: Int?
    var type: String?
    var subType: String?
    var category: String?
    var dueDate: String?
    var leadUserID: String?
    var assistantUserID: String?
    var repeatFrequency: String?
    var status: String?
    var riskScoreRed: Int?
    var riskScoreAmber: Int?
    var riskScoreYellow: Int?
    var riskScoreGreen: Int?
    
    required init?(map: Map) {
        // Initialize if needed
    }
    
    func mapping(map: Map) {
        checkId <- map["checkId"]
        siteId <- map["siteId"]
        type <- map["type"]
        subType <- map["subType"]
        category <- map["category"]
        dueDate <- map["dueDate"]
        leadUserID <- map["leadUserID"]
        assistantUserID <- map["assistantUserID"]
        repeatFrequency <- map["repeatFrequency"]
        status <- map["status"]
        riskScoreRed <- map["riskScoreRed"]
        riskScoreAmber <- map["riskScoreAmber"]
        riskScoreYellow <- map["riskScoreYellow"]
        riskScoreGreen <- map["riskScoreGreen"]
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
    }
}

class CreateSiteRequestModel: Mappable {
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

    required init?(map: Map) {
        // Initialize if needed
    }
    
    init() { }
    
    func mapping(map: Map) {
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

class SiteResponseModel: Mappable {
    
    var siteId: Int?
    var siteName: String?
    var address1: String?
    var address2: String?
    var area: String?
    var city: String?
    var postCode: String?
    var country: String?
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
    var clientResponsiblity: Bool?
    
    var siteDocumentsEntity: [Any]?
    var userEntity: [Any]?
    var documentsEntity: [Any]?
    var userSitesEntity: [Any]?
    var siteChecks: [Any]?
    
    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    // Mapping function to map JSON keys to model properties
    func mapping(map: Map) {
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
        clientResponsiblity <- map["clientResponsiblity"]
        
        siteDocumentsEntity <- map["siteDocumentsEntity"]
        userEntity          <- map["userEntity"]
        documentsEntity     <- map["documentsEntity"]
        userSitesEntity     <- map["userSitesEntity"]
        siteChecks          <- map["siteChecks"]
    }
}

class keyContacts: Mappable {
    var updateKeyContactRequestModel: [UpdateKeyContactRequestModel]?
    
    // Default initializer
    init() {}

    // Required initializer for ObjectMapper
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        updateKeyContactRequestModel             <- map["updateKeyContactRequestModel"]
    }

}

class UpdateKeyContactRequestModel: Mappable {
    var id: String?
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

class SiteScheduleResponseModel: Mappable {
    var siteId: Int?
    var siteName: String?
    var address1: String?
    var address2: String?
    var area: String?
    var city: String?
    var postCode: String?
    var country: String?
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
    var clientResponsibility: Bool?
    var siteDocumentsEntity: [String] = []
    var userEntity: [String] = []
    var documentsEntity: [String] = []
    var userSitesEntity: [String] = []
    var siteChecks: [String] = []
    var siteProjectContractsEntity: [String] = []
    var siteEnergySurvey: [String] = []
    var assetEntity: [String] = []

    // Default initializer
    init() {}

    // Required initializer for ObjectMapper
    required init?(map: Map) {}

    // Mapping function to map JSON keys to properties
    func mapping(map: Map) {
        siteId                    <- map["siteId"]
        siteName                  <- map["siteName"]
        address1                  <- map["address1"]
        address2                  <- map["address2"]
        area                      <- map["area"]
        city                      <- map["city"]
        postCode                  <- map["postCode"]
        country                   <- map["country"]
        status                    <- map["status"]
        mapViewUrl                <- map["mapViewUrl"]
        streetViewUrl             <- map["streetViewUrl"]
        monStartTime              <- map["monStartTime"]
        tuesStartTime             <- map["tuesStartTime"]
        wedStartTime              <- map["wedStartTime"]
        thurStartTime             <- map["thurStartTime"]
        friStartTime              <- map["friStartTime"]
        satStartTime              <- map["satStartTime"]
        sunStartTime              <- map["sunStartTime"]
        monEndTime                <- map["monEndTime"]
        tuesEndTime               <- map["tuesEndTime"]
        wedEndTime                <- map["wedEndTime"]
        thurEndTime               <- map["thurEndTime"]
        friEndTime                <- map["friEndTime"]
        satEndTime                <- map["satEndTime"]
        sunEndTime                <- map["sunEndTime"]
        localAuthority            <- map["localAuthority"]
        siteImageUrl              <- map["siteImageUrl"]
        clientResponsibility      <- map["clientResponsibility"]
        siteDocumentsEntity       <- map["siteDocumentsEntity"]
        userEntity                <- map["userEntity"]
        documentsEntity           <- map["documentsEntity"]
        userSitesEntity           <- map["userSitesEntity"]
        siteChecks                <- map["siteChecks"]
        siteProjectContractsEntity <- map["siteProjectContractsEntity"]
        siteEnergySurvey          <- map["siteEnergySurvey"]
        assetEntity               <- map["assetEntity"]
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
        case master = "MasterNode"
        case position = "position"
        case floor = "floor"
        case room = "room"
        
        var title: String {
            switch self {
            case .default:
                return "Select Node Type"
            case .master:
                return "Main Building"
            case .position, .floor, .room:
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
