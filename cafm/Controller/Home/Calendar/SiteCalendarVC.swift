//
//  SiteCalendarVC.swift
//  cafm
//
//  Created by NS on 20/10/24.
//
//

import UIKit

class SiteCalendarVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var filterMainView: DesignableView!
    @IBOutlet weak var filterMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterSubView: UIView!
    @IBOutlet weak var filterSubViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filtersDropDownXIB: OptionBtnXib!
    
    @IBOutlet weak var searchXIB: CustomTextField!
    @IBOutlet weak var monthXIB: OptionBtnXib!
    @IBOutlet weak var yearXIB: OptionBtnXib!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
