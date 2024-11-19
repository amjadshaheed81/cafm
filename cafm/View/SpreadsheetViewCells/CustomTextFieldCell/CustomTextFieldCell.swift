//
//  CustomTextFieldCell.swift
//  cafm
//
//  Created by NS on 21/09/24.
//  
//

import UIKit
import SpreadsheetView

class CustomTextFieldCell: Cell {
    
    @IBOutlet weak var xib: CustomTextField!
    
    var stepper: UIStepper?
    
    var stepperValueHandler: ((Int) -> Void)?
    
    func setupStepper() {
        let stepperSize = CGSize(width: 94, height: 32)
        let padding: CGFloat = 4
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: stepperSize.width+(padding*2), height: self.xib.textField.frame.height)))
        
        self.stepper = UIStepper(frame: CGRect(origin: CGPoint(x: padding, y: (self.xib.textField.frame.height-stepperSize.height)/2), size: stepperSize))
        if let stepper {
            stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)
            stepper.stepValue = 1.0
            stepper.minimumValue = Double(Int.min)
            stepper.maximumValue = Double(Int.max)
            self.xib.textField.keyboardType = .numberPad
            //self.stepper?.isContinuous = true
            //self.stepper?.autorepeat = true
            view.addSubview(stepper)
        }
        
        self.xib.textField.rightView = view
        self.xib.textField.rightViewMode = .always
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        if let stepper {
            let value = Int(stepper.value)
            self.xib.textField.text = "\(value)"
            self.stepperValueHandler?(value)
        }
    }
    
}

extension UITextField {
    
    func setupStepper(valueHandler: @escaping ((Int) -> Void)) -> UIStepper {
        let stepperSize = CGSize(width: 94, height: 32)
        let padding: CGFloat = 4
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: stepperSize.width+(padding*2), height: self.frame.height)))
        
        let stepper = UIStepper(frame: CGRect(origin: CGPoint(x: padding, y: (self.frame.height-stepperSize.height)/2), size: stepperSize))
        
        stepper.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            let value = Int(stepper.value)
            self.text = "\(value)"
            valueHandler(value)
            
        }), for: .valueChanged)
        
        //stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)
        stepper.stepValue = 1.0
        stepper.minimumValue = Double(Int.min)
        stepper.maximumValue = Double(Int.max)
        view.addSubview(stepper)
        
        self.rightView = view
        self.rightViewMode = .always
        self.keyboardType = .numberPad
        
        return stepper
    }
    
}
