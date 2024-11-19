//
//  ChartModel.swift
//  cafm
//
//  Created by NS on 12/11/24.
//
//

import Foundation
import ObjectMapper

class CostChartModel: Mappable {
    var x: String?
    var y: Double?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        x <- map["x"]
        y <- map["y"]
    }
}

class AssetChartModel: Mappable {
    var pat: Int?
    var door: Int?
    var general: Int?
    var pfp: Int?
    var cost: [CostChartModel]?
    var costSite: [CostChartModel]?
    var quantity: [CostChartModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        pat <- map["pat"]
        door <- map["door"]
        general <- map["genral"]
        pfp <- map["pfp"]
        cost <- map["cost"]
        costSite <- map["costSite"]
        quantity <- map["quantity"]
    }
}
