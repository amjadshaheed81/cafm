//
//  EnergyModel.swift
//  cafm
//
//  Created by ShitaRam on 05/10/24.
//

import UIKit
import ObjectMapper

// MARK: - Cost Model
class Cost: Mappable {
    var costId: Int?
    var fromDate: String?
    var toDate: String?
    var cost: Double?
    var budgetCategory: String?
    var submittedBy: String?
    var energyId: Int?

    required init?(map: Map) {}

    func mapping(map: Map) {
        costId          <- map["costId"]
        fromDate        <- map["fromDate"]
        toDate          <- map["toDate"]
        cost            <- map["cost"]
        budgetCategory  <- map["budgetCategory"]
        submittedBy     <- map["submittedBy"]
        energyId        <- map["energyId"]
    }
}

// MARK: - Reading Model
class Reading: Mappable {
    var readingId: Int?
    var readingValue: Double?
    var readingDate: String?
    var readingUnit: String?
    var energyId: Int?
    var submittedUserId: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        readingId       <- map["readingId"]
        readingValue    <- map["readingValue"]
        readingDate     <- map["readingDate"]
        readingUnit     <- map["readingUnit"]
        energyId        <- map["energyId"]
        submittedUserId <- map["submittedUserId"]
    }
}

// MARK: - Energy Model
class Energy: Mappable {
    var costList: [Cost]?
    var readingList: [Reading]?
    var energyId: Int?
    var reference: String?
    var budgetCategory: String?
    var siteId: Int?

    required init?(map: Map) {}

    func mapping(map: Map) {
        costList        <- map["costList"]
        readingList     <- map["readingList"]
        energyId        <- map["energyId"]
        reference       <- map["reference"]
        budgetCategory  <- map["budgetCategory"]
        siteId          <- map["siteId"]
    }
    
    func cost() -> String {
        var cost: Double = 0
        for i in costList ?? [] {
            cost += i.cost ?? 0
        }
        return String(format: "£%.2f", cost)
    }
    
}

class ReqEnrAndCostModel: Mappable {
    var searchField: String?
    var reference: String?
    var budgetCategory: String?
    var siteId: Int?

    // Required initializer for ObjectMapper
    required init?(map: Map) {
    }
    
    init() {
        
    }

    // Mapping function
    func mapping(map: Map) {
        searchField     <- map["searchField"]
        reference       <- map["reference"]
        budgetCategory  <- map["budgetCategory"]
        siteId          <- map["siteId"]
    }
}
