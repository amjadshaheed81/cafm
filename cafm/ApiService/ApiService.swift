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
    
    case loginApi(email: String, password: String)
    case siteAllDetails
    case siteDetailsRiskData
    case projectContractsAPI(siteId: Int)
    case actionSummaryAPI(siteId: Int)
    case userCalendarEventsAPI
    case userDetailsAPI(userId: Int)
    case siteCheckSiteAPI(siteId: Int)
    case getAllUserData
    case userManageAPI(userModel: UserModel)
    case getAllCompanies
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
    case updateKeyContactAPI(models: [UpdateKeyContactRequestModel])
    case getKeyContactsDetail(userId: Int)
    case updateLocalDetails(userModel: UpdateCreateSiteLocalDetailsRequestModel)
    case updateTimingAPI(userModel: SiteScheduleRequestModel)
    case deleteSiteImage(userId: Int)
    case uploadSiteImageData(userId: Int)
    case deleteSiteDetails(userId: Int)
    case getAllSiteDetailsBySiteID(userId: Int)
    case siteLayoutAPI(siteId: Int)
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
    
    static let baseApi = "http://cpc-beta.ukwest.cloudapp.azure.com"
    
    func api() -> String {
        switch self {
        case .loginApi(let email, let password):
            return ApiService.baseApi+"/api/user/login?"+"email=\(email)&password=\(password)"
        case .siteAllDetails:
            return ApiService.baseApi+"/api/site/site/all"
        case .siteDetailsRiskData:
            return ApiService.baseApi+"/api/site-check/risks"
        case .projectContractsAPI(let siteId):
            return ApiService.baseApi+"/api/project/contracts?siteId=\(siteId)"
        case .actionSummaryAPI(let siteId):
            return ApiService.baseApi+"/api/action/\(siteId)/summary"
        case .userCalendarEventsAPI:
            return ApiService.baseApi+"/api/user/calendar/events"
        case .userDetailsAPI(let userId):
            return ApiService.baseApi+"/api/user/\(userId)/details"
        case .siteCheckSiteAPI(let siteId):
            return ApiService.baseApi+"/api/site-check/site/\(siteId)"
        case .getAllUserData:
            return ApiService.baseApi+"/api/user/all"
        case .userManageAPI:
            return ApiService.baseApi+"/api/user/manage"
        case .getAllCompanies:
            return ApiService.baseApi+"/api/companies/all"
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
        }
    }
    
    func method() -> HTTPMethod{
        switch self {
        case .loginApi, .projectContractsAPI, .actionSummaryAPI, .userCalendarEventsAPI, .userDetailsAPI, .siteCheckSiteAPI, .siteAllDetails, .siteDetailsRiskData, .getAllUserData, .siteActionsAPI, .getAllCompanies, .siteLayoutAPI, .getSearchAddressAPI, .getSearchResultAddressAPI, .getSiteSiteInfo, .folders:
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
        case .createSite(userModel: _):
            return .post
        case .updateKeyContactAPI(models: _):
            return .put
        case .getKeyContactsDetail(userId: _):
            return .get
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
        case .deleteFile(id: let id):
            return .delete
        case .uploadFileNewVersion:
            return .put
        case .deletekeyContacts(id: let id):
            return .delete
        }
    }
    
    func parameters() -> [String: Any]? {
        switch self {
        case .loginApi, .projectContractsAPI, .actionSummaryAPI, .userCalendarEventsAPI, .userDetailsAPI, .siteCheckSiteAPI, .siteAllDetails, .siteDetailsRiskData, .getAllUserData, .siteActionsAPI, .getAllCompanies, .siteLayoutAPI, .getSearchAddressAPI, .getSearchResultAddressAPI, .deleteUser, .siteUploadFloorPlan, .getSiteSiteInfo:
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
        }
    }
    
}

class APIClient {
    
    enum MappableResult<T: Mappable> {
        case single(T)
        case array([T])
    }
    
    // Generic function for API request
    static func request<T: Mappable>(_ service: ApiService, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]] {
                    // Mapping the array of Mappable objects
                    let objects = jsonArray.compactMap { T(JSON: $0) }
                    if objects.isEmpty {
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
    
    static func request<T: Mappable>(_ service: ApiService, completion: @escaping (Result<T, Error>) -> Void) {
        
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: URLEncoding.default).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let object = T(JSON: json) {
                    completion(.success(object))
                } else {
                    completion(.failure(NSError(domain: "Mapping Error", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestDelete(_ service: ApiService, completion: @escaping(_ isSucess: Bool) -> Void) {
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default).response(completionHandler: { response in
            switch response.result {
            case .success(let value):
                //rk-pd in this put the condition of the 200 code
                if response.response?.statusCode == 200 || response.response?.statusCode == 204 {
                    completion(true)
                }else {
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
        }, to: apiURL)
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
        AF.request(service.api(), method: service.method(), parameters: service.parameters(), encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function for handling multipart form data
    static func requestMultipart<T: Mappable>(_ service: ApiService, multipartData: @escaping (MultipartFormData) -> Void, completion: @escaping (Result<MappableResult<T>, Error>) -> Void) {
        
        AF.upload(multipartFormData: multipartData, to: service.api(), method: service.method()).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]] {
                    // Mapping the array of Mappable objects
                    let objects = jsonArray.compactMap { T(JSON: $0) }
                    if objects.isEmpty {
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
        
        let documentRequestString = Mapper().toJSONString(documentRequest, prettyPrint: true)
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "files", fileName: fileURL.lastPathComponent, mimeType: APIClient.mimeType(for: fileURL))
            if let requestData = documentRequestString?.data(using: .utf8) {
                multipartFormData.append(requestData, withName: "documentRequestString")
            }
        }, to: service.api())
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
        }, to: service.api(), method: service.method())
        .response { response in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    completion(true)
                }else {
                    completion(false)
                }
            case .failure(let error):
                completion(false)
            }
        }
    }
    
}


