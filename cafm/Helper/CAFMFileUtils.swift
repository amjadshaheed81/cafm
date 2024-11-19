//
//  CAFMFileUtils.swift
//  cafm
//
//  Created by NS on 22/09/24.
//  
//

import UIKit
import Alamofire
import SCLAlertView

final class CAFMFileUtils: NSObject {
    static let shared = CAFMFileUtils()
    private override init() { }
    
    // Download and Share file
    func downloadAndShareFile(_ urlStr: String?, from viewController: UIViewController, sender: UIView, shouldDeleteAfterSharing: Bool = false) {
        let loadingAlert = SCLAlertView(appearance: loadingSCLAppearance)
        loadingAlert.showLoading(title: "Downloading File...")
        self.downloadFile(urlStr) { [weak self] fileURL in
            guard let self else { return }
            loadingAlert.hideView()
            if let fileURL {
                self.shareFile(from: viewController, fileURL: fileURL, sender: sender, shouldDeleteAfterSharing: shouldDeleteAfterSharing)
            }
        }
    }
    
    // Download file
    func downloadFile(_ urlStr: String?, completion: @escaping (URL?) -> Void) {
        guard let urlStr, let url = URL(string: urlStr) else {
            completion(nil)
            return
        }
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        
        let destination: DownloadRequest.Destination = { _, _ in
            let fileManager = FileManager.default
            var fileURL = documentDirectory().appendingPathComponent("\(fileName)").appendingPathExtension("\(fileExtension)")
            var count = 1
            while fileManager.fileExists(atPath: fileURL.path) {
                fileURL = documentDirectory().appendingPathComponent("\(fileName)-\(count)").appendingPathExtension("\(fileExtension)")
                count += 1
            }
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination).response { response in
            if response.error == nil, response.fileURL != nil {
                completion(response.fileURL)
            }else {
                completion(nil)
            }
        }
    }
    
    // Share file
    func shareFile(from viewController: UIViewController, fileURL: URL, sender: UIView, shouldDeleteAfterSharing: Bool = false) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityController.completionWithItemsHandler = { _, _, _, _ in
            if shouldDeleteAfterSharing {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityController.modalPresentationStyle = .popover
            activityController.popoverPresentationController?.sourceRect = sender.convert(sender.bounds, to: viewController.view)
            activityController.popoverPresentationController?.sourceView = viewController.view
        }
        
        viewController.present(activityController, animated: true)
    }
    
}
