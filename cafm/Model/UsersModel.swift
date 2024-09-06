//
//  UsersModel.swift
//  cafm
//
//  Created by ShitaRam on 18/08/24.
//

import ObjectMapper

// Model for User
class User: Mappable {
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
    
    var timestamp: String?
    var error: String?
    var message: String?
    var path: String?
    
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
        
        timestamp <- map["timestamp"]
        error <- map["error"]
        message <- map["message"]
        path <- map["path"]
    }
}

// Model for UsersList
class UsersList: Mappable {
    var users: [User]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        users <- map["users"]
    }
}
