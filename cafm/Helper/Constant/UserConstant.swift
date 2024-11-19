//
//  UserConstant.swift
//  cafm
//
//  Created by NS on 26/08/24.
//
//

import Foundation

final class UserConstants {
    static let shared = UserConstants()
    private init() { }
    
    var userDetail: User?
    private(set) var allSites: [CreateSiteRequestModel] = []
    
    func setAllSites(from sites: [CreateSiteRequestModel]) {
        let userRole = UserDefaults.standard.userRole
        if userRole == .admin {
            allSites = sites
        }else if let taggedSite = userDetail?.taggedSites {
            allSites = sites.filter({ site in
                return taggedSite.contains { $0.id == site.siteId }
            })
        }
    }
    
    var currentUserID: Int? {
        get {
            return UserDefaults.standard.object(forKey: "currentUserID") as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentUserID")
        }
    }
    
    var selectedSiteID: Int? {
        get {
            return UserDefaults.standard.object(forKey: "selectedSiteID") as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedSiteID")
        }
    }
    
    var selectedSiteName: String? {
        if let siteId = selectedSiteID, let site = allSites.first(where: { $0.siteId == siteId }) {
            return site.siteName
        }
        return nil
    }
    
    var selectedUserName: String? {
        if let user = userDetail {
            return user.name
        }
        return nil
    }
    
    func logoutUser() {
        userEmailId = nil
        userPassword = nil
        jwtToken = nil
        sasToken = nil
        UserDefaults.standard.setValue(nil, forKey: "UserRole")
        
        userDetail = nil
        allSites = []
        currentUserID = nil
        selectedSiteID = nil
        
        sasToken = nil
    }
    
    var sasToken: String?
    
    var SiteArea: [String] = [
        "East Midlands",
        "Ireland & Northern Ireland",
        "London & Eastern",
        "North East, Yorkshire & Humberside",
        "North West",
        "Scotland",
        "Central",
        "South East",
        "South West",
        "Wales",
        "West Midlands",
    ]
    
}
