//
//  FileViewVC.swift
//  cafm
//
//  Created by NS on 01/09/24.
//
//

import UIKit
import PDFKit
import ImageScrollView
import SDWebImage

class FileViewVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var fileURL: URL?
    var image: UIImage?
    
    var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.mainView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                self.emptyView.isHidden = false
                self.mainView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar()
        self.emptyView.delegate = self
        
        if let fileURL {
            if fileURL.pathExtension == "pdf" {
                self.setupPDFView(fileURL)
            }else {
                self.setupImageScrollView(fileURL)
            }
        }else {
            self.loadingStatus = .failed
        }
    }
    
    func configureNavigationBar() {
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        let downloadBtn = UIButton(type: .system)
        downloadBtn.addCorner()
        downloadBtn.backgroundColor = UIColor(appColor: .AppTint)
        downloadBtn.tintColor = UIColor.white
        downloadBtn.setTitle("Download", for: .normal)
        downloadBtn.titleLabel?.font = UIFont(name: .MontserratMedium, size: 15)
        downloadBtn.frame = CGRect(x: 0, y: 0, width: 8+79+8, height: 32)
        downloadBtn.addTarget(self, action: #selector(self.navDownloadBtnClicked(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadBtn)
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func navDownloadBtnClicked(_ sender: UIButton) {
        guard let serverURL = self.fileURL else { return }
        
        var data: Data?
        if let image = self.image, let imageData = image.jpegData(compressionQuality: 1.0) {
            data = imageData
        }else if let document = pdfView.document, let pdfData = document.dataRepresentation() {
            data = pdfData
        }
        
        if let data {
            let fileName = serverURL.lastPathComponent
            let fileURL = documentDirectory().appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL, options: .atomic)
                shareFile(filePath: fileURL)
            } catch {
                print("Failed to create CSV file: \(error)")
            }
        }
    }
    
    func shareFile(filePath: URL) {
        if FileManager.default.fileExists(atPath: filePath.path) {
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [filePath], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
                guard self != nil else { return }
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceRect = self.navigationController?.navigationBar.frame ?? CGRect.zero
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.permittedArrowDirections = .any
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func setupPDFView(_ url: URL) {
        self.pdfView.isHidden = false
        self.pdfView.backgroundColor = UIColor.white
        self.pdfView.autoScales = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            guard let data = data, error == nil else {
                strongSelf.loadingStatus = .failed
                return
            }
            DispatchQueue.main.async {
                if let document = PDFDocument(data: data) {
                    strongSelf.pdfView.document = document
                } else {
                    strongSelf.loadingStatus = .failed
                }
            }
        }.resume()
    }
    
    func setupImageScrollView(_ url: URL) {
        self.imageScrollView.isHidden = false
        self.imageScrollView.setup()
        
        self.loadingStatus = .loading
        SDWebImageDownloader.shared.downloadImage(with: url) { [weak self] image, error, _, _ in
            guard let strongSelf = self else { return }
            if let image = image {
                strongSelf.loadingStatus = .default
                strongSelf.image = image
                strongSelf.imageScrollView.display(image: image)
            }else {
                strongSelf.loadingStatus = .failed
            }
        }
    }
    
}

extension FileViewVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            
        }
    }
}
