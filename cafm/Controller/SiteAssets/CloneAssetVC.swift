//
//  CloneAssetVC.swift
//  cafm
//
//  Created by Savan Lakhani on 07/09/24.
//

import UIKit
import PDFKit
import SCLAlertView

class CloneAssetVC: UIViewController {
    
    @IBOutlet weak var txField1: TextFiledDataXib!
    @IBOutlet weak var txField2: TextFiledDataXib!
    @IBOutlet weak var txField3: TextFiledDataXib!
    
    @IBOutlet weak var errorViewLbl: UILabel!
    @IBOutlet weak var errorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var actionBtnView: ActionBtnViewXIB!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var decreaseLbl: UILabel!
    @IBOutlet weak var increaseLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    var value: Int = 0 {
        didSet {
            self.txField3.tfData.text = "\(value)"
        }
    }
    
    var assetID: Int?
    var assetName: String?
    var manufacture: String?
    var qrImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = "Clone Asset"
        self.titleLbl.adjustsFontSizeToFitWidth = true
                
        if self.qrImage != nil, let assetName = self.assetName {
            self.titleLbl.text = "\(assetName) - Asset QR Code"
        }
        
        self.value = 0
        
        self.txField1.lblTFName.text = "Asset Name"
        self.txField2.lblTFName.text = "Manufacturer"
        self.txField3.lblTFName.text = "Select Number of Clones to Create"
        
        self.txField1.tfData.text = self.assetName ?? ""
        self.txField2.tfData.text = self.manufacture ?? ""
        
        self.actionBtnView.saveBtn.setTitle("Clone", for: .normal)
        
        if self.qrImage != nil {
            self.qrImageView.image = self.qrImage
            self.stackView.isHidden = true
            self.txField1.isHidden = true
            self.txField2.isHidden = true
            self.txField3.isHidden = true
            self.errorView.isHidden = true
            self.actionBtnView.saveBtn.setTitle("Print", for: .normal)
        }
        
        self.txField1.tfData.isEnabled = false
        self.txField1.tfData.isSelected = false
        self.txField2.tfData.isSelected = false
        self.txField2.tfData.isEnabled = false
        self.txField2.tfData.backgroundColor = .lightGray.withAlphaComponent(0.3)
        self.txField1.tfData.backgroundColor = .lightGray.withAlphaComponent(0.3)
        
        self.errorViewLbl.font = UIFont(name: .MontserratRegular, size: 18)
        self.errorViewLbl.adjustsFontSizeToFitWidth = true
        self.errorView.addCorner()
        self.errorView.backgroundColor = .orange.withAlphaComponent(0.1)
        self.errorView.addShadow()
        
        self.stackView.addCorner(value: 3)
        
        self.setupUI()
        self.actionBtnView.saveBtn.addTarget(self, action: #selector(cloneBtnTapped), for: .touchUpInside)
        self.actionBtnView.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
    }
    
    func exportPDF(with qrImage: UIImage, headerTitle: String) {
        let pdfMetaData = [
            kCGPDFContextCreator: "cafm",
            kCGPDFContextAuthor: "cafm"
        ]
        
        // Create a CGRect representing the size of the PDF
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        
        // PDF Renderer
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageBounds, format: UIGraphicsPDFRendererFormat())
        
        let pdfData = pdfRenderer.pdfData { (context) in
            context.beginPage()
            
            // Define header frame
            let headerFrame = CGRect(x: 20, y: 20, width: 300, height: 40)
            
            // Draw the header title
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            headerTitle.draw(in: headerFrame, withAttributes: headerAttributes)
            
            // Draw the separator
            let separatorY: CGFloat = headerFrame.maxY + 10
            let separator = UIBezierPath(rect: CGRect(x: 20, y: separatorY, width: pageBounds.width - 40, height: 1))
            UIColor.lightGray.setFill()
            separator.fill()
            
            // Draw the QR code image below the separator
            let qrSize: CGFloat = 300
            let qrFrame = CGRect(x: (pageBounds.width - qrSize) / 2, y: separatorY + 20, width: qrSize, height: qrSize)
            qrImage.draw(in: qrFrame)
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let pdfFilename = "QR_PDF.pdf"
        let pdfFileURL = tempDirectory.appendingPathComponent(pdfFilename)
        
        do {
            try pdfData.write(to: pdfFileURL)
            
            let activityViewController = UIActivityViewController(activityItems: [pdfFileURL], applicationActivities: nil)
            
            self.present(activityViewController, animated: true, completion: nil)
            
        } catch {
            print("Could not save the PDF file: \(error)")
        }
    }

    @objc func cloneBtnTapped() {
        if let qrImage = self.qrImage, let assetName = self.assetName {
            self.exportPDF(with: qrImage, headerTitle: "\(assetName) - Asset QR Code")
        }else if let assetID = self.assetID, value != 0 {
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false // if you dont want the close button use false
            )
            let sclAlert = SCLAlertView(appearance: appearance)
            sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
            
            let apiService = ApiService.cloneAssets(assetId: assetID, numberOfClone: value)
            
            APIClient.requestWithCode(apiService) { [weak self] isSuccess, code in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    sclAlert.hideView()
                    if code == 200 {
                        SCLAlertView().showSuccess("", subTitle: "Asset cloning is successfully completed.")
                    }else {
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                }
            }
        }else if value == 0 {
            SCLAlertView().showInfo("", subTitle: "Please select number of clones to create")
        }
    }
    
    func printImage(image: UIImage) {
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "Print QR"
        
        printController.printInfo = printInfo
        printController.printingItem = image
        
        printController.present(animated: true, completionHandler: nil)
    }
    
    
    @IBAction func closeClick(_ sender: Any) {
        self.cancelBtnTapped()
    }
    
    @objc func cancelBtnTapped() {
        self.dismiss(animated: true)
    }
    
    func setupUI() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let increaseTap = UITapGestureRecognizer(target: self, action: #selector(increaseValue))
        increaseTap.numberOfTapsRequired = 1
        self.increaseLbl.addGestureRecognizer(increaseTap)
        
        let decreaseTap = UITapGestureRecognizer(target: self, action: #selector(decreaseValue))
        decreaseTap.numberOfTapsRequired = 1
        self.decreaseLbl.addGestureRecognizer(decreaseTap)
        
        // Set up constraints for the label and stack view
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: txField3.tfData.trailingAnchor, constant: -30),
            self.stackView.centerYAnchor.constraint(equalTo: txField3.tfData.centerYAnchor),
            self.stackView.widthAnchor.constraint(equalToConstant: 20),
            self.stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    // Method to increase the value
    @objc func increaseValue() {
        value += 1
    }
    
    // Method to decrease the value
    @objc func decreaseValue() {
        if value > 0 {
            value -= 1
        }
    }
    
}
