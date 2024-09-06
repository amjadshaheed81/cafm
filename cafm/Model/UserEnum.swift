//
//  UserEnum.swift
//  cafm
//
//  Created by ShitaRam on 24/08/24.
//

import Foundation

enum UserEnum: String {
    case role = "Role"
    case admin = "Admin"
    case manager = "Manager"
    case siteActionManage = "Site Action Manage"
    case siteUsers = "Site Users"
    case careTaker = "Care Taker"
    case contractor = "Contractor"
    case surveyor = "Surveyor"
    case tradesman = "Tradesman"
    case tester = "Tester"
    case unknown = "Unknown"
    
    static var userTypeArray: [UserEnum] {
        [.role,.admin,.manager,.siteActionManage,.siteUsers,.careTaker,.contractor,.surveyor,.tradesman,.tester]
    }
    
}
