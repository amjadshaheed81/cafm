//
//  CAFMDatePicker.swift
//  cafm
//
//  Created by NS on 21/09/24.
//  
//

import UIKit

final class CAFMDatePicker: NSObject {
    
    weak var delegate: CAFMDatePickerDelegate?
    
    init(delegate: CAFMDatePickerDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    func openDatePicker(presentVC: UIViewController, sender: UIView, tag: Int, selectedDate: Date? = nil, minDate: Date? = nil, maxDate: Date? = nil, hideButton: Bool = false, dateChangeHandler: ((Date?) -> Void)? = nil) {
        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        if let dateChangeHandler {
            vc.dateChangeHandler = dateChangeHandler
        }else {
            vc.delegate = self
        }
        vc.selectedDate = selectedDate
        vc.minimumDate = minDate
        vc.maximumDate = maxDate
        vc.hideButtons = hideButton
        
        if hideButton {
            vc.preferredContentSize = CGSize(width: 10+320+10, height: 10+324+10)
        }else {
            vc.preferredContentSize = CGSize(width: 10+320+10, height: 10+324+40+10)
        }
        vc.modalPresentationStyle = .popover
        vc.presentationController?.delegate = self
        vc.popoverPresentationController?.permittedArrowDirections = .any
        //vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        vc.popoverPresentationController?.sourceView = sender
        vc.popoverPresentationController?.sourceRect = sender.bounds
        
        vc.view.tag = tag
        presentVC.present(vc, animated: true)
    }
    
}

//MARK: - DatePickerVCDelegate
extension CAFMDatePicker: DatePickerVCDelegate {
    
    func datePickerVCDidSelectDate(vc: UIViewController, date: Date?) {
        self.delegate?.datePickerDidSelectDate(date, tag: vc.view.tag)
    }
    
}

//MARK: - UIPopoverPresentationControllerDelegate
extension CAFMDatePicker: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? .popover : .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
}

//MARK: - protocol CAFMDatePickerDelegate
protocol CAFMDatePickerDelegate: AnyObject {
    func datePickerDidSelectDate(_ date: Date?, tag: Int)
    func datePickerDidClose(tag: Int)
}
