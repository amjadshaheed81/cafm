//
//  SpreadsheetViewCells.swift
//  cafm
//
//  Created by Savan Lakhani on 19/08/24.
//

import UIKit
import SpreadsheetView

class SiteDetailsCell: Cell {
    let label = UILabel()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.label.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label.frame = bounds
        self.label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.label.font = UIFont.boldSystemFont(ofSize: 14)
        self.label.textAlignment = .left
        self.label.numberOfLines = 2
        self.contentView.addSubview(self.label)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class RiskCell: Cell {
    
    let redLabel = UILabel()
    let amberLabel = UILabel()
    let yellowLabel = UILabel()
    let greenLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
        setupStackView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.redLabel.text = "0"
        self.amberLabel.text = "0"
        self.greenLabel.text = "0"
        self.yellowLabel.text = "0"
    }
    
    private func setupLabels() {
        [redLabel, amberLabel, yellowLabel, greenLabel].forEach { label in
            addCornerToView(label, value: 5)
            label.text = "0"
            label.font = UIFont(name: .MontserratMedium, size: 12)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            if label == self.redLabel {
                label.backgroundColor = UIColor(appColor: .RedStatus)
            }else if label == self.amberLabel {
                label.backgroundColor = UIColor(appColor: .AmberStatus)
            }else if label == self.yellowLabel {
                label.backgroundColor = UIColor(appColor: .YellowRiskScore)
            }else if label == self.greenLabel {
                label.backgroundColor = UIColor(appColor: .GreenRiskScore)
            }
        }
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [redLabel, amberLabel, yellowLabel, greenLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.redLabel.widthAnchor.constraint(equalTo: self.redLabel.heightAnchor),
            self.amberLabel.widthAnchor.constraint(equalTo: self.amberLabel.heightAnchor),
            self.yellowLabel.widthAnchor.constraint(equalTo: self.yellowLabel.heightAnchor),
            self.greenLabel.widthAnchor.constraint(equalTo: self.greenLabel.heightAnchor),
        ])
    }
        
}

class ActionCell: Cell {
    
    let viewImage = UIImageView()
    let editImage = UIImageView()
    let deleteImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
        setupStackView()
    }
    
    private func setupLabels() {
        [self.viewImage, self.editImage, self.deleteImage].forEach { imageView in
            imageView.backgroundColor = .white
            imageView.contentMode = .scaleAspectFit
            addCornerToView(imageView, value: 6)
            addBorderToView(imageView, color: UIColor.gray)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if imageView == self.viewImage {
                let image = UIImage(named: "eye")
                let insets = UIEdgeInsets(top: 200, left: 200, bottom: 200, right: 200)
                imageView.image = image
                imageView.setImageWithInsets(image: image!, insets: insets)
            }else if imageView == self.editImage {
                let image = UIImage(named: "edit_icon")
                let insets = UIEdgeInsets(top: 200, left: 200, bottom: 200, right: 200)
                imageView.setImageWithInsets(image: image!, insets: insets)
            }else if imageView == self.deleteImage {
                let image = UIImage(named: "delete")
                let insets = UIEdgeInsets(top: 200, left: 200, bottom: 200, right: 200)
                imageView.setImageWithInsets(image: image!, insets: insets)
            }
        }
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [self.viewImage, self.editImage, self.deleteImage])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.viewImage.widthAnchor.constraint(equalTo: self.viewImage.heightAnchor),
            self.editImage.widthAnchor.constraint(equalTo: self.editImage.heightAnchor),
            self.deleteImage.widthAnchor.constraint(equalTo: self.deleteImage.heightAnchor),
        ])
    }
    
}
