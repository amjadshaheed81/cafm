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
    
    var userDetail: UserModel?
    private(set) var allSites: [SiteModel] = []
    
    func setAllSites(from sites: [SiteModel]) {
        let userRole = UserDefaults.standard.userRole
        if userRole == .admin {
            allSites = sites
        }else if let taggedSite = userDetail?.taggedSites {
            allSites = sites.filter({ site in
                return taggedSite.contains { $0.id == site.siteId && $0.name == site.siteName }
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
    
    func logoutUser() {
        userEmailId = nil
        userPassword = nil
        UserDefaults.standard.setValue(nil, forKey: "UserRole")
        
        userDetail = nil
        allSites = []
        currentUserID = nil
        selectedSiteID = nil
    }
    
}
