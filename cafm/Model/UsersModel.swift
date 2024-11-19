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
    
    var userId: Int?
    var firstName: String?
    var lastName: String?
    
    var password: String?
    var companyEntity: CompanyEntity?
    var siteDocumentsEntity: [String]?
    var reviewersiteDocumentsEntity: [String]?
    var userSitesEntity: [UserSitesEntity]?
    
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
        
        userId          <- map["userId"]
        firstName       <- map["firstName"]
        lastName        <- map["lastName"]
        
        password <- map["password"]
        companyEntity <- map["companyEntity"]
        siteDocumentsEntity <- map["siteDocumentsEntity"]
        reviewersiteDocumentsEntity <- map["reviewersiteDocumentsEntity"]
        userSitesEntity <- map["userSitesEntity"]
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

// Model for UsersList
class LoginUserDetail: Mappable {
    var user: User?
    var message: String?
    var status: Int?
    var jwtToken: String?
    var sasToken: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        user <- map["user"]
        status <- map["status"]
        message <- map["message"]
        jwtToken <- map["jwtToken"]
        sasToken <- map["sasToken"]
    }
}

class EnergyCostBudgetCategory: Mappable {
    var id: Int?
    var lovType: String?
    var lovValue: String?

    // Required initializer for ObjectMapper
    required init?(map: Map) {
    }

    // Mapping function where you map the JSON keys to object properties
    func mapping(map: Map) {
        id        <- map["id"]
        lovType   <- map["lovType"]
        lovValue  <- map["lovValue"]
    }
}

class CommentResponse: Mappable {
    var commentId: Int?
    var text: String?
    var actionId: Int?
    var userId: Int?
    var image: String?
    var createdAt: String?
    var user: User?

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
