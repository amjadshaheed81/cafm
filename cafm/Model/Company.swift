//
//  Company.swift
//  cafm
//
//  Created by ShitaRam on 25/08/24.
//

import ObjectMapper

class Company: Mappable {
    
    var companyId: Int?
    var companyName: String?
    var email: String?
    var phone: String?
    
    required init?(map: Map) {
        // Initial setup if needed
    }
    
    init () {
        
    }
    
    func mapping(map: Map) {
        companyId   <- map["companyId"]
        companyName <- map["companyName"]
        email       <- map["email"]
        phone       <- map["phone"]
    }
}
