//
//  SiteCheckModel.swift
//  cafm
//
//  Created by NS on 21/09/24.
//
//

import ObjectMapper

class SiteCheckModel: Mappable {
    
    enum Status: String, CaseIterable {
        case `default` = "Status"
        case open = "Open"
        case done = "Done"
        
        func textColor() -> UIColor {
            switch self {
            case .open, .default:
                return UIColor(appColor: .AmberStatus)
            case .done:
                return UIColor(appColor: .GreenStatus)
            }
        }
        
        func textBGColor() -> UIColor {
            switch self {
            case .open, .default:
                return UIColor(appColor: .AmberStatusBG)
            case .done:
                return UIColor(appColor: .GreenStatusBG)
            }
        }
    }
    
    enum RepeatFrequency: String, CaseIterable {
        case `default` = "None"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var checkId: Int?
    var siteId: Int?
    var type: String?
    var subType: String?
    var category: String?
    var dueDate: String?
    var startDate: String?
    var leadUserID: String?
    var assistantUserID: String?
    var repeatFrequency: RepeatFrequency?
    var status: Status?
    var riskScoreRed: Int?
    var riskScoreAmber: Int?
    var riskScoreYellow: Int?
    var riskScoreGreen: Int?
    var siteEntity: CreateSiteRequestModel?
    var siteCheckAsbestosSample: [SiteCheckAsbestosSample]?
    var siteCheckAsbestosSurvey: [SiteCheckAsbestosSurvey]?
    var siteCheckAssessment: [SiteCheckAssessment]?
    var siteCheckAssessmentResponse: [SiteCheckAssessmentResponse]?
    var siteCheckAudit: [InspectionFaultModel]?
    var siteCheckDomesticRASurvey: [SiteCheckAssessmentResponse]?
    var siteCheckInspection: [String]?
    var siteCheckInspectionFault: [InspectionFaultModel]?
    var siteCheckWaterOutletTemp: [SiteCheckWaterOutletTemp]?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        checkId <- map["checkId"]
        siteId <- map["siteId"]
        type <- map["type"]
        subType <- map["subType"]
        category <- map["category"]
        dueDate <- map["dueDate"]
        startDate <- map["startDate"]
        leadUserID <- map["leadUserID"]
        assistantUserID <- map["assistantUserID"]
        repeatFrequency <- map["repeatFrequency"]
        status <- map["status"]
        riskScoreRed <- map["riskScoreRed"]
        riskScoreAmber <- map["riskScoreAmber"]
        riskScoreYellow <- map["riskScoreYellow"]
        riskScoreGreen <- map["riskScoreGreen"]
        siteEntity <- map["siteEntity"]
        siteCheckAsbestosSample <- map["siteCheckAsbestosSample"]
        siteCheckAsbestosSurvey <- map["siteCheckAsbestosSurvey"]
        siteCheckAssessment <- map["siteCheckAssessment"]
        siteCheckAssessmentResponse <- map["siteCheckAssessmentResponse"]
        siteCheckAudit <- map["siteCheckAudit"]
        siteCheckDomesticRASurvey <- map["siteCheckDomesticRASurvey"]
        siteCheckInspection <- map["siteCheckInspection"]
        siteCheckInspectionFault <- map["siteCheckInspectionFault"]
        siteCheckWaterOutletTemp <- map["siteCheckWaterOutletTemp"]
    }
    
}

class SiteDocumentsEntity: Mappable {
    var siteDocumentId: SiteDocumentId?
    var fileName: String?
    var fileBlob: String?
    var siteId: Int?
    var folderId: Int?
    var source: String?
    var uploaderUserId: Int?
    var uploadDate: String?
    var issueDate: String?
    var expiryDate: String?
    var reviewerUserId: Int?
    var note: String?
    var referenceNumber: String?
    var statutoryCategoryId: Int?
    var siteEntity: String?
    var documentsEntity: CreateFolderReq?
    var userEntity: User?
    var reviewerUserEntity: User?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        siteDocumentId <- map["siteDocumentId"]
        fileName <- map["fileName"]
        fileBlob <- map["fileBlob"]
        siteId <- map["siteId"]
        folderId <- map["folderId"]
        source <- map["source"]
        uploaderUserId <- map["uploaderUserId"]
        uploadDate <- map["uploadDate"]
        issueDate <- map["issueDate"]
        expiryDate <- map["expiryDate"]
        reviewerUserId <- map["reviewerUserId"]
        note <- map["note"]
        referenceNumber <- map["referenceNumber"]
        statutoryCategoryId <- map["statutoryCategoryId"]
        siteEntity <- map["siteEntity"]
        documentsEntity <- map["documentsEntity"]
        userEntity <- map["userEntity"]
        reviewerUserEntity <- map["reviewerUserEntity"]
    }
    
}

class SiteDocumentId: Mappable {
    var fileId: Int?
    var fileVersion: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        fileId <- map["fileId"]
        fileVersion <- map["fileVersion"]
    }
    
}

class CompanyEntity: Mappable {
    var companyId: Int?
    var companyName: String?
    var email: String?
    var phone: String?
    var userEntity: [String]?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        companyId <- map["companyId"]
        companyName <- map["companyName"]
        email <- map["email"]
        phone <- map["phone"]
        userEntity <- map["userEntity"]
    }
    
}

class UserSitesEntity: Mappable {
    var userSiteId: ActionModel?
    var siteEntity: String?
    var userEntity: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        userSiteId <- map["userSiteId"]
        siteEntity <- map["siteEntity"]
        userEntity <- map["userEntity"]
    }
    
}

class SiteProjectContractsFoldersEntity: Mappable {
    var siteProjectContractsFolderId: SiteProjectContractsFolderId?
    var documentsEntity: CreateFolderReq?
    var siteProjectContractsEntity: String?
    
    var siteProjectContractsAssetId: SiteProjectContractsFolderId?
    var assetEntity: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        siteProjectContractsFolderId <- map["siteProjectContractsFolderId"]
        documentsEntity <- map["documentsEntity"]
        siteProjectContractsEntity <- map["siteProjectContractsEntity"]
        
        siteProjectContractsAssetId <- map["siteProjectContractsAssetId"]
        assetEntity <- map["assetEntity"]
    }
    
}

class SiteProjectContractsFolderId: Mappable {
    var projectContractId: Int?
    var folderId: Int?
    
    var assetId: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        projectContractId <- map["projectContractId"]
        folderId <- map["folderId"]
        
        assetId <- map["assetId"]
    }
    
}

class SiteScheduleVisitEntity: Mappable {
    var scheduleId: Int?
    var projectContractId: Int?
    var visitPurpose: String?
    var status: String?
    var visitDate: String?
    var rescheduleDate: String?
    var siteProjectContractsEntity: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        scheduleId <- map["scheduleId"]
        projectContractId <- map["projectContractId"]
        visitPurpose <- map["visitPurpose"]
        status <- map["status"]
        visitDate <- map["visitDate"]
        rescheduleDate <- map["rescheduleDate"]
        siteProjectContractsEntity <- map["siteProjectContractsEntity"]
    }
    
}

class SiteCheckAsbestosSample: Mappable {
    var sampleId: Int?
    var checkId: Int?
    var sampleFileUrl: String?
    var position: String?
    var floor: String?
    var room: String?
    var area: String?
    var quantity: Int?
    var hseNotification: String?
    var licensedMaterial: String?
    var identification: String?
    var comment: String?
    var removedFromSite: Bool?
    var productType: String?
    var damage: String?
    var surfaceTreatment: String?
    var asbestosType: String?
    var mainActivityScore: Int?
    var secondaryActivityScore: Int?
    var location: String?
    var accessibility: String?
    var extent: String?
    var occupants: Int?
    var frequencyOfUse: String?
    var avgTimeInUse: String?
    var maintenanceActivityType: String?
    var maintenanceFrequency: String?
    var acmOption: String?
    var measureAction: String?
    var remedialCost: Int?
    var recommendationDue: String?
    var nextInspectionDate: String?
    var labels: String?
    var ptwRequired: String?
    var status: String?
    var riskType: String?
    var totalMatScore: Int?
    var totalPriScore: Int?
    var totalRiskScore: Int?
    var closedUserId: Int?
    var closedDate: String?
    var siteCheck: String?
    
    var update: Bool?
    var sampleNo: String?
    var expanded: Bool?
    var siteId: Int?
    
    var isEditing: Bool?
    var isForAddNew: Bool?
    var selectedFile: FilePickerModel?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        sampleId <- map["sampleId"]
        checkId <- map["checkId"]
        sampleFileUrl <- map["sampleFileUrl"]
        position <- map["position"]
        floor <- map["floor"]
        room <- map["room"]
        area <- map["area"]
        quantity <- map["quantity"]
        hseNotification <- map["hseNotification"]
        licensedMaterial <- map["licensedMaterial"]
        identification <- map["identification"]
        comment <- map["comment"]
        removedFromSite <- map["removedFromSite"]
        productType <- map["productType"]
        damage <- map["damage"]
        surfaceTreatment <- map["surfaceTreatment"]
        asbestosType <- map["asbestosType"]
        mainActivityScore <- map["mainActivityScore"]
        secondaryActivityScore <- map["secondaryActivityScore"]
        location <- map["location"]
        accessibility <- map["accessibility"]
        extent <- map["extent"]
        occupants <- map["occupants"]
        frequencyOfUse <- map["frequencyOfUse"]
        avgTimeInUse <- map["avgTimeInUse"]
        maintenanceActivityType <- map["maintenanceActivityType"]
        maintenanceFrequency <- map["maintenanceFrequency"]
        acmOption <- map["acmOption"]
        measureAction <- map["measureAction"]
        remedialCost <- map["remedialCost"]
        recommendationDue <- map["recommendationDue"]
        nextInspectionDate <- map["nextInspectionDate"]
        labels <- map["labels"]
        ptwRequired <- map["ptwRequired"]
        status <- map["status"]
        riskType <- map["riskType"]
        totalMatScore <- map["totalMatScore"]
        totalPriScore <- map["totalPriScore"]
        totalRiskScore <- map["totalRiskScore"]
        closedUserId <- map["closedUserId"]
        closedDate <- map["closedDate"]
        siteCheck <- map["siteCheck"]
        
        update <- map["update"]
        sampleNo <- map["sampleNo"]
        expanded <- map["expanded"]
        siteId <- map["siteId"]
    }
    
}

class SiteEnergySurvey: Mappable {
    var energyId: Int?
    var reference: String?
    var budgetCategory: String?
    var siteId: Int?
    var siteEntity: String?
    var energyReadings: [EnergyReadings]?
    var energyCost: [EnergyCost]?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        energyId <- map["energyId"]
        reference <- map["reference"]
        budgetCategory <- map["budgetCategory"]
        siteId <- map["siteId"]
        siteEntity <- map["siteEntity"]
        energyReadings <- map["energyReadings"]
        energyCost <- map["energyCost"]
    }
    
}

class EnergyReadings: Mappable {
    var readingId: Int?
    var readingValue: Int?
    var readingDate: String?
    var readingUnit: String?
    var energyId: Int?
    var submittedUserId: String?
    var siteEnergySurvey: String?
    var siteId: Int?
    var reference: String?
    var budgetCategory: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        readingId <- map["readingId"]
        readingValue <- map["readingValue"]
        readingDate <- map["readingDate"]
        readingUnit <- map["readingUnit"]
        energyId <- map["energyId"]
        submittedUserId <- map["submittedUserId"]
        siteEnergySurvey <- map["siteEnergySurvey"]
        siteId <- map["siteId"]
        reference <- map["reference"]
        budgetCategory <- map["budgetCategory"]
    }
    
}

class EnergyCost: Mappable {
    var costId: Int?
    var fromDate: String?
    var toDate: String?
    var cost: Int?
    var budgetCategory: String?
    var submittedBy: String?
    var energyId: Int?
    var siteId: Int?
    var reference: String?
    var siteEnergySurvey: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        costId <- map["costId"]
        fromDate <- map["fromDate"]
        toDate <- map["toDate"]
        cost <- map["cost"]
        budgetCategory <- map["budgetCategory"]
        submittedBy <- map["submittedBy"]
        energyId <- map["energyId"]
        siteId <- map["siteId"]
        reference <- map["reference"]
        siteEnergySurvey <- map["siteEnergySurvey"]
    }
    
}

class PreActionAssetsEntity: Mappable {
    var preActionAssetId: PreActionAssetId?
    var preActionEntity: PreAction?
    var assetEntity: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        preActionAssetId <- map["preActionAssetId"]
        preActionEntity <- map["preActionEntity"]
        assetEntity <- map["assetEntity"]
    }
    
}

class PreActionAssetId: Mappable {
    var actionId: Int?
    var assetId: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        actionId <- map["actionId"]
        assetId <- map["assetId"]
    }
    
}

class SiteCheckAsbestosSurvey: Mappable {
    var id: Int?
    var checkId: Int?
    var surveyCompany: String?
    var ukasLab: String?
    var reportDate: String?
    var surveyReference: String?
    var reportUrl: String?
    var siteCheck: String?
    
    var siteId: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        checkId <- map["checkId"]
        surveyCompany <- map["surveyCompany"]
        ukasLab <- map["ukasLab"]
        reportDate <- map["reportDate"]
        surveyReference <- map["surveyReference"]
        reportUrl <- map["reportUrl"]
        siteCheck <- map["siteCheck"]
        
        siteId <- map["siteId"]
    }
    
}

class SiteCheckAssessment: Mappable {
    var assessmentId: Int?
    var checkId: Int?
    var status: String?
    var totalRisks: Int?
    var siteCheck: String?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        assessmentId <- map["assessmentId"]
        checkId <- map["checkId"]
        status <- map["status"]
        totalRisks <- map["totalRisks"]
        siteCheck <- map["siteCheck"]
    }
    
}

class SiteCheckAssessmentResponse: Mappable {
    
    enum Response: String, CaseIterable {
        case yes = "Yes"
        case no = "No"
    }
    
    enum Status: String, CaseIterable {
        case open = "Open"
        case closed = "Closed"
        
        var textColor: UIColor {
            switch self {
            case .open: return UIColor(appColor: .AmberStatus)
            case .closed: return UIColor(appColor: .GreenStatus)
            }
        }
        
        var bgColor: UIColor {
            switch self {
            case .open: return UIColor(appColor: .AmberStatusBG)
            case .closed: return UIColor(appColor: .GreenStatusBG)
            }
        }
    }
    
    var responseId: Int?
    var checkId: Int?
    var qid: Int?
    var response: Response?
    var position: String?
    var file: String?
    var floor: String?
    var room: String?
    var assets: String?
    var consequence: String?
    var likelihood: String?
    var action: String?
    var responseDate: String?
    var riskType: String?
    var totalRiskScore: Int?
    var status: Status?
    var closedUserId: Int?
    var closedDate: String?
    var siteCheck: String?
    var siteCheckAssessmentQuestions: SiteCheckAssessmentQuestions?
    
    var id: Int?
    var riskFactorId: Int?
    var riskFactor: String?
    var weight: Int?
    var score: Int?
    var observation: String?
    var weightedScore: Int?
    var siteCheckRASurveyRiskFactors: SiteCheckRASurveyRiskFactors?
    
    var faultassets: String?
    
    var siteId: Int?
    
    var selectedFile: FilePickerModel?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        responseId <- map["responseId"]
        checkId <- map["checkId"]
        qid <- map["qid"]
        response <- map["response"]
        position <- map["position"]
        file <- map["file"]
        floor <- map["floor"]
        room <- map["room"]
        assets <- map["assets"]
        consequence <- map["consequence"]
        likelihood <- map["likelihood"]
        action <- map["action"]
        responseDate <- map["responseDate"]
        riskType <- map["riskType"]
        totalRiskScore <- map["totalRiskScore"]
        status <- map["status"]
        closedUserId <- map["closedUserId"]
        closedDate <- map["closedDate"]
        siteCheck <- map["siteCheck"]
        siteCheckAssessmentQuestions <- map["siteCheckAssessmentQuestions"]
        
        id <- map["id"]
        riskFactorId <- map["riskFactorId"]
        riskFactor <- map["riskFactor"]
        weight <- map["weight"]
        score <- map["score"]
        observation <- map["observation"]
        weightedScore <- map["weightedScore"]
        siteCheckRASurveyRiskFactors <- map["siteCheckRASurveyRiskFactors"]
        faultassets <- map["faultassets"]
        
        siteId <- map["siteId"]
    }
    
}

class SiteCheckAssessmentQuestions: Mappable {
    var qid: Int?
    var question: String?
    var category: String?
    var assetCategory: String?
    var order: String?
    
    var status: String?
    var completed: Bool?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        qid <- map["qid"]
        question <- map["question"]
        category <- map["category"]
        assetCategory <- map["assetCategory"]
        order <- map["order"]
    }
    
}

class SiteCheckRASurveyRiskFactors: Mappable {
    var riskFactorID: Int?
    var riskFactor: String?
    var weight: Int?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        riskFactorID <- map["riskFactorID"]
        riskFactor <- map["riskFactor"]
        weight <- map["weight"]
    }
    
}

class SiteCheckWaterOutletTemp: Mappable {
    
    enum UsageFrequency: String, CaseIterable {
        case None, Daily, Weekly, Monthly, Yearly
    }
    
    var id: Int?
    var checkId: Int?
    var assetId: Int?
    var assetName: String?
    var outletType: String?
    var temperature: String?
    var normalRunTime: String?
    var usageFrequency: UsageFrequency?
    var position: String?
    var floor: String?
    var room: String?
    var reading1: Int?
    var r1Date: String?
    var reading2: Int?
    var r2Date: String?
    var reading3: Int?
    var r3Date: String?
    var siteCheck: String?
    
    var update: Bool?
    var status: String?
    
    var isEditing: Bool?
    var isForAddNew: Bool?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        checkId <- map["checkId"]
        assetId <- map["assetId"]
        assetName <- map["assetName"]
        outletType <- map["outletType"]
        temperature <- map["temperature"]
        normalRunTime <- map["normalRunTime"]
        usageFrequency <- map["usageFrequency"]
        position <- map["position"]
        floor <- map["floor"]
        room <- map["room"]
        reading1 <- map["reading1"]
        r1Date <- map["r1Date"]
        reading2 <- map["reading2"]
        r2Date <- map["r2Date"]
        reading3 <- map["reading3"]
        r3Date <- map["r3Date"]
        siteCheck <- map["siteCheck"]
        
        update <- map["update"]
        status <- map["status"]
    }
    
}

class SiteCheckWaterTank: Mappable {
    var id: Int?
    var checkId: Int?
    var floor: String?
    var room: String?
    var orientation: String?
    var internalExternal: String?
    var systemFed: String?
    var turnoverTime: String?
    var volume: String?
    var q1: String?
    var q2: String?
    var q3: String?
    var q4: String?
    var q5: String?
    var q6: String?
    var q7: String?
    var status: String?
    var siteCheck: String?

    init() { }
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        checkId <- map["checkId"]
        floor <- map["floor"]
        room <- map["room"]
        orientation <- map["orientation"]
        internalExternal <- map["internalExternal"]
        systemFed <- map["systemFed"]
        turnoverTime <- map["turnoverTime"]
        volume <- map["volume"]
        q1 <- map["q1"]
        q2 <- map["q2"]
        q3 <- map["q3"]
        q4 <- map["q4"]
        q5 <- map["q5"]
        q6 <- map["q6"]
        q7 <- map["q7"]
        status <- map["status"]
        siteCheck <- map["siteCheck"]
    }
}
