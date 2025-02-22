//
//  StatutoryModel.swift
//  cafm
//
//  Created by ShitaRam on 17/09/24.
//

import Foundation
import ObjectMapper

class StatutoryRegistersModel: Mappable {
    var siteId: Int?
    var siteName: String?
    var statutoryRegisters: [StatutoryModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        siteId <- map["siteId"]
        siteName <- map["siteName"]
        statutoryRegisters <- map["statutoryRegisters"]
    }
}

class StatutoryModel: Mappable {
    
    var id: Int?
    var siteId: Int?
    var requirement: String?
    var required: Bool?
    var residence: String?
    var status: String?
    var type: String?
    var subType: String?
    var files: [File]?
    var sortOrder: String?
    
    var siteName: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id          <- map["id"]
        siteId      <- map["siteId"]
        requirement <- map["requirement"]
        required    <- map["required"]
        residence   <- map["residence"]
        status      <- map["status"]
        type        <- map["type"]
        subType     <- map["subType"]
        files       <- map["files"]
        sortOrder   <- map["sortOrder"]
    }
    
    // Function to check the status based on your conditions
    func checkStatus(complition: @escaping((_ status: String) -> Void)) {
        guard let required = self.required, required else {
            complition("Fail")
            return
        }
        if type?.lowercased() == "PDF".lowercased() {
            if let files = files, files.count > 0, hasValidExpiry(files: files) {
                complition("Passed")
            }else {
                complition("Fail")
            }
        } else if type?.lowercased() == "link".lowercased() , let subType = subType {
            guard let siteID = UserConstants.shared.selectedSiteID else {
                complition("Fail")
                return
            }
            let apiService = ApiService.siteCheckSiteAPI(siteId: siteID)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
                guard let self else { return }
                switch result {
                case .success(let mappableResult): 
                    switch mappableResult {
                    case .array(let array):
                        print(array)
                        switch subType {
                        case "Asbestos":
                            let isAsbestosRecordAvailable = array.contains(where: {$0.subType == "Asbestos"})
                            complition(isAsbestosRecordAvailable ? "Passed" : "Fail")
                            break
                        case "PAT":
                            let apiService = ApiService.getRegistedAssetDetail(model: AssetRegisterData.assetPatAPI(siteId: siteID))
                            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetsResponse>, Error>) in
                                guard let strongSelf = self else { return }
                                switch result {
                                case .success(let mappableResult):
                                    switch mappableResult {
                                    case .single(let single):
                                        guard let files = self?.files, !files.isEmpty, let assets = single.assets, !assets.isEmpty else {
                                            complition("Fail")
                                            return
                                        }
                                        let isExpiryDateValid = strongSelf.hasValidExpiry(files: files)
                                        complition(isExpiryDateValid ? "Passed" : "Fail")
                                        break
                                    default:
                                        complition("Fail")
                                        break
                                    }
                                case .failure(let error):
                                    complition("Fail")
                                    print(apiService.api(), "Error:", error.localizedDescription)
                                }
                            }
                            break
                        case "Emergency light and Fire Alarm":
                            let isEmergencyAvailable = self.isEmergencyAvailable(siteChecks: array)
                            complition(isEmergencyAvailable ? "Passed" : "Fail")
                            break
                        case "Water Risk Assessment/Water Temperature" :
                            let isWaterAvailable = self.isWaterAvailable(siteChecks: array)
                            complition(isWaterAvailable ? "Passed" : "Fail")
                            break
                        default:
                            complition("Fail")
                            break
                        }
                        break
                    default:
                        complition("Fail")
                        break
                    }
                    break
                case .failure(let error):
                    complition("Fail")
                    break
                }
            }
        }
    }

    
    func isEmergencyAvailable(siteChecks: [SiteCheckModel]) -> Bool {
        let currentDate = Date()
        return siteChecks.contains { itm in
            if itm.type == "Audit", let dueDateString = itm.dueDate, let dueDate = stringToDate(dueDateString) {
                return dueDate > currentDate
            }
            return false
        }
    }
    
    func isWaterAvailable(siteChecks: [SiteCheckModel]) -> Bool {
        let currentDate = Date()
        return siteChecks.contains { itm in
            if itm.subType == "Water", let dueDateString = itm.dueDate, let dueDate = stringToDate(dueDateString) {
                return dueDate > currentDate
            }
            return false
        }
    }


    
    // Helper methods to check specific conditions

    private func hasDocumentAvailable(files: [File]) -> Bool {
        return !files.isEmpty
    }

    private func hasValidExpiry(files: [File]) -> Bool {
        let currentDate = Date()
        return !files.contains { file in
            if let expiryDateStr = file.expiryDate, let expiryDate = stringToDate(expiryDateStr), currentDate > expiryDate {
                return true
            }else {
                return false
            }
        }
    }

    private func hasAnyRecord(files: [File]?) -> Bool {
        guard let files = files else { return false }
        return !files.isEmpty
    }

    
}
