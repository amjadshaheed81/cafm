//
//  EventCalendarContainerVC.swift
//  cafm
//
//  Created by NS on 19/10/24.
//  
//

import UIKit

class EventCalendarContainerVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: CalendarSegment!
    @IBOutlet weak var containerView: UIView!
    
    weak var vc1: EventCalendarVC!
    weak var vc2: EventCalendarVC!
    
    let userConstants = UserConstants.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControlValueChanged(self.segmentedControl)
    }
    
    func setup() {
        var yourCalendarStr = "Your Calendar"
        var siteCalendarStr = "Site Calendar"
        
        if let userName = userConstants.selectedUserName {
            yourCalendarStr = "Your (\(userName)) Calendar"
        }
        if let siteName = userConstants.selectedSiteName {
            siteCalendarStr = "Site Calendar - \(siteName)"
        }
        
        self.segmentedControl.setTitle(yourCalendarStr, forSegmentAt: 0)
        self.segmentedControl.setTitle(siteCalendarStr, forSegmentAt: 1)
        self.segmentedControl.setTitleTextAttributes([
            .font: UIFont(name: .MontserratRegular, size: 15) as Any,
            .foregroundColor: UIColor(appColor: .PrimaryText)
        ], for: .normal)
        self.segmentedControl.setTitleTextAttributes([
            .font: UIFont(name: .MontserratMedium, size: 15) as Any,
            .foregroundColor: UIColor(appColor: .AppTint)
        ], for: .selected)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            if vc1 == nil {
                self.vc1 = generalSB.instantiateViewController(withIdentifier: "EventCalendarVC") as? EventCalendarVC
                add(childVC: self.vc1, to: self.containerView)
                self.vc1.view.isHidden = true
            }
            showViewController(self.vc1)
            break
        case 1:
            if vc2 == nil {
                self.vc2 = generalSB.instantiateViewController(withIdentifier: "EventCalendarVC") as? EventCalendarVC
                self.vc2.isForSite = true
                add(childVC: self.vc2, to: self.containerView)
                self.vc2.view.isHidden = true
            }
            showViewController(self.vc2)
            break
        default:
            break
        }
    }
    
}
