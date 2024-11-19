//
//  BulkUploadVC.swift
//  cafm
//
//  Created by ShitaRam on 02/09/24.
//

import UIKit
import PhotosUI
import SCLAlertView

class BulkUploadVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var cvView: UICollectionView!
    
    var itemArray: [URL] = []
    
    var folderName = ""
    var folderId: Int?
    var homeVC: DocumnetsVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cvView.delegate = self
        self.cvView.dataSource = self
    }
    
    @IBAction func btnSelectClick(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10 // 0 means no limit, change this to a specific number if you want to limit the selection
        configuration.filter = .images // This ensures only images are shown
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        if itemArray.isEmpty {
            showAlert(message: "Please select the file")
            return
        }
        var sucessCount = 0
        var failedCount = 0
        let totalCount = itemArray.count
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        for item in itemArray {
            var req = FileUploadRequest()
            req.folderId = folderId
            var fileRequest = FileRequest()
            fileRequest.name = item.lastPathComponent
            fileRequest.issueDate = getCurrentAndOneYearLaterDates().currentDate
            fileRequest.expiryDate = getCurrentAndOneYearLaterDates().oneYearLaterDate
            fileRequest.note = ""
            fileRequest.referenceNumber = ""
            fileRequest.fileVersion = 1
            fileRequest.siteId = 1
            fileRequest.originalFileName = item.lastPathComponent
            fileRequest.uploaderUserId = UserConstants.shared.currentUserID
            fileRequest.reviewerUserId = UserConstants.shared.currentUserID
            req.files = [fileRequest]
            let api = ApiService.uploadFileInFolder
            APIClient.uploadFileInFolder(service: api, fileURL: item, documentRequest: req, completion: { [weak self] (result: Result<APIClient.MappableResult<FileUploadResponse>, Error>) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    switch result {
                    case .success(let responseResult):
                        if case .single(let responseResult) = responseResult {
                            print(responseResult.toJSON())
                            let sclAlertView = SCLAlertView()
                            sucessCount += 1
                            if sucessCount + failedCount == totalCount {
                                scl.hideView()
                                showAlert(sucessCount: sucessCount, failedCount: failedCount)
                            }
                        }else {
                            failedCount += 1
                            if sucessCount + failedCount == totalCount {
                                scl.hideView()
                                showAlert(sucessCount: sucessCount, failedCount: failedCount)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        failedCount += 1
                        if sucessCount + failedCount == totalCount {
                            scl.hideView()
                            showAlert(sucessCount: sucessCount, failedCount: failedCount)
                        }
                    }
                }
            })
        }
    }
    
    func showAlert(sucessCount: Int, failedCount: Int) {
        let alert = UIAlertController(title: nil, message: "Total files successfully uploaded: \(sucessCount)\nTotal files failed to upload: \(failedCount)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else {return}
                self.itemArray = []
                if sucessCount > 0 {
                    self.cvView.reloadData()
                    if let id = self.folderId {
                        self.homeVC?.fetchData(id: id)
                    }
                    self.dismiss(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        let item = itemArray[indexPath.row].lastPathComponent
        cell.lblSiteName.text = item
        cell.btnRemoveSite.addAction { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let item = self.itemArray.remove(at: indexPath.row)
                self.cvView.reloadData()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = itemArray[indexPath.row].lastPathComponent ?? ""
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        let width = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).width
        return CGSize(width: min(width+40+3,self.view.frame.width-20), height: 40)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                if let pickedImage = image as? UIImage {
                    // Fetch the asset associated with the picked image
                    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                            guard let fileURL = url else {
                                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            // Process the image here as needed
                            DispatchQueue.main.async {
                                self?.handlePickedImage(pickedImage, fromURL: fileURL)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handlePickedImage(_ pickedImage: UIImage, fromURL fileURL: URL) {
        // Implement the logic you had for handling a single image
        // Fetch the file name from the URL
        let fileName = fileURL.lastPathComponent
        print("Selected image name: \(fileName)")
        
        // Check the image size and proceed similarly to your original code
        if let imageData = pickedImage.jpegData(compressionQuality: 0.8) {
            let imageSize = imageData.count
            let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if imageSize > maxFileSize {
                    // Image size exceeds 1 MB, show an alert
                    self.showAlert(message: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                } else {
                    print("Image size is within the limit: \(imageSize) bytes")
                    let name = (fileName as NSString).deletingPathExtension
                    let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                    let fileURL = documentDirectory().appendingPathComponent(newfileName)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            self.showAlert(message: "Please try again")
                            return
                        }
                    }
                    do {
                        try imageData.write(to: fileURL, options: .atomic)
                        self.itemArray.append(fileURL)
                        self.cvView.reloadData()
                    } catch {
                        self.showAlert(message: "Please try again")
                        print("Error saving image: \(error)")
                    }
                }
            }
        }
    }
    
}
