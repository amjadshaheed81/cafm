//
//  ApiHelper.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import Foundation
import Alamofire
import ObjectMapper

enum ResponseResult<T> {
    case single(T)
    case array([T])
}

enum ApiService {
    
    case loginApi(model: LoginRequestModel)
    case resetPasswordAPI(model: ResetPasswordRequest)
    case siteAllDetails(sort: String?, sortName: String?)
    case siteDetailsRiskData
    case projectContractsAPI(siteId: Int)
    case actionSummaryAPI(siteId: Int)
    case userCalendarEventsAPI(userId: String?, siteId: String?)
    case putUserCalendarAPI(model: CalendarEvent)
    case userDetailsAPI(userId: Int)
    case siteCheckSiteAPI(siteId: Int)
    case siteCheckAllAPI
    case put_siteCheckBy(checkId: Int, model: SiteCheckModel)
    case get_siteCheckBy(checkId: Int)
    case delete_siteCheckBy(checkId: Int)
    case post_siteCheckBy(model: SiteCheckModel)
    case getSiteCheckFileSASToken
    case getSiteCheckInspectionFaultBy(checkId: Int)
    case getSiteCheckInspectionBy(checkId: Int)
    case postSiteCheckFileUpload
    case postSiteCheckInspectionFault(model: InspectionFaultModel)
    case postSiteCheckInspection(model: SiteCheckInspectionModel)
    case getSiteCheckAssessmentQuestions(category: AssessmentQuestionsCategoryEnum)
    case getSiteCheckAssessmentResponseBy(checkId: Int)
    case postSiteCheckAssessmentResponse(model: SiteCheckAssessmentResponse)
    case getSiteCheckAuditBy(checkId: Int)
    case postSiteCheckAudit(model: InspectionFaultModel)
    case getSiteCheckAsbestosSurveyBy(checkId: Int)
    case postSiteCheckAsbestosSurvey(model: SiteCheckAsbestosSurvey)
    case getSiteCheckAsbestosSampleBy(checkId: Int)
    case postSiteCheckAsbestosSample(model: SiteCheckAsbestosSample)
    case getSiteCheckRASurveyRiskFactors
    case getSiteCheckDomesticRASurveyBy(checkId: Int)
    case postSiteCheckDomesticRASurvey(model: SiteCheckAssessmentResponse)
    case getSiteCheckWaterOutletTempBy(checkId: Int)
    case postSiteCheckWaterOutletTemp(model: SiteCheckWaterOutletTemp)
    case getSiteCheckTankBy(checkId: Int)
    case postSiteCheckTank(model: SiteCheckWaterTank)
    case getAllUserData
    case getAllUserDataBy(userRole: UserEnum)
    case getAllUserBy(siteId: Int)
    case getAllUserByUserType(userType: String)
    case userManageAPI(userModel: User)
    case getAllCompanies
    case getAllAction(area: String?)
    case siteActionsAPI(siteId: Int)
    case siteActionsPUTapi(siteModel: ActionModel)
    case getSearchAddressAPI(searchText: String)
    case getSearchResultAddressAPI(searchText: String)
    case newUserAdd(userModel: AddUserRequet)
    case createSite(userModel: CreateSiteRequestModel)
    case updateSite(userModel: CreateSiteRequestModel)
    case deleteUser(userId: Int)
    case createFolder(folder: CreateFolderReq)
    case folders(id:Int)
    case uploadFileInFolder
    case uploadFileNewVersion
    case updateKeyContactAPI(models: [GetKeyContactsDetailResponse])
    case getKeyContactsDetail(userId: Int)
    case updateLocalDetails(userModel: UpdateCreateSiteLocalDetailsRequestModel)
    case updateTimingAPI(userModel: SiteScheduleRequestModel)
    case deleteSiteImage(userId: Int)
    case uploadSiteImageData(userId: Int)
    case deleteSiteDetails(userId: Int)
    case getAllSiteDetailsBySiteID(userId: Int)
    case siteLayoutAPI(siteId: Int)
    case siteSaveMarkerAPI(siteId: Int)
    case saveSiteMarkerAPI(model: MarkerModel)
    case siteCreateNode(node: SiteLayoutModel)
    case siteUploadFloorPlan
    case getSiteSiteInfo(siteId: Int, query: String)
    case siteSiteInfo(model: SiteInformationModel?)
    case siteSiteAreaInfo(model: SiteInformationModel?)
    case siteSiteSecurityInfo(model: SiteInformationModel?)
    case siteSiteUtilityInfo(model: SiteInformationModel?)
    case siteSiteLiftInfo(model: SiteInformationModel?)
    case siteSiteLandscapeInfo(model: SiteInformationModel?)
    case versionHistoryOFFile(id: Int)
    case deleteFile(id: Int)
    case deletekeyContacts(id: Int)
    case siteAssetsCategory
    case cloneAssets(assetId: Int, numberOfClone: Int)
    case getRegistedAssetDetail(model: AssetRegisterData)
    case deleteSiteAssets(id: Int)
    case documentSiteParentFoldersAPI(siteId: Int)
    case siteAssetsAPI(siteId: Int)
    case siteAllWithDetails(withDetails: Bool?)
    case lovAPI(lovType: LOVTypeEnum, desc: String? = nil, filter1: String? = nil)
    case put_siteAssetsAPI(siteId: Int)
    case siteAssetsDetails(assetId: Int)
    case put_siteAssetsDetails(assetId: Int)
    case put_siteAssets_patDetails(assetId: Int, model: PATDetailsRequest)
    case put_siteAssets_pspDetails(assetId: Int, model: AssetPFPItem)
    case put_siteAssets_doorSpecification(assetId: Int, model: AssetDoorSpecifications)
    case documnetFileMove(folderId: Int, fileID: Int)
    case documnetFileCopy(folderId: Int, fileID: Int)
    case searchApiForDocumnet(query: String)
    case getProjectContractsCategory
    case getProjectContractSubCategory
    case getUserRole(userRole: UserEnum, siteId: Int)
    case contractsManageAPI(model: ContractDetailsModel)
    case updateContractsManageAPI(model: [ContractDetailsModel])
    case contractsFolderAPI(projectContractId : Int, model: FolderRequest)
    case contractsAssetsAPI(projectContractId : Int, model: AssetRequest)
    case contractsVisitAPI(model: ScheduleRequest)
    case contractsCalenderAPI(model: CalenderEventRequest)
    case getProjectContractDetails(projectId: Int)
    case deleteScheduleVisitAPI(scheduleId: Int)
    case terminateContract(projectId: Int)
    case statutoryRegister(siteId: Int)
    case statutoryRegisterAll
    case contracterContractsDetails(contractId: Int)
    case getSelectedSiteContractDetails(siteId: Int?, contractId: Int?, area: String?)
    case userManagerAddSite(userID: Int, addedSites: [Int], removedSites: [Int])
    case resetPassWordFromHome(userId: Int, password: String)
    case manageStatutoryRegister(model: StatutoryModel)
    case energyCostCategory
    case siteEnergyCostDetails(siteId: Int)
    case energySurveyAll
    case getPreActionSummaryDetail(taggedSiteId: Int)
    case deletePreAction(actionId: Int)
    case createPreAction(actionId: Int)
    case deleteEnegySubCoste(costId: Int)
    case deleteEnegySubReading(readingId: Int)
    case closePreAction(actionId: Int)
    case pendingPreAction(actionId: Int, model: StatusModel)
    case approvePreAction(model: ClientAction)
    case dropDownTyprList
    case dropDownList(catType: String)
    case deleteDropDownValue(id: Int)
    case addnewValueDropDown(item: DropDownSubCategory)
    case editValueDropDown(id: Int,item: DropDownSubCategory)
    case addNewDropDown(item: DropDownSubCategory)
    case createNewEnrReading(item: ReqEnrAndCostModel)
    case deleteEnergyServay(id: Int)
    case addNewCostInreading(item: EnergyUsage)
    case addRedingInreading(item: ReqEnergyReading)
    case manageCompanyAPI(model: CompanyDetails)
    case deleteCompanyAPI(id: Int)
    case getSiteActionsDetailsFromIDAPI(id: Int)
    case addComments(model: AddCommentsRequestModel)
    case getActionComment(id: Int)
    case uploadAction(model: ActionResponseModel)
    case getSITE_CHECK_TYPE
    case getSITE_CHECK_SUB_TYPE
    case getSITE_CHECK_CATEGORY
    case getSiteAssetsAllV2(area: String?, fromDate: String?, toDate: String?, siteId: Int?)
    
    static let baseApi = "https://property.unitetheunion.org"
    
    func api() -> String {
        switch self {
        case .loginApi(model: let model):
            return ApiService.baseApi+"/api/user/login"
        case .siteAllDetails(sort: let sort, sortName: let sortName):
            let api = ApiService.baseApi+"/api/site/site/all"
            return apiWithQueryParameters(string: api, queryItems: [
                URLQueryItem(name: "sort", value: sort),
                URLQueryItem(name: "sortName", value: sortName),
            ])
        case .siteDetailsRiskData:
            return ApiService.baseApi+"/api/site-check/risks"
        case .projectContractsAPI(let siteId):
            return ApiService.baseApi+"/api/project/contracts?siteId=\(siteId)"
        case .actionSummaryAPI(let siteId):
            return ApiService.baseApi+"/api/action/\(siteId)/summary"
        case .userCalendarEventsAPI(userId: let userId, siteId: let siteId):
            var api = ApiService.baseApi+"/api/user/calendar/events"
            if let userId { api += "?userId=\(userId)" }
            if let siteId { api += "??siteId=\(siteId)" }
            return api
        case .putUserCalendarAPI(model: let model):
            return ApiService.baseApi+"/api/user/calendar"
        case .userDetailsAPI(let userId):
            return ApiService.baseApi+"/api/user/\(userId)/details"
        case .siteCheckSiteAPI(let siteId):
            return ApiService.baseApi+"/api/site-check/site/\(siteId)"
        case .siteCheckAllAPI:
            return ApiService.baseApi+"/api/site-check/all"
        case .put_siteCheckBy(checkId: let checkId, model: let model):
            return ApiService.baseApi+"/api/site-check/\(checkId)"
        case .get_siteCheckBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/check-id/\(checkId)"
        case .delete_siteCheckBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/check-id/\(checkId)"
        case .post_siteCheckBy(model: let model):
            return ApiService.baseApi+"/api/site-check/"
        case .getSiteCheckFileSASToken:
            return ApiService.baseApi+"/api/site-check/file/sas-token"
        case .getSiteCheckInspectionFaultBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/inspection/fault/\(checkId)"
        case .getSiteCheckInspectionBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/inspection/\(checkId)"
        case .postSiteCheckFileUpload:
            return ApiService.baseApi+"/api/site-check/file/upload"
        case .postSiteCheckInspectionFault(model: let model):
            return ApiService.baseApi+"/api/site-check/inspection/fault"
        case .postSiteCheckInspection(model: let model):
            return ApiService.baseApi+"/api/site-check/inspection"
        case .getSiteCheckAssessmentQuestions(category: let category):
            return ApiService.baseApi+"/api/site-check/assessment/questions/\(category.rawValue)"
        case .getSiteCheckAssessmentResponseBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/assessment/response/\(checkId)"
        case .postSiteCheckAssessmentResponse(model: let model):
            return ApiService.baseApi+"/api/site-check/assessment/response"
        case .getSiteCheckAuditBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/audit/\(checkId)"
        case .postSiteCheckAudit(model: let model):
            return ApiService.baseApi+"/api/site-check/audit"
        case .getSiteCheckAsbestosSurveyBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/asbestos-survey/\(checkId)"
        case .postSiteCheckAsbestosSurvey(model: let model):
            return ApiService.baseApi+"/api/site-check/asbestos-survey"
        case .getSiteCheckAsbestosSampleBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/asbestos-sample/\(checkId)"
        case .postSiteCheckAsbestosSample(model: let model):
            return ApiService.baseApi+"/api/site-check/asbestos-sample"
        case .getSiteCheckRASurveyRiskFactors:
            return ApiService.baseApi+"/api/site-check/ra-survey-risk-factors"
        case .getSiteCheckDomesticRASurveyBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/domestic-ra-survey/\(checkId)"
        case .postSiteCheckDomesticRASurvey(model: let model):
            return ApiService.baseApi+"/api/site-check/domestic-ra-survey"
        case .getSiteCheckWaterOutletTempBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/water-outlet-temp/\(checkId)"
        case .postSiteCheckWaterOutletTemp(model: let model):
            return ApiService.baseApi+"/api/site-check/water-outlet-temp"
        case .getSiteCheckTankBy(checkId: let checkId):
            return ApiService.baseApi+"/api/site-check/tank/\(checkId)"
        case .postSiteCheckTank(model: let model):
            return ApiService.baseApi+"/api/site-check/tank"
        case .getAllUserData:
            return ApiService.baseApi+"/api/user/all"
        case .getAllUserBy(siteId: let siteId):
            return ApiService.baseApi+"/api/user/all?siteId=\(siteId)"
        case .getAllUserByUserType(userType: let userType):
            return ApiService.baseApi+"/api/user/all?userType=\(userType)"
        case .userManageAPI:
            return ApiService.baseApi+"/api/user/manage"
        case .getAllCompanies:
            return ApiService.baseApi+"/api/companies/all"
        case .getAllAction(area: let area):
            let api = ApiService.baseApi+"/api/site/actions/all"
            return apiWithQueryParameters(string: api, queryItems: [
                URLQueryItem(name: "area", value: area),
            ])
        case .siteActionsAPI(let siteId):
            return ApiService.baseApi+"/api/site/actions/\(siteId)"
        case .siteActionsPUTapi:
            return ApiService.baseApi+"/api/site/actions"
        case .getSearchAddressAPI(let searchText):
            return "https://api.getaddress.io/autocomplete/\(searchText)?api-key=pdSw7G1TEk6kghR1DNzddQ41182&all=true"
        case .getSearchResultAddressAPI(searchText: let searchText):
            return "https://api.getaddress.io/get/\(searchText)?api-key=pdSw7G1TEk6kghR1DNzddQ41182&all=true"
        case .newUserAdd:
            return ApiService.baseApi+"/api/user/manage"
        case .createSite(userModel: let userModel):
            return ApiService.baseApi+"/api/site/site"
        case .deleteUser(let userId):
            return ApiService.baseApi+"/api/user/\(userId)/delete"
        case .folders(id: let id):
            return ApiService.baseApi+"/api/document/parent/\(id)/folders"
        case .createFolder(folder: let folder):
            return ApiService.baseApi+"/api/document/folder"
        case .updateKeyContactAPI(models: let models):
            return ApiService.baseApi+"/api/site/updateKeyContacts"
        case .getKeyContactsDetail(userId: let userId):
            return ApiService.baseApi+"/api/site/keyContacts/\(userId)"
        case .updateLocalDetails(userModel: let userModel):
            return ApiService.baseApi+"/api/site/updateLocalDetails"
        case .updateTimingAPI(userModel: let userModel):
            return ApiService.baseApi+"/api/site/updateTimings"
        case .deleteSiteImage(let userId):
            return ApiService.baseApi+"/api/site/site/\(userId)/delete"
        case .uploadSiteImageData(let userId):
            return ApiService.baseApi+"/api/site/site/\(userId)/upload"
        case .updateSite(userModel: let userModel):
            return ApiService.baseApi+"/api/site/updateSite"
        case .deleteSiteDetails(userId: let userId):
            return ApiService.baseApi+"/api/site/site/\(userId)"
        case .getAllSiteDetailsBySiteID(userId: let userId):
            return ApiService.baseApi+"/api/site/site/\(userId)"
        case .siteLayoutAPI(let siteId):
            return ApiService.baseApi+"/api/site/layout/\(siteId)"
        case .siteSaveMarkerAPI(siteId: let siteId):
            return ApiService.baseApi+"/api/site/SaveMarker/\(siteId)"
        case .saveSiteMarkerAPI(model: let model):
            return ApiService.baseApi+"/api/site/SaveMarker"
        case .siteCreateNode:
            return ApiService.baseApi+"/api/site/createNode"
        case .siteUploadFloorPlan:
            return ApiService.baseApi+"/api/site/uploadfloorplan"
        case .getSiteSiteInfo(siteId: let siteId, query: let query):
            return ApiService.baseApi+"/api/site/siteinfo/\(siteId)?q=\(query)"
        case .siteSiteInfo(model: let model):
            return ApiService.baseApi+"/api/site/siteinfo"
        case .siteSiteAreaInfo(model: let model):
            return ApiService.baseApi+"/api/site/siteareainfo"
        case .siteSiteSecurityInfo(model: let model):
            return ApiService.baseApi+"/api/site/sitesecurityinfo"
        case .siteSiteUtilityInfo(model: let model):
            return ApiService.baseApi+"/api/site/siteutilityinfo"
        case .siteSiteLiftInfo(model: let model):
            return ApiService.baseApi+"/api/site/siteliftsinfo"
        case .siteSiteLandscapeInfo(model: let model):
            return ApiService.baseApi+"/api/site/sitelandscapeinfo"
        case .uploadFileInFolder:
            return ApiService.baseApi+"/api/document/files/upload"
        case .versionHistoryOFFile(id: let id):
            return ApiService.baseApi+"/api/document/file/\(id)/history"
        case .deleteFile(id: let id):
            return ApiService.baseApi+"/api/document/file/\(id)/delete"
        case .uploadFileNewVersion:
            return ApiService.baseApi+"/api/document/file/newVersion/upload"
        case .deletekeyContacts(id: let id):
            return ApiService.baseApi+"/api/site/keyContacts/\(id)"
        case .siteAssetsCategory:
            return ApiService.baseApi+"/api/lov/ASSET_CATEGORY"
        case .cloneAssets(assetId: let assetId, numberOfClone: let numberOfClone):
            return ApiService.baseApi+"/api/site/assets/clone/\(assetId)/\(numberOfClone)"
        case .getRegistedAssetDetail(model: let model):
            return model.url()
        case .deleteSiteAssets(id: let id):
            return ApiService.baseApi+"/api/site/assets/\(id)"
        case .documentSiteParentFoldersAPI(siteId: let siteId):
            return ApiService.baseApi+"/api/document/site/\(siteId)/parent/folders"
        case .siteAssetsAPI(siteId: let siteId):
            return ApiService.baseApi+"/api/site/\(siteId)/assets"
        case .siteAllWithDetails(withDetails: let withDetails):
            let api = ApiService.baseApi+"/api/site/site/all"
            return apiWithQueryParameters(string: api, queryItems: [
                URLQueryItem(name: "withDetails", value: withDetails?.stringValue),
            ])
        case .lovAPI(lovType: let lovType, desc: let desc, filter1: let filter1):
            if let desc, let filter1 {
                return ApiService.baseApi+"/api/lov/\(lovType.rawValue)?desc=\(desc)&filter1=\(filter1)"
            }else if let desc {
                return ApiService.baseApi+"/api/lov/\(lovType.rawValue)?desc=\(desc)"
            }else if let filter1 {
                return ApiService.baseApi+"/api/lov/\(lovType.rawValue)?filter1=\(filter1)"
            }else {
                return ApiService.baseApi+"/api/lov/\(lovType.rawValue)"
            }
        case .put_siteAssetsAPI(siteId: let siteId):
            return ApiService.baseApi+"/api/site/\(siteId)/assets"
        case .siteAssetsDetails(assetId: let assetId):
            return ApiService.baseApi+"/api/site/assets/\(assetId)/details"
        case .documnetFileMove(folderId: let folderId, fileID: let fileID):
            return ApiService.baseApi+"/api/document/file/\(fileID)/move/\(folderId)"
        case .documnetFileCopy(folderId: let folderId, fileID: let fileID):
            return ApiService.baseApi+"/api/document/file/\(fileID)/copy/\(folderId)"
        case .searchApiForDocumnet(query: let query):
            return ApiService.baseApi+"/api/document/file/search?q=\(query)&siteId=\(UserConstants.shared.selectedSiteID ?? 0)"
        case .put_siteAssetsDetails(assetId: let assetId):
            return ApiService.baseApi+"/api/site/assets/\(assetId)/details"
        case .put_siteAssets_patDetails(assetId: let assetId, model: let model):
            return ApiService.baseApi+"/api/site/assets/\(assetId)/patDetails"
        case .put_siteAssets_pspDetails(assetId: let assetId, model: let model):
            return ApiService.baseApi+"/api/site/assets/\(assetId)/pspDetails"
        case .put_siteAssets_doorSpecification(assetId: let assetId, model: let model):
            return ApiService.baseApi+"/api/site/assets/\(assetId)/doorSpecification"
        case .getAllUserDataBy(userRole: let userRole):
            return ApiService.baseApi+"/api/user/all?userRole=\(userRole.rawValue)"
        case .getProjectContractsCategory:
            return ApiService.baseApi+"/api/lov/PROJECT_CONTRACT_CATEGORY"
        case .getProjectContractSubCategory:
            return ApiService.baseApi+"/api/lov/PROJECT_CONTRACT_SUB_CATEGORY"
        case .getUserRole(userRole: let userRole, let siteId):
            return ApiService.baseApi+"/api/user/all?userRole=\(userRole.rawValue)&siteId=\(siteId)"
        case .contractsFolderAPI(let projectContractId, model: _):
            return ApiService.baseApi+"/api/project/\(projectContractId)/folders"
        case .contractsAssetsAPI(projectContractId: let projectContractId, model: _):
            return ApiService.baseApi+"/api/project/\(projectContractId)/assets"
        case .contractsVisitAPI(model: let model):
            return ApiService.baseApi+"/api/project/visits"
        case .contractsCalenderAPI(model: let model):
            return ApiService.baseApi+"/api/user/calendar"
        case .contractsManageAPI(model: let model):
            return ApiService.baseApi+"/api/project/manage"
        case .getProjectContractDetails(projectId: let projectId):
            return ApiService.baseApi+"/api/project/\(projectId)/details"
        case .deleteScheduleVisitAPI(scheduleId: let scheduleId):
            return ApiService.baseApi+"/api/project/\(scheduleId)/delete"
        case .updateContractsManageAPI(model: let model):
            return ApiService.baseApi+"/api/project/manage"
        case .terminateContract(projectId: let projectId):
            return ApiService.baseApi+"/api/project/\(projectId)/terminate"
        case .statutoryRegister(siteId: let siteId):
            return ApiService.baseApi+"/api/document/\(siteId)/statutoryRegister"
        case .statutoryRegisterAll:
            return ApiService.baseApi+"/api/document/statutoryRegister/all"
        case .contracterContractsDetails(contractId: let contractId):
            return ApiService.baseApi+"/api/project/contracts?contractorCompanyId=\(contractId)"
        case .getSelectedSiteContractDetails(siteId: let siteId, contractId: let contractId, area: let area):
            let api = ApiService.baseApi+"/api/project/contracts"
            if let area {
                return apiWithQueryParameters(string: api, queryItems: [
                    URLQueryItem(name: "area", value: area),
                    URLQueryItem(name: "contractorCompanyId", value: contractId?.stringValue),
                ])
            }else {
                return apiWithQueryParameters(string: api, queryItems: [
                    URLQueryItem(name: "siteId", value: siteId?.stringValue),
                    URLQueryItem(name: "contractorCompanyId", value: contractId?.stringValue),
                ])
            }
        case .userManagerAddSite(userID: let userID, addedSites: let addedSites, removedSites: let removedSites):
            return ApiService.baseApi+"/api/user/\(userID)/site/manage"
        case .resetPassWordFromHome(userId: let userId, password: let password):
            return ApiService.baseApi+"/api/user/password"
        case .manageStatutoryRegister(model: let model):
            return ApiService.baseApi+"/api/document/statutoryRegister/manage"
        case .energyCostCategory:
            return ApiService.baseApi+"/api/lov/ENERGY_COST_BUDGET_CATEGORY"
        case .siteEnergyCostDetails(siteId: let siteId):
            return ApiService.baseApi+"/api/energy/site/survey/\(siteId)"
        case .energySurveyAll:
            return ApiService.baseApi+"/api/energy/survey/all"
        case .getPreActionSummaryDetail(taggedSiteId: let taggedSiteId):
            return ApiService.baseApi+"/api/action/\(taggedSiteId)/summary"
        case .deletePreAction(actionId: let actionId):
            return ApiService.baseApi+"/api/action/\(actionId)/delete"
        case .createPreAction(actionId: let actionId):
            return ApiService.baseApi+"/api/action/\(actionId)/actions"
        case .deleteEnegySubCoste(costId: let costId):
            return ApiService.baseApi+"/api/energy/cost/\(costId)"
        case .deleteEnegySubReading(readingId: let readingId):
            return ApiService.baseApi+"/api/energy/reading/\(readingId)"
        case .closePreAction(actionId: let actionId):
            return ApiService.baseApi+"/api/action/\(actionId)/close"
        case .pendingPreAction(actionId: let actionId, model: let model):
            return ApiService.baseApi+"/api/action/\(actionId)/approve"
        case .approvePreAction(model: let model):
            return ApiService.baseApi+"/api/site/actions"
        case .dropDownTyprList:
            return ApiService.baseApi+"/api/lov/lov-types?"
        case .dropDownList(catType: let catType):
            return ApiService.baseApi+"/api/lov/\(catType)"
        case .deleteDropDownValue(id: let id):
            return ApiService.baseApi+"/api/lov/\(id)"
        case .addnewValueDropDown(item: let item):
            return ApiService.baseApi+"/api/lov/"
        case .editValueDropDown(id: let id, item: let item):
            return ApiService.baseApi+"/api/lov/id/\(id)"
        case .addNewDropDown(item: let item):
            return ApiService.baseApi+"/api/lov/"
        case .createNewEnrReading(item: let item):
            return ApiService.baseApi+"/api/energy/survey"
        case .deleteEnergyServay(id: let id):
            return ApiService.baseApi+"/api/energy/survey/\(id)"
        case .addNewCostInreading(item: let item):
            return ApiService.baseApi+"/api/energy/cost"
        case .addRedingInreading(item: let item):
            return ApiService.baseApi+"/api/energy/reading"
        case .resetPasswordAPI(model: let model):
            return ApiService.baseApi+"/api/user/reset-password"
        case .manageCompanyAPI(model: let model):
            return ApiService.baseApi+"/api/companies/manage"
        case .deleteCompanyAPI(id: let id):
            return ApiService.baseApi+"/api/companies/\(id)/delete"
        case .getSiteActionsDetailsFromIDAPI(id: let id):
            return ApiService.baseApi+"/api/site/actions/id/\(id)"
        case .addComments(model: let model):
            return ApiService.baseApi+"/api/site/actions/comments"
        case .getActionComment(id: let id):
            return ApiService.baseApi+"/api/site/actions/comments/\(id)"
        case .uploadAction(model: let model):
            return ApiService.baseApi+"/api/site/actions"
        case .getSITE_CHECK_TYPE:
            return ApiService.baseApi+"/api/lov/SITE_CHECK_TYPE"
        case .getSITE_CHECK_SUB_TYPE:
            return ApiService.baseApi+"/api/lov/SITE_CHECK_SUB_TYPE"
        case .getSITE_CHECK_CATEGORY:
            return ApiService.baseApi+"/api/lov/SITE_CHECK_CATEGORY"
        case .addNewCostInreading(item: let item):
            return ApiService.baseApi+"/api/energy/cost"
        case .addRedingInreading(item: let item):
            return ApiService.baseApi+"/api/energy/reading"
        case .getSiteAssetsAllV2(area: let area, fromDate: let fromDate, toDate: let toDate, siteId: let siteId):
            let api = ApiService.baseApi+"/api/site/assets/all/v2"
            if let area {
                return apiWithQueryParameters(string: api, queryItems: [
                    URLQueryItem(name: "area", value: area),
                    URLQueryItem(name: "fromDate", value: fromDate),
                    URLQueryItem(name: "toDate", value: toDate),
                ])
            }else if let siteId {
                return apiWithQueryParameters(string: api, queryItems: [
                    URLQueryItem(name: "siteId", value: siteId.stringValue),
                    URLQueryItem(name: "fromDate", value: fromDate),
                    URLQueryItem(name: "toDate", value: toDate),
                ])
            }else {
                return apiWithQueryParameters(string: api, queryItems: [
                    URLQueryItem(name: "fromDate", value: fromDate),
                    URLQueryItem(name: "toDate", value: toDate),
                ])
            }
        }
    }
    
    func method() -> HTTPMethod{
        switch self {
        case .projectContractsAPI, .actionSummaryAPI, .userCalendarEventsAPI, .userDetailsAPI, .siteCheckSiteAPI, .siteCheckAllAPI, .siteAllDetails, .siteDetailsRiskData, .getAllUserData, .siteActionsAPI, .getAllCompanies, .siteLayoutAPI, .getSearchAddressAPI, .getSearchResultAddressAPI, .getSiteSiteInfo, .folders, .getKeyContactsDetail(userId: _), .siteAssetsCategory:
            return .get
        case .siteSaveMarkerAPI(siteId: let siteId):
            return .get
        case .saveSiteMarkerAPI(model: let model):
            return .put
        case .getAllAction(area: let area):
            return .get
        case .loginApi(model: let model):
            return .post
        case .putUserCalendarAPI(model: let model):
            return .put
        case .put_siteCheckBy(checkId: let checkId, model: let model):
            return .put
        case .get_siteCheckBy(checkId: let checkId):
            return .get
        case .delete_siteCheckBy(checkId: let checkId):
            return .delete
        case .post_siteCheckBy(model: let model):
            return .post
        case .getSiteCheckFileSASToken:
            return .get
        case .getSiteCheckInspectionFaultBy(checkId: let checkId):
            return .get
        case .getSiteCheckInspectionBy(checkId: let checkId):
            return .get
        case .postSiteCheckFileUpload:
            return .post
        case .postSiteCheckInspectionFault(model: let model):
            return .post
        case .postSiteCheckInspection(model: let model):
            return .post
        case .getSiteCheckAssessmentQuestions(category: let category):
            return .get
        case .getSiteCheckAssessmentResponseBy(checkId: let checkId):
            return .get
        case .postSiteCheckAssessmentResponse(model: let model):
            return .post
        case .getSiteCheckAuditBy(checkId: let checkId):
            return .get
        case .postSiteCheckAudit(model: let model):
            return .post
        case .getSiteCheckAsbestosSurveyBy(checkId: let checkId):
            return .get
        case .postSiteCheckAsbestosSurvey(model: let model):
            return .post
        case .getSiteCheckAsbestosSampleBy(checkId: let checkId):
            return .get
        case .postSiteCheckAsbestosSample(model: let model):
            return .post
        case .getSiteCheckRASurveyRiskFactors:
            return .get
        case .getSiteCheckDomesticRASurveyBy(checkId: let checkId):
            return .get
        case .postSiteCheckDomesticRASurvey(model: let model):
            return .post
        case .getSiteCheckWaterOutletTempBy(checkId: let checkId):
            return .get
        case .postSiteCheckWaterOutletTemp(model: let model):
            return .post
        case .getSiteCheckTankBy(checkId: let checkId):
            return .get
        case .postSiteCheckTank(model: let model):
            return .post
        case .getAllUserBy(siteId: let siteId):
            return .get
        case .getAllUserByUserType(userType: let userType):
            return .get
        case .userManageAPI, .newUserAdd, .siteActionsPUTapi:
            return .put
        case .getSearchAddressAPI(searchText: let searchText), .getSearchResultAddressAPI(searchText: let searchText):
            return .get
        case .createSite(userModel: let userModel):
            return .post
        case .deleteUser:
            return .delete
        case .createFolder(folder: let folder):
            return .post
        case .updateKeyContactAPI(models: _):
            return .put
        case .updateLocalDetails(userModel: _):
            return .put
        case .updateTimingAPI(userModel: _):
            return .put
        case .deleteSiteImage(userId: _):
            return .delete
        case .uploadSiteImageData(userId: _):
            return .post
        case .updateSite(userModel: let userModel):
            return .put
        case .deleteSiteDetails(userId: let userId):
            return .delete
        case .getAllSiteDetailsBySiteID(userId: let userId):
            return .get
        case .createSite, .siteCreateNode, .siteUploadFloorPlan,  .siteSiteInfo, .siteSiteAreaInfo, .siteSiteSecurityInfo, .siteSiteUtilityInfo, .siteSiteLiftInfo, .siteSiteLandscapeInfo:
            return .post
        case .deleteUser:
            return .delete
        case .uploadFileInFolder:
            return .post
        case .versionHistoryOFFile(id: let id):
            return .get
        case .deleteFile(id: let id), .deletekeyContacts(id: let id):
            return .delete
        case .uploadFileNewVersion:
            return .put
        case .cloneAssets(assetId: _, numberOfClone: _):
            return .get
        case .getRegistedAssetDetail(model: let model):
            return .get
        case .deleteSiteAssets(id: let id):
            return .delete
        case .documentSiteParentFoldersAPI(siteId: let siteId):
            return .get
        case .siteAssetsAPI(siteId: let siteId):
            return .get
        case .siteAllWithDetails(withDetails: let withDetails):
            return .get
        case .lovAPI(lovType: let lovType, desc: let desc, filter1: let filter1):
            return .get
        case .put_siteAssetsAPI(siteId: let siteId):
            return .put
        case .siteAssetsDetails(assetId: let assetId):
            return .get
        case .documnetFileMove, .documnetFileCopy:
            return .put
        case .searchApiForDocumnet(query: let query):
            return .get
        case .put_siteAssetsDetails(assetId: let assetId):
            return .put
        case .put_siteAssets_patDetails(assetId: let assetId, model: let model):
            return .put
        case .put_siteAssets_pspDetails(assetId: let assetId, model: let model):
            return .put
        case .put_siteAssets_doorSpecification(assetId: let assetId, model: let model):
            return .put
        case .getAllUserDataBy(userRole: let userRole):
            return .get
        case .getProjectContractsCategory, .getProjectContractSubCategory:
            return .get
        case .getUserRole(userRole: let userRole, siteId: let siteId):
            return .get
        case .contractsFolderAPI(projectContractId: let projectContractId, model: _):
            return .put
        case .contractsAssetsAPI(projectContractId: let projectContractId, model: _):
            return .put
        case .contractsVisitAPI(model: let model):
            return .put
        case .contractsCalenderAPI(model: let model):
            return .put
        case .contractsManageAPI(model: let model):
            return .put
        case .getProjectContractDetails(projectId: let projectId):
            return .get
        case .deleteScheduleVisitAPI(scheduleId: let scheduleId):
            return .delete
        case .updateContractsManageAPI(model: let model):
            return .put
        case .terminateContract(projectId: let projectId):
            return .get
        case .statutoryRegister(siteId: let siteId):
            return .get
        case .statutoryRegisterAll:
            return .get
        case .contracterContractsDetails(contractId: let contractId):
            return .get
        case .getSelectedSiteContractDetails(siteId: let siteId, contractId: let contractId, area: let area):
            return .get
        case .userManagerAddSite(userID: let userID, addedSites: let addedSites, removedSites: let removedSites):
            return .post
        case .resetPassWordFromHome(userId: let userId, password: let password):
            return .put
        case .manageStatutoryRegister(model: let model):
            return .put
        case .energyCostCategory:
            return .get
        case .siteEnergyCostDetails(siteId: let siteId):
            return .get
        case .energySurveyAll:
            return .get
        case .getPreActionSummaryDetail(taggedSiteId: let taggedSiteId):
            return .get
        case .deletePreAction(actionId: let actionId):
            return .delete
        case .createPreAction(actionId: let actionId):
            return .post
        case .deleteEnegySubCoste(costId: let costId):
            return .delete
        case .deleteEnegySubReading(readingId: let readingId):
            return .delete
        case .closePreAction(actionId: let actionId):
            return .put
        case .pendingPreAction(actionId: let actionId, model: let model):
            return .put
        case .approvePreAction(model: let model):
            return .put
        case .dropDownTyprList:
            return .get
        case .dropDownList(catType: let catType):
            return .get
        case .deleteDropDownValue(id: let id):
            return .delete
        case .addnewValueDropDown(item: let item):
            return .post
        case .editValueDropDown(id: let id, item: let item):
            return .put
        case .addNewDropDown(item: let item):
            return .post
        case .createNewEnrReading(item: let item):
            return .post
        case .deleteEnergyServay(id: let id):
            return .delete
        case .addNewCostInreading(item: let item):
            return .post
        case .addRedingInreading(item: let item):
            return .post
        case .resetPasswordAPI(model: let model):
            return .post
        case .manageCompanyAPI(model: let model):
            return .put
        case .deleteCompanyAPI(id: let id):
            return .delete
        case .getSiteActionsDetailsFromIDAPI(id: let id):
            return .get
        case .addComments(model: let model):
            return .put
        case .getActionComment(id: let id):
            return .get
        case .uploadAction(model: let model):
            return .put
        case .getSITE_CHECK_TYPE, .getSITE_CHECK_SUB_TYPE, .getSITE_CHECK_CATEGORY:
            return .get
        case .addNewCostInreading(item: let item):
            return .post
        case .addRedingInreading(item: let item):
            return .post
        case .getSiteAssetsAllV2(area: let area, fromDate: let fromDate, toDate: let toDate, siteId: let siteId):
            return .get
        }
    }
    
    func parameters() -> [String: Any]? {
        switch self {
        case .projectContractsAPI, .actionSummaryAPI, .userCalendarEventsAPI, .userDetailsAPI, .siteCheckSiteAPI, .siteCheckAllAPI, .siteAllDetails, .siteDetailsRiskData, .getAllUserData, .siteActionsAPI, .getAllCompanies, .siteLayoutAPI, .getSearchAddressAPI, .getSearchResultAddressAPI, .deleteUser, .siteUploadFloorPlan, .getSiteSiteInfo:
            return nil
        case .siteSaveMarkerAPI(siteId: let siteId):
            return nil
        case .saveSiteMarkerAPI(model: let model):
            return model.toJSON()
        case .getAllAction(area: let area):
            return nil
        case .loginApi(model: let model):
            return model.toJSON()
        case .putUserCalendarAPI(model: let model):
            return model.toJSON()
        case .put_siteCheckBy(checkId: let checkId, model: let model):
            return model.toJSON()
        case .get_siteCheckBy(checkId: let checkId):
            return nil
        case .delete_siteCheckBy(checkId: let checkId):
            return nil
        case .post_siteCheckBy(model: let model):
            return model.toJSON()
        case .getSiteCheckFileSASToken:
            return nil
        case .getSiteCheckInspectionFaultBy(checkId: let checkId):
            return nil
        case .getSiteCheckInspectionBy(checkId: let checkId):
            return nil
        case .postSiteCheckFileUpload:
            return nil
        case .postSiteCheckInspectionFault(model: let model):
            return model.toJSON()
        case .postSiteCheckInspection(model: let model):
            return model.toJSON()
        case .getSiteCheckAssessmentQuestions(category: let category):
            return nil
        case .getSiteCheckAssessmentResponseBy(checkId: let checkId):
            return nil
        case .postSiteCheckAssessmentResponse(model: let model):
            return model.toJSON()
        case .getSiteCheckAuditBy(checkId: let checkId):
            return nil
        case .postSiteCheckAudit(model: let model):
            return model.toJSON()
        case .getSiteCheckAsbestosSurveyBy(checkId: let checkId):
            return nil
        case .postSiteCheckAsbestosSurvey(model: let model):
            return model.toJSON()
        case .getSiteCheckAsbestosSampleBy(checkId: let checkId):
            return nil
        case .postSiteCheckAsbestosSample(model: let model):
            return model.toJSON()
        case .getSiteCheckRASurveyRiskFactors:
            return nil
        case .getSiteCheckDomesticRASurveyBy(checkId: let checkId):
            return nil
        case .postSiteCheckDomesticRASurvey(model: let model):
            return model.toJSON()
        case .getSiteCheckWaterOutletTempBy(checkId: let checkId):
            return nil
        case .postSiteCheckWaterOutletTemp(model: let model):
            return model.toJSON()
        case .getSiteCheckTankBy(checkId: let checkId):
            return nil
        case .postSiteCheckTank(model: let model):
            return model.toJSON()
        case .getAllUserBy(siteId: let siteId):
            return nil
        case .getAllUserByUserType(userType: let userType):
            return nil
        case .userManageAPI(let userModel):
            return userModel.toJSON()
        case .newUserAdd(let userModel):
            return userModel.toJSON()
        case .createSite(userModel: let userModel):
            return userModel.toJSON()
        case .siteActionsPUTapi(let siteModel):
            return siteModel.toJSON()
        case .folders:
            return nil
        case .createFolder(folder: let folder):
            return folder.toJSON()
        case .updateKeyContactAPI(models: let models):
            return nil
        case .getKeyContactsDetail(userId: _):
            return nil
        case .updateLocalDetails(userModel: let userModel):
            return userModel.toJSON()
        case .updateTimingAPI(userModel: let userModel):
            return userModel.toJSON()
        case .deleteSiteImage(userId: _):
            return nil
        case .uploadSiteImageData(userId: _):
            return nil
        case .updateSite(userModel: let userModel):
            return userModel.toJSON()
        case .deleteSiteDetails(userId: let userId):
            return nil
        case .getAllSiteDetailsBySiteID(userId: let userId):
            return nil
        case .siteCreateNode(node: let node):
            return node.toJSON()
        case .siteSiteInfo(model: let model):
            return model?.toJSON()
        case .siteSiteAreaInfo(model: let model):
            return model?.toJSON()
        case .siteSiteSecurityInfo(model: let model):
            return model?.toJSON()
        case .siteSiteUtilityInfo(model: let model):
            return model?.toJSON()
        case .siteSiteLiftInfo(model: let model):
            return model?.toJSON()
        case .siteSiteLandscapeInfo(model: let model):
            return model?.toJSON()
        case .uploadFileInFolder:
            return nil
        case .versionHistoryOFFile(id: let id):
            return nil
        case .deleteFile(id: let id):
            return nil
        case .uploadFileNewVersion:
            return nil
        case .deletekeyContacts(id: let id):
            return nil
        case .siteAssetsCategory:
            return nil
        case .cloneAssets(assetId: _, numberOfClone: _):
            return nil
        case .getRegistedAssetDetail(model: let model):
            return nil
        case .deleteSiteAssets(id: let id):
            return nil
        case .documentSiteParentFoldersAPI(siteId: let siteId):
            return nil
        case .siteAssetsAPI(siteId: let siteId):
            return nil
        case .siteAllWithDetails(withDetails: let withDetails):
            return nil
        case .lovAPI(lovType: let lovType, desc: let desc, filter1: let filter1):
            return nil
        case .put_siteAssetsAPI(siteId: let siteId):
            return nil
        case .siteAssetsDetails(assetId: let assetId):
            return nil
        case .documnetFileMove, .documnetFileCopy:
            return nil
        case .searchApiForDocumnet(query: let query):
            return nil
        case .put_siteAssetsDetails(assetId: let assetId):
            return nil
        case .put_siteAssets_patDetails(assetId: let assetId, model: let model):
            return model.toJSON()
        case .put_siteAssets_pspDetails(assetId: let assetId, model: let model):
            return model.toJSON()
        case .put_siteAssets_doorSpecification(assetId: let assetId, model: let model):
            return model.toJSON()
        case .getAllUserDataBy(userRole: let userRole):
            return nil
        case .getProjectContractsCategory, .getProjectContractSubCategory:
            return nil
        case .getUserRole(userRole: let userRole, siteId: let siteId):
            return nil
        case .contractsFolderAPI(projectContractId: let projectContractId, model: let model):
            return model.toJSON()
        case .contractsAssetsAPI(projectContractId: let projectContractId, model: let model):
            return model.toJSON()
        case .contractsVisitAPI(model: let model):
            return model.toJSON()
        case .contractsCalenderAPI(model: let model):
            return model.toJSON()
        case .contractsManageAPI(model: let model):
            return model.toJSON()
        case .getProjectContractDetails(projectId: let projectId):
            return nil
        case .deleteScheduleVisitAPI(scheduleId: let scheduleId):
            return nil
        case .updateContractsManageAPI(model: let model):
            return model.first?.toJSON()
        case .terminateContract(projectId: let projectId):
            return nil
        case .statutoryRegister(siteId: let siteId):
            return nil
        case .statutoryRegisterAll:
            return nil
        case .contracterContractsDetails(contractId: let contractId):
            return nil
        case .getSelectedSiteContractDetails(siteId: let siteId, contractId: let contractId, area: let area):
            return nil
        case .userManagerAddSite(userID: let userID, addedSites: let addedSites, removedSites: let removedSites):
            return ["addedSites": addedSites, "removedSites": removedSites]
        case .resetPassWordFromHome(userId: let userId, password: let password):
            return ["password": password, "userId": userId]
        case .manageStatutoryRegister(model: let model):
            return model.toJSON()
        case .energyCostCategory:
            return nil
        case .siteEnergyCostDetails(siteId: let siteId):
            return nil
        case .energySurveyAll:
            return nil
        case .getPreActionSummaryDetail(taggedSiteId: let taggedSiteId):
            return nil
        case .deletePreAction(actionId: let actionId):
            return nil
        case .createPreAction(actionId: let actionId):
            return nil
        case .deleteEnegySubCoste(costId: let costId):
            return nil
        case .deleteEnegySubReading(readingId: let readingId):
            return nil
        case .closePreAction(actionId: let actionId):
            return nil
        case .pendingPreAction(actionId: let actionId, model: let model):
            return model.toJSON()
        case .approvePreAction(model: let model):
            return model.toJSON()
        case .dropDownTyprList:
            return nil
        case .dropDownList(catType: let catType):
            return nil
        case .deleteDropDownValue(id: let id):
            return nil
        case .addnewValueDropDown(item: let item):
            return item.toJSON()
        case .editValueDropDown(id: let id, item: let item):
            return item.toJSON()
        case .addNewDropDown(item: let item):
            return item.toJSON()
        case .createNewEnrReading(item: let item):
            return item.toJSON()
        case .deleteEnergyServay(id: let id):
            return nil
        case .addNewCostInreading(item: let item):
            return item.toJSON()
        case .addRedingInreading(item: let item):
            return item.toJSON()
        case .resetPasswordAPI(model: let model):
            return model.toJSON()
        case .manageCompanyAPI(model: let model):
            return model.toJSON()
        case .deleteCompanyAPI(id: let id):
            return nil
        case .getSiteActionsDetailsFromIDAPI(id: let id):
            return nil
        case .addComments(model: let model):
            return model.toJSON()
        case .getActionComment(id: let id):
            return nil
        case .uploadAction(model: let model):
            return model.toJSON()
        case .getSITE_CHECK_TYPE, .getSITE_CHECK_SUB_TYPE, .getSITE_CHECK_CATEGORY:
            return nil
        case .addNewCostInreading(item: let item):
            return item.toJSON()
        case .addRedingInreading(item: let item):
            return item.toJSON()
        case .getSiteAssetsAllV2(area: let area, fromDate: let fromDate, toDate: let toDate, siteId: let siteId):
            return nil
        }
    }
    
    func apiWithQueryParameters(string: String, queryItems: [URLQueryItem]) -> String {
        if var urlComponents = URLComponents(string: string) {
            for queryItem in queryItems {
                if let value = queryItem.value {
                    if urlComponents.queryItems == nil {
                        urlComponents.queryItems = []
                    }
                    urlComponents.queryItems?.append(queryItem)
                }
            }
            return urlComponents.string ?? string
        }
        return string
    }
    
}

var headersNew: HTTPHeaders {
    return ["Cookie": jwtToken ?? ""]
}

//var headersNew: HTTPHeaders = [
//    "Cookie": jwtToken ?? ""
//]


func logOutScreen() {
    DispatchQueue.main.async {
        let vc = loginSB.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.delegate = sceneDelegate
        sceneDelegate.window?.rootViewController = navigationController
    }
}

class APIClient {
    
    
    enum MappableResult<T: Mappable> {
        case single(T)
        case array([T])
    }
    
    // Generic function for API request
    static func request<T: Mappable>(_ service: ApiService, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default, headers: headersNew).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]], response.response?.statusCode == 200 {
                    // Mapping the array of Mappable objects
                    let objects = jsonArray.compactMap { T(JSON: $0) }
                    completion(.success(.array(objects)))
                }else if let json = value as? [String: Any], let object = T(JSON: json), response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                    // Mapping a single Mappable object
                    completion(.success(.single(object)))
                }else if let json = value as? [String: Any], let object = T(JSON: json), response.response?.statusCode == 401 {
                    UserConstants.shared.logoutUser()
                    logOutScreen()
                    completion(.success(.single(object)))
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Generic function for API request
    static func loginRequest<T: Mappable>(_ service: ApiService, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let object = T(JSON: json), response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                    // Mapping a single Mappable object
                    completion(.success(.single(object)))
                }else if let json = value as? [String: Any], let object = T(JSON: json), response.response?.statusCode == 401 {
                    completion(.success(.single(object)))
                }else {
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func request<T: Mappable>(_ service: ApiService, completion: @escaping (Result<T, Error>) -> Void) {
        
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: URLEncoding.default, headers: headersNew).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let object = T(JSON: json) {
                    completion(.success(object))
                } else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestDelete(_ service: ApiService, completion: @escaping(_ isSucess: Bool) -> Void) {
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default, headers: headersNew).response(completionHandler: { response in
            switch response.result {
            case .success(let value):
                //rk-pd in this put the condition of the 200 code
                if response.response?.statusCode == 200 || response.response?.statusCode == 204 {
                    completion(true)
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(false)
                }
                break
            case .failure(let error):
                completion(false)
                break
            }
        })
    }
    
    static func uploadFile<T: Mappable>(_ service: ApiService, _ fileURL: URL, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        let apiURL = service.api() // Replace with your API URL
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "file", fileName: fileURL.lastPathComponent, mimeType: APIClient.mimeType(for: fileURL))
        }, to: apiURL, headers: headersNew)
        .response { response in
            switch response.result {
            case .success(let value):
                if let value = value {
                    do {
                        // Try to parse the data as JSON
                        if let json = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any] {
                            // Map JSON to object using ObjectMapper
                            let object = T(JSON: json)
                            if let object = object {
                                completion(.success(.single(object)))
                            } else {
                                completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                            }
                        } else {
                            completion(.failure(NSError(domain: "JSON Parsing Error", code: 1, userInfo: nil)))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }else {
                    completion(.failure(NSError(domain: "JSON Parsing Error", code: 1, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function for handling string responses
    static func requestString(_ service: ApiService, completion: @escaping (Result<String, Error>) -> Void) {
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default, headers: headersNew).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestResponse(_ service: ApiService, completion: @escaping (_ isSucess: Bool) -> Void) {
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default, headers: headersNew).response { response in
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 200 {
                    completion(true)
                }else {
                    completion(false)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    // Function for handling multipart form data
    static func requestMultipart<T: Mappable>(_ service: ApiService, multipartData: @escaping (MultipartFormData) -> Void, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        
        AF.upload(multipartFormData: multipartData, to: service.api(), method: service.method(), headers: headersNew).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]] {
                    // Mapping the array of Mappable objects
                    let objects = jsonArray.compactMap { T(JSON: $0) }
                    if objects.isEmpty {
                        if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                            logOutScreen()
                        }
                        completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                    } else {
                        completion(.success(.array(objects)))
                    }
                } else if let json = value as? [String: Any], let object = T(JSON: json) {
                    // Mapping a single Mappable object
                    completion(.success(.single(object)))
                } else {
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func requestMultipart1(_ service: ApiService, multipartData: @escaping (MultipartFormData) -> Void, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        AF.upload(multipartFormData: multipartData, to: service.api(), method: service.method(), headers: headersNew).response { response in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    completion(.success(true))
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestMultipartString(_ service: ApiService, multipartData: @escaping (MultipartFormData) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        AF.upload(multipartFormData: multipartData, to: service.api(), method: service.method(), headers: headersNew).responseString { response in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    completion(.success(value))
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "svg":
            return "image/svg+xml"
        case "pdf":
            return "application/pdf"
        default:
            return "image/jpeg"
        }
    }

    static func requestWithCode(_ service: ApiService, completion: @escaping(_ isSucess: Bool, _ code: Int?) -> Void) {
        let parameters = service.parameters()
        // Convert the parameters to JSON
        // Create a URL request
        var request = URLRequest(url: URL(string: service.api())!)
        request.httpMethod = service.method().rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let cookieValue = jwtToken ?? ""
        request.setValue(cookieValue, forHTTPHeaderField: "Cookie")

        if service.parameters() != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                completion(false, nil)
                return
            }

            // Check for HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                completion(true, httpResponse.statusCode)
                return
            }else {
                completion(false, nil)
                return

            }
        }
        task.resume()
    }
    
    static func requestWithArray(_ service: ApiService, parameters: [[String: Any]]? = nil, completion: @escaping(_ isSucess: Bool, _ code: Int?) -> Void) {
        var request = URLRequest(url: URL(string: service.api())!)
        request.httpMethod = service.method().rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        let cookieValue = jwtToken ?? ""
        request.setValue(cookieValue, forHTTPHeaderField: "Cookie")

        // Use Alamofire to send the request
        AF.request(request).responseString { response in
            switch response.result {
            case .success(let value):
                print("Response: \(value)")
                completion(true, response.response?.statusCode ?? -1)
            case .failure(let error):
                print("Error: \(error)")
                completion(false, nil)
            }
        }
    }
    
    static func uploadFileInFolder<T: Mappable>(service: ApiService, fileURL: URL, documentRequest: FileUploadRequest , completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        
        let documentRequestString = documentRequest.toJSONString()
                
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "files", fileName: fileURL.lastPathComponent, mimeType: "application/octet-stream")
            if let requestData = documentRequestString?.data(using: .utf8) {
                multipartFormData.append(requestData, withName: "documentRequestString")
            }
        }, to: service.api(), method: .post, headers: headersNew)
        .response { response in
            switch response.result {
            case .success(let value):
                if let value = value {
                    do {
                        // Try to parse the data as JSON
                        if let json = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any], response.response?.statusCode == 200 {
                            
                            print("uploadFileInFolder \(json)")
                            // Map JSON to object using ObjectMapper
                            let object = T(JSON: json)
                            if let object = object {
                                completion(.success(.single(object)))
                            } else {
                                completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                            }
                        } else {
                            if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                                logOutScreen()
                            }

                            completion(.failure(NSError(domain: "JSON Parsing Error", code: 1, userInfo: nil)))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }else {
                    completion(.failure(NSError(domain: "JSON Parsing Error", code: 1, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func uploadFileNewVersion(service: ApiService, fileURL: URL, documentRequest: FileUploadRequest , completion: @escaping (_ isSucess: Bool) -> Void) {
        
        let documentRequestString = Mapper().toJSONString(documentRequest, prettyPrint: true)
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "file", fileName: fileURL.lastPathComponent, mimeType: APIClient.mimeType(for: fileURL))
            if let requestData = documentRequestString?.data(using: .utf8) {
                multipartFormData.append(requestData, withName: "documentRequestString")
            }
        }, to: service.api(), method: service.method(), headers: headersNew)
        .response { response in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    completion(true)
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(false)
                }
            case .failure(let error):
                completion(false)
            }
        }
    }
    
    static func requestWithStringArray(_ service: ApiService, completion: @escaping ([String]?, Error?) -> Void) {
        
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default, headers: headersNew).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [String?], response.response?.statusCode == 200 {
                    completion(jsonArray.compactMap({$0}), nil)
                }else {
                    if let json = value as? [String: Any], let object = APIErrorResponse(JSON: json), let message = object.message, message.lowercased().contains("JWT".lowercased()), (response.response?.statusCode == 500 || response.response?.statusCode == 401) {
                        logOutScreen()
                    }
                    completion(nil, nil)
                }
            case .failure(let error):
                completion(nil, nil)
            }
        }
    }
    
}


