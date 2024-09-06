//
//  DesignableView.swift
//  cafm
//
//  Created by ShitaRam on 19/08/24.
//

import UIKit

@IBDesignable
class DesignableCornerView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.masksToBounds = cornerRadius > 0
    }
}

@IBDesignable
class DesignableView: UIView {
    
    @IBInspectable var CornerRadius: CGFloat = CGFloat.zero  {
        didSet {
            layer.cornerRadius = CornerRadius
            layer.masksToBounds = CornerRadius > 0
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = CGFloat.zero  {
        didSet {
            layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = BorderColor.cgColor
        }
    }
    
    @IBInspectable var ShadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = ShadowColor.cgColor
        }
    }
    
    @IBInspectable var ShadowOpacity: CGFloat = CGFloat.zero  {
        didSet {
            layer.shadowOpacity = Float(ShadowOpacity)
        }
    }
    
    @IBInspectable var ShadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = ShadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = CGFloat.zero {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = CornerRadius
        layer.masksToBounds = CornerRadius > 0
        
        layer.borderWidth = BorderWidth
        layer.borderColor = BorderColor.cgColor
        
        layer.shadowColor = ShadowColor.cgColor
        layer.shadowOpacity = Float(ShadowOpacity)
        layer.shadowOffset = ShadowOffset
        layer.shadowRadius = shadowRadius
    }
    
}
