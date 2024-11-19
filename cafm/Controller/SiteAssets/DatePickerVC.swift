//
//  DatePickerVC.swift
//  cafm
//
//  Created by NS on 08/09/24.
//
//

import UIKit

class DatePickerVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    
    weak var delegate: DatePickerVCDelegate?
    var dateChangeHandler: ((Date?) -> Void)?
    var selectedDate: Date?
    var minimumDate: Date?
    var maximumDate: Date?
    var hideButtons: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hideButtons {
            self.buttonViewHeight.constant = CGFloat.zero
            self.buttonView.frame.size.height = self.buttonViewHeight.constant
            self.buttonView.isHidden = true
        }
        if let selectedDate {
            self.datePicker.date = selectedDate
        }
        if let minimumDate {
            self.datePicker.minimumDate = minimumDate
        }
        if let maximumDate {
            self.datePicker.maximumDate = maximumDate
        }
    }
    
    @IBAction func datePickerDateDidChange(_ sender: UIDatePicker) {
        self.dateChanged(sender.date)
    }
    
    @IBAction func clearBtnClicked(_ sender: UIButton) {
        self.datePicker.date = Date()
        self.dateChanged(nil)
    }
    
    @IBAction func todayBtnClicked(_ sender: UIButton) {
        self.datePicker.date = Date()
        self.dateChanged(self.datePicker.date)
    }
    
    func dateChanged(_ date: Date?) {
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if let dateChangeHandler {
                dateChangeHandler(date)
            }else {
                self.delegate?.datePickerVCDidSelectDate(vc: self, date: date)
            }
        }
    }
    
}

protocol DatePickerVCDelegate: AnyObject {
    func datePickerVCDidSelectDate(vc: UIViewController, date: Date?)
}
