//
//  ListStatusBadge.swift
//  cafm
//
//  Created by NS on 28/10/24.
//
//

import UIKit

enum ListStatusBadge: String {
    case open
    case closed
    case sold
    case recieved
    case awarded
    case rejected
    
    static func status(from status: String?) -> ListStatusBadge {
        ListStatusBadge(rawValue: status?.lowercased() ?? "") ?? .open
    }
    
    var displayText: String {
        return rawValue.capitalized
    }
    
    var textColor: UIColor {
        switch self {
        case .open, .awarded: UIColor(appColor: .GreenStatus)
        case .closed, .rejected: UIColor(appColor: .RedStatus)
        case .sold, .recieved: UIColor(appColor: .AmberStatus)
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .open, .awarded: UIColor(appColor: .GreenStatusBG)
        case .closed, .rejected: UIColor(appColor: .RedStatusBG)
        case .sold, .recieved: UIColor(appColor: .AmberStatusBG)
        }
    }
}
