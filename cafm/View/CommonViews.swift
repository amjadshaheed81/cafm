//
//  CommonViews.swift
//  cafm
//
//  Created by NS on 17/08/24.
//
//

import UIKit

class PrimaryButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.addCorner()
        self.tintColor = UIColor.white
        self.imageView?.tintColor = self.tintColor
        self.backgroundColor = UIColor(appColor: .AppTint)
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = UIColor(appColor: .AppTint)
            }else {
                self.backgroundColor = UIColor.lightGray
            }
        }
    }
}

func getPrimaryNavigationBtn(title: String) -> UIButton {
    let btn = UIButton(type: .system)
    btn.addCorner()
    btn.backgroundColor = UIColor(appColor: .AppTint)
    btn.tintColor = UIColor.white
    btn.setTitle(title, for: .normal)
    btn.titleLabel?.font = UIFont(name: .MontserratSemiBold, size: 15)
    
    let lbl = UILabel()
    lbl.text = btn.title(for: .normal)
    lbl.font = btn.titleLabel?.font
    lbl.numberOfLines = 1
    lbl.sizeToFit()
    
    let size = CGSize(width: max(32, 8+lbl.frame.width+8), height: 32)
    btn.frame = CGRect(origin: CGPoint.zero, size: size)
    btn.widthAnchor.constraint(equalToConstant: size.width).isActive = true
    btn.heightAnchor.constraint(equalToConstant: size.height).isActive = true

    return btn
}

class SecondaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white //UIColor.clear
        self.addCorner()
        self.addBorder()
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
    }
}

class DefaultFontLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = getAppPrimaryFont(from: self.font)
    }
}

class DefaultFontButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addCorner()
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
    }
}

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor(appColor: .BG1)
        self.tintColor = UIColor(appColor: .PrimaryText)
        self.addCorner()
        self.addBorder(color: UIColor(appColor: .Separator2))
        self.titleLabel?.font = getAppPrimaryFont(from: self.titleLabel?.font)
        self.setTitleColor(UIColor(appColor: .PrimaryText), for: .normal)
    }

}

func getActionButton(size: CGSize, tag: Int, image: UIImage?, target: Any? = nil, action: Selector? = nil) -> ActionButton {
    let btn = ActionButton(type: .system)
    btn.frame = CGRect(origin: CGPoint.zero, size: size)
    btn.tag = tag
    btn.setImage(image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
    if let target, let action {
        btn.addTarget(target, action: action, for: .touchUpInside)
    }
    
    btn.widthAnchor.constraint(equalToConstant: size.width).isActive = true
    btn.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    return btn
}

class DefaultTextView: UITextView, NSTextStorageDelegate {
    
    private class PlaceholderLabel: UILabel { }
    
    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap( { $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            label.textColor = UIColor.lightGray
            label.numberOfLines = 0
            addSubview(label)
            return label
        }
    }
    
    @IBInspectable
    var placeholder: String {
        get {
            return subviews.compactMap( { $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue
            let width = frame.width - (textContainer.lineFragmentPadding * 2) - (textContainerInset.left+textContainerInset.right)
            let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            placeholderLabel.frame.size.height = size.height
            placeholderLabel.frame.size.width = width
            placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding+textContainerInset.left, y: textContainerInset.top)
            
            textStorage.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addCorner()
        self.addBorder(color: UIColor(appColor: .Separator2))
        self.font = getAppPrimaryFont(from: self.font)
    }
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
}

class DefaultSwitch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.onTintColor = UIColor(appColor: .AppTint)
    }

}

class CalendarSegment: UISegmentedControl {
    
}
