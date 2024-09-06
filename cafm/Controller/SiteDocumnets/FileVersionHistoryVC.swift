//
//  FileVersionHistoryVC.swift
//  cafm
//
//  Created by ShitaRam on 02/09/24.
//

import UIKit
import SpreadsheetView
import Photos
import SCLAlertView
import PhotosUI

class FileVersionHistoryVC: UIViewController, UITextFieldDelegate, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var viewFolderTFXib: TextFiledDataXib!
    @IBOutlet weak var viewFileNameTFXib: TextFiledDataXib!
    @IBOutlet weak var viewSpread: SpreadsheetView!
    @IBOutlet weak var lblSelectedFile: UILabel!
    
    @IBOutlet weak var viewMainBgBtn: UIView!
    
    @IBOutlet weak var heighOFFolderView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOFFileName: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfBtnChhose: NSLayoutConstraint!
    
    var folderName = ""
    var folderId: Int?
    var fileID: Int?
    var selectedFile: File?
    var selectedImageFile: URL?
    var originalName: String?
    var homeVC: DocumnetsVC?
    
    var isPreview = false
    
    var loadingStatus: LoadingStatus = .loading
    
    var versionFileHistory: VersionHistoryResponse?
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var headerRow: [String] = ["File", "Version", "Uploaded By", "Date", "Action"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPreview {
            self.viewFolderTFXib.isHidden = true
            self.viewFileNameTFXib.isHidden = true
            self.viewMainBgBtn.isHidden = true
            self.heighOFFolderView.constant = 0
            self.heightOFFileName.constant = 0
            self.heightOfBtnChhose.constant = 0
        }
        viewFolderTFXib.lblTFName.text = "Folder"
        viewFolderTFXib.tfData.text = folderName
        viewFolderTFXib.tfData.backgroundColor = UIColor(.separator)
        self.viewFolderTFXib.tfData.isUserInteractionEnabled = false
        
        viewFileNameTFXib.lblTFName.text = "File Name"
        viewFileNameTFXib.tfData.delegate = self
        viewFileNameTFXib.tfData.text = selectedFile?.name
        if let id = self.selectedFile?.id {
            fetchData(id: id)
        }
        viewSpread.register(UINib(nibName: String(describing: FolderViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewXib.self))
        viewSpread.register(UINib(nibName: String(describing: FolderViewImgXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewImgXib.self))
        viewSpread.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpread.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))

        viewSpread.delegate = self
        viewSpread.dataSource = self
    }
    
    func fetchData(id: Int) {
        loadingStatus = .loading
        reloadCollection()
        let apiData = ApiService.versionHistoryOFFile(id: id)
        APIClient.request(apiData) { [weak self] (result: Result<APIClient.MappableResult<VersionHistoryResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let documentResponse) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.loadingStatus = .default
                        self.versionFileHistory = documentResponse
                        self.reloadCollection()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self?.loadingStatus = .failed
                self?.reloadCollection()
            }
        }
    }
    
    func reloadCollection() {
        viewSpread.reloadData()
    }
    
    @IBAction func btnSave(_ sender: Any) {
        if loadingStatus != .default {
            return
        }
        if selectedImageFile == nil {
            showAlert(message: "Please select the file")
            return
        }
        if let text = self.viewFileNameTFXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            
        }else {
            showAlert(message: "Please enter file name")
        }
        
        var req = FileUploadRequest()
        req.folderId = folderId
        var fileRequest = FileRequest()
        fileRequest.id = self.fileID
        fileRequest.name = (self.viewFileNameTFXib.tfData.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknow")+".png"
        fileRequest.originalFileName = originalName
        fileRequest.fileVersion = (self.versionFileHistory?.files?.count ?? 1) + 1
        fileRequest.siteId = 1
        fileRequest.uploaderUserId = UserConstants.shared.currentUserID
        fileRequest.reviewerUserId = UserConstants.shared.currentUserID
        fileRequest.referenceNumber = ""
        req.files = [fileRequest]
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.uploadFileNewVersion
        APIClient.uploadFileNewVersion(service: api, fileURL: selectedImageFile!, documentRequest: req, completion: { [weak self] isSucess in
            DispatchQueue.main.async { [weak self] in
                scl.hideView()
                guard let self else {return}
                if isSucess {
                    let sclAlertView = SCLAlertView()
                    sclAlertView.showSuccess("", subTitle: "Upload successfully.")
                    if let id = folderId {
                        homeVC?.fetchData(id: id)
                    }
                    self.dismiss(animated: true)
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        })
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
                    if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                        let imageSize = imageData.count
                        let maxFileSize = 1 * 1024 * 1024 // 1 MB in bytes
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            if imageSize > maxFileSize {
                                // Image size exceeds 1 MB, show an alert
                                showAlert(message: "The selected image size is more than 1 MB. Please select a smaller image.")
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
                                    self.lblSelectedFile.text = " \(fileURL.lastPathComponent)"
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
    
    // Function to show an alert with a message
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSelectFile(_ sender: Any) {
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
        if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
            let imageSize = imageData.count
            let maxFileSize = 1 * 1024 * 1024 // 1 MB in bytes
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if imageSize > maxFileSize {
                    // Image size exceeds 1 MB, show an alert
                    self.showAlert(message: "The selected image size is more than 1 MB. Please select a smaller image.")
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
                        self.lblSelectedFile.text = " \(fileURL.lastPathComponent)"
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
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRow.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            return 1+(versionFileHistory?.files?.count ?? 0)
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray = [headerRow[column]]
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            break
        }
        if (versionFileHistory?.files?.count ?? 0) > 0 {
            switch column {
            case 0:
                var array = [headerRow[column]]
                array.append(contentsOf: self.versionFileHistory?.files?.compactMap({$0.name}) ?? [])
                let headerWidth = getMaxLabelSize(textArray: array, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition:  5+35+5+5, maxWidth: 250).width
                return headerWidth
            case 1,2,3,4:
                var stringsArray = [headerRow[column]]
                if column == 1 {
                    // no need
                }else if column == 2 {
                    stringsArray.append(contentsOf: self.versionFileHistory?.files?.compactMap({$0.uploaderUserName}) ?? [])
                }else if column == 3 {
                    stringsArray.append(contentsOf: self.versionFileHistory?.files?.compactMap({convertDateString($0.issueDate)}) ?? [])
                }else if column == 4 {
                    // no need
                }
                return max(getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width,30)
            default:
                return getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
            }
        }else {
            return 30
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let textArray = headerRow
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = headerRow
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 60)
                let heightAdditionOther: CGFloat = 10+10
                let minHeight = refSize.height-heightAdditionOther
                var optionArray = [String?]()
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                optionArray.append(contentsOf: [
                    self.versionFileHistory?.files?[row-1].name,
                    self.versionFileHistory?.files?[row-1].uploaderUserName,
                    convertDateString(self.versionFileHistory?.files?[row-1].issueDate)
                ])
                let textArrayA = optionArray.compactMap{$0}
                let otherHeight = getMaxLabelSize(textArray: textArrayA, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAdditionOther).height
                return otherHeight

            }
        }
    }
    
    func cellBorderSetUp(cell: Cell, isHeader: Bool) {
        if isHeader {
            cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.backgroundColor = UIColor(appColor: .AppTint)
        }else {
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = .white
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: true)
            cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        }else if indexPath.row == 1 && isDataNotRecive {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = loadingStatus.rawValue
            return cell
        }else {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.setUpDocView(isForVersionHistory: true)
                cell.lblFolderName.text = self.versionFileHistory?.files?[indexPath.row-1].name
                cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.btnFolder.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let vc = documnetSB.instantiateViewController(withIdentifier: "FilePreviewVC") as! FilePreviewVC
                        let urlString = self.versionFileHistory?.files?[indexPath.row-1].fileBlobUrl ?? ""
                        vc.url = URL(string: urlString)
                        self.present(vc, animated: true)
                    }
                }
                return cell
            case 1,2,3:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                var text: String? = ""
                if indexPath.column == 1 {
                    text = "\(self.versionFileHistory?.files?[indexPath.row-1].fileVersion ?? 0)"
                }else if indexPath.column == 2 {
                    text = self.versionFileHistory?.files?[indexPath.row-1].uploaderUserName
                }else if indexPath.column == 3 {
                    text = convertDateString(self.versionFileHistory?.files?[indexPath.row-1].issueDate)
                }
                cell.lblText.text = text
                cell.lblText.textColor = .black
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                return cell
            case 4:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewImgXib", for: indexPath) as! FolderViewImgXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.btnPreview.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        let vc = documnetSB.instantiateViewController(withIdentifier: "FilePreviewVC") as! FilePreviewVC
                        let urlString = self.versionFileHistory?.files?[indexPath.row-1].fileBlobUrl ?? ""
                        vc.url = URL(string: urlString)
                        self.present(vc, animated: true)
                    }
                }
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = "-"
                cell.lblText.textColor = .black
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                return cell
            }
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRow.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if (loadingStatus == .noInternet || loadingStatus == .failed) {
            if let id = self.selectedFile?.id {
                self.fetchData(id: id)
            }
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    

    
}
