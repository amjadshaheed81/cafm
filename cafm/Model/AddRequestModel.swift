//
//  AddRequestModel.swift
//  cafm
//
//  Created by ShitaRam on 25/08/24.
//

import Foundation
import ObjectMapper


struct AddUserRequet: Mappable {
    var userId: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var phone: CGFloat?
    var role: String?
    var userType: String?
    var defaultSiteId: Int?
    var companyId: Int?
    var trade: String?
    var status: String?
    var favorite: String?
    var taggedSites: [TaggedSite]?

    init?(map: Map) {}
    
    init() {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        email <- map["email"]
        password <- map["password"]
        phone <- map["phone"]
        role <- map["role"]
        userType <- map["userType"]
        defaultSiteId <- map["defaultSiteId"]
        companyId <- map["companyId"]
        trade <- map["trade"]
        status <- map["status"]
        favorite <- map["favorite"]
        taggedSites <- map["taggedSites"]
    }
}
