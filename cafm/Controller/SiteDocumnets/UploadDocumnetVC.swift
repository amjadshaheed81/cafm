//
//  UploadDocumnetVC.swift
//  cafm
//
//  Created by ShitaRam on 01/09/24.
//

import UIKit
import Photos
import SCLAlertView
import PhotosUI

class UploadDocumnetVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    
    @IBOutlet weak var selectFolderBtn: UIButton!
    @IBOutlet weak var viewFolderTFXib: TextFiledDataXib!
    @IBOutlet weak var viewFileNameTFXib: TextFiledDataXib!
    @IBOutlet weak var viewVersionTFXib: TextFiledDataXib!
    @IBOutlet weak var viewIssueDateTFXib: TextFiledDataXib!
    @IBOutlet weak var viewExpireDateTFXib: TextFiledDataXib!
    @IBOutlet weak var viewNoteTFXib: TextFiledDataXib!
    
    @IBOutlet weak var lblDataName: UILabel!
    
    var selectedImageFile: URL?
    var originalName: String?
    
    var folderName = ""
    var folderId: Int?
    let issueDatePicker = UIDatePicker()
    let expireDatePicker = UIDatePicker()
    
    var homeVC: DocumnetsVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFiled()
    }
    
    @IBAction func btnUploadFileClick(_ sender: Any) {
        if selectedImageFile == nil {
            showAlert(message: "Please select the file")
            return
        }
        var req = FileUploadRequest()
        req.folderId = folderId
        var fileRequest = FileRequest()
        fileRequest.name = self.viewFileNameTFXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? selectedImageFile?.lastPathComponent : (self.viewFileNameTFXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknow")+".png"
        if let issueDate = viewIssueDateTFXib.tfData.text, !issueDate.isEmpty {
            fileRequest.issueDate = convertDateStringToNewString(from: "dd/MM/yy", originalDateString: issueDate, to: "yyyy-MM-dd HH:mm:ss")
        }else {
            fileRequest.issueDate = getCurrentAndOneYearLaterDates().currentDate
        }
        if let expireDate = viewExpireDateTFXib.tfData.text, !expireDate.isEmpty {
            fileRequest.expiryDate = convertDateStringToNewString(from: "dd/MM/yy", originalDateString: expireDate, to: "yyyy-MM-dd HH:mm:ss")
        }else {
            fileRequest.expiryDate = getCurrentAndOneYearLaterDates().oneYearLaterDate
        }
        if let note = self.viewNoteTFXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty {
            fileRequest.note = note
            fileRequest.referenceNumber = note
        }else {
            fileRequest.note = ""
            fileRequest.referenceNumber = ""
        }
        fileRequest.fileVersion = 1
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        fileRequest.siteId = siteID
        fileRequest.originalFileName = selectedImageFile?.lastPathComponent
        fileRequest.uploaderUserId = UserConstants.shared.currentUserID
        fileRequest.reviewerUserId = UserConstants.shared.currentUserID
        req.files = [fileRequest]
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.uploadFileInFolder
        APIClient.uploadFileInFolder(service: api, fileURL: selectedImageFile!, documentRequest: req, completion: { [weak self] (result: Result<APIClient.MappableResult<FileUploadResponse>, Error>) in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                switch result {
                case .success(let responseResult):
                    if case .single(let responseResult) = responseResult {
                        print(responseResult.toJSON())
                        let sclAlertView = SCLAlertView()
                        sclAlertView.showSuccess("", subTitle: "Upload successfully.")
                        if let id = folderId {
                            homeVC?.fetchData(id: id)
                        }
                        self.dismiss(animated: true)
                    }else {
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        })
    }
    
    func setUpTextFiled() {
        CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: self.selectFolderBtn, tag: 1, allowPhotos: true, supportedTypes: [.image])

        viewFolderTFXib.lblTFName.text = "Folder"
        viewFolderTFXib.tfData.text = folderName
        viewFolderTFXib.tfData.backgroundColor = UIColor(.separator)
        self.viewFolderTFXib.tfData.isUserInteractionEnabled = false
        
        viewFileNameTFXib.lblTFName.text = "File Name"
        viewFileNameTFXib.tfData.delegate = self
        
        viewVersionTFXib.lblTFName.text = "Version"
        viewVersionTFXib.tfData.text = "1"
        viewVersionTFXib.tfData.backgroundColor = UIColor(.separator)
        self.viewVersionTFXib.tfData.isUserInteractionEnabled = false
        
        viewIssueDateTFXib.lblTFName.text = "Issue Date"
        viewIssueDateTFXib.tfData.delegate = self
        
        issueDatePicker.datePickerMode = .date
        issueDatePicker.preferredDatePickerStyle = .wheels // Optional: Choose the picker style
        issueDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Set the input view of the text field to the date picker
        viewIssueDateTFXib.tfData.inputView = issueDatePicker
        
        viewIssueDateTFXib.tfData.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonIssueDateClicked))

        
        viewExpireDateTFXib.lblTFName.text = "Expiry Date"
        viewExpireDateTFXib.tfData.delegate = self
        
        
        expireDatePicker.datePickerMode = .date
        expireDatePicker.preferredDatePickerStyle = .wheels // Optional: Choose the picker style
        expireDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        viewExpireDateTFXib.tfData.inputView = expireDatePicker
        
        viewExpireDateTFXib.tfData.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonExpireDateClicked))

        
        
        viewNoteTFXib.lblTFName.text = "Enter notes..."
        viewNoteTFXib.tfData.delegate = self
    }
    
    @objc func doneButtonIssueDateClicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = self.issueDatePicker.date
        viewIssueDateTFXib.tfData.text = formatter.string(from: self.issueDatePicker.date)
        if let oneYearLaterDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) {
            viewExpireDateTFXib.tfData.text = formatter.string(from: oneYearLaterDate)
        }
    }

    @objc func doneButtonExpireDateClicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = self.expireDatePicker.date
        viewExpireDateTFXib.tfData.text = formatter.string(from: self.expireDatePicker.date)
    }
    
    // Function called when the date picker value changes
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"  // Set the format to dd/MM/yy
        let selectedDate = sender.date
        
        if sender == issueDatePicker {
            viewIssueDateTFXib.tfData.text = formatter.string(from: sender.date)
            if let oneYearLaterDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) {
                self.expireDatePicker.date = oneYearLaterDate
                viewExpireDateTFXib.tfData.text = formatter.string(from: oneYearLaterDate)
            }
        }else {
            viewExpireDateTFXib.tfData.text = formatter.string(from: sender.date)
        }
    }
    
    @IBAction func btnSelectFolder(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images // This ensures only images are shown
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
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
                                self?.showAlert(message: "Please try again")
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
                    showAlert(message: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                } else {
                    print("Image size is within the limit: \(imageSize) bytes")
                    let name = (fileName as NSString).deletingPathExtension
                    let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                    let fileURL = documentDirectory().appendingPathComponent(newfileName)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            showAlert(message: "Please try again")
                            return
                        }
                    }
                    do {
                        try imageData.write(to: fileURL, options: .atomic)
                        self.lblDataName.text = " \(fileURL.lastPathComponent)"
                        self.selectedImageFile = fileURL
                        self.originalName = fileName
                    } catch {
                        showAlert(message: "Please try again")
                        print("Error saving image: \(error)")
                    }
                }
            }
        }
    }

    
    // UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            // Handle the picked image here
            
            // Fetch the asset associated with the picked image
            if let asset = info[.phAsset] as? PHAsset {
                // Request image name using PHAssetResource
                if let fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename {
                    print("Selected image name: \(fileName)")
                    
                    print("Selected the correct image!")
                    // Check if the image size exceeds 1 MB
                    if let imageData = pickedImage.jpegData(compressionQuality: 0.8) {
                        let imageSize = imageData.count
                        let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            if imageSize > maxFileSize {
                                // Image size exceeds 1 MB, show an alert
                                showAlert(message: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                            } else {
                                print("Image size is within the limit: \(imageSize) bytes")
                                let name = (fileName as NSString).deletingPathExtension
                                let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                                let fileURL = documentDirectory().appendingPathComponent(newfileName)
                                if FileManager.default.fileExists(atPath: fileURL.path) {
                                    do {
                                        try FileManager.default.removeItem(at: fileURL)
                                    } catch {
                                        showAlert(message: "Please try again")
                                        return
                                    }
                                }
                                do {
                                    try imageData.write(to: fileURL, options: .atomic)
                                    self.lblDataName.text = " \(fileURL.lastPathComponent)"
                                    self.selectedImageFile = fileURL
                                    self.originalName = fileName
                                } catch {
                                    showAlert(message: "Please try again")
                                    print("Error saving image: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnCancelClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension UploadDocumnetVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        let fileName = fileData.fileName ?? ""
        if let imageData = fileData.image?.jpegData(compressionQuality: 0.8) {
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let name = (fileName as NSString).deletingPathExtension
                let newfileName = (name.isEmpty ? UUID().uuidString : name) + ".png"
                let fileURL = documentDirectory().appendingPathComponent(newfileName)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        showAlert(message: "Please try again")
                        return
                    }
                }
                do {
                    try imageData.write(to: fileURL, options: .atomic)
                    self.lblDataName.text = " \(fileURL.lastPathComponent)"
                    self.selectedImageFile = fileURL
                    self.originalName = fileName
                } catch {
                    showAlert(message: "Please try again")
                    print("Error saving image: \(error)")
                }
            }
        }else if let fileURL = fileData.fileURL {
            self.lblDataName.text = " \(fileURL.lastPathComponent)"
            self.selectedImageFile = fileURL
            self.originalName = fileName
        }
        
    }
    
    func filePickerDidClose(tag: Int) {
        
    }
    
}
