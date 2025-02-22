//
//  CAFMFilePicker.swift
//  cafm
//
//  Created by NS on 13/09/24.
//
//

import UIKit
import PhotosUI
import SCLAlertView

struct FilePickerModel {
    var fileName: String?
    var image: UIImage?
    var fileURL: URL?
}

final class CAFMFilePicker: NSObject {
    
    weak var delegate: CAFMFilePickerDelegate?
    
    init(delegate: CAFMFilePickerDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    // Set file picker menu
    func configureFileMenu(on viewController: UIViewController, sender: UIButton, tag: Int, allowPhotos: Bool = true, supportedTypes: [UTType] = [.image, .pdf]) {
        if allowPhotos {
            var menuItems: [UIMenuElement] = []
            
            // Camera action
            let cameraAction = UIAction(title: "Camera", image: UIImage(systemName: "camera.fill")) { _ in
                self.presentCamera(from: viewController, tag: tag)
            }
            menuItems.append(cameraAction)
            
            // Photos action
            let photosAction = UIAction(title: "Photos", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) { _ in
                self.presentPhotoPicker(from: viewController, tag: tag)
            }
            menuItems.append(photosAction)
            
            // Files action
            let filesAction = UIAction(title: "Files", image: UIImage(systemName: "folder.fill")) { _ in
                self.presentDocumentPicker(from: viewController, tag: tag, supportedTypes: supportedTypes)
            }
            menuItems.append(filesAction)
            
            let menu = UIMenu(title: "Select", children: menuItems)
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
        } else {
            sender.addAction {
                self.presentDocumentPicker(from: viewController, tag: tag, supportedTypes: supportedTypes)
            }
        }
    }
    
    // Present camera
    private func presentCamera(from viewController: UIViewController, tag: Int) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            //SCLAlertView().showError("Error", subTitle: "Camera is not available.")
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = self
        cameraPicker.view.tag = tag
        viewController.present(cameraPicker, animated: true)
    }
    
    // Present photo picker
    private func presentPhotoPicker(from viewController: UIViewController, tag: Int) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.view.tag = tag
        viewController.present(picker, animated: true)
    }
    
    // Present document picker
    private func presentDocumentPicker(from viewController: UIViewController, tag: Int, supportedTypes: [UTType]) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        documentPicker.delegate = self
        documentPicker.view.tag = tag
        viewController.present(documentPicker, animated: true)
    }
    
    func handlePickedImage(_ pickedImage: UIImage, fromURL fileURL: URL, tag: Int) {
        // Implement the logic you had for handling a single image
        // Fetch the file name from the URL
        let fileName = fileURL.lastPathComponent
        print("Selected image name: \(fileName)")
        
        // Check the image size and proceed similarly to your original code
        if let imageData = pickedImage.jpegData(compressionQuality: 0.8) {
            let imageSize = imageData.count
            let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if imageSize > maxFileSize {
                    // Image size exceeds 1 MB, show an alert
                    SCLAlertView().showError("Error", subTitle: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
                } else {
                    print("Image size is within the limit: \(imageSize) bytes")
                    self.delegate?.filePickerDidSelectFile(FilePickerModel(fileName: fileName, image: pickedImage, fileURL: nil), tag: tag)
                }
            }
        }
    }
    
}

let uploadMaxSize = 20

extension CAFMFilePicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self else { return }
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    SCLAlertView().showError("Error", subTitle: "Please try again")
                    return
                }
                
                if let pickedImage = image as? UIImage {
                    // Fetch the asset associated with the picked image
                    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] (url, error) in
                            guard let self else { return }
                            guard let fileURL = url else {
                                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                SCLAlertView().showError("Error", subTitle: "Please try again")
                                return
                            }
                            // Process the image here as needed
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                self.handlePickedImage(pickedImage, fromURL: fileURL, tag: picker.view.tag)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

extension CAFMFilePicker: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let fileName = url.lastPathComponent
        
        do {
            let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            let maxFileSize = uploadMaxSize * 1024 * 1024 // 1 MB in bytes
            if fileSize > maxFileSize {
                // Image size exceeds 1 MB, show an alert
                SCLAlertView().showError("Error", subTitle: "The selected image size is more than \(uploadMaxSize) MB. Please select a smaller image.")
            } else {
                print("Image size is within the limit: \(fileSize) bytes")
                delegate?.filePickerDidSelectFile(FilePickerModel(fileName: fileName, image: nil, fileURL: url), tag: controller.view.tag)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            SCLAlertView().showError("Error", subTitle: "Please try again")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.filePickerDidClose(tag: controller.view.tag)
    }
    
}

let minImageFileSize: CGFloat = 1080

extension UIImage {
    
    func resizeImage(targetSizeWidth: CGFloat) -> UIImage {
        var size = self.size
        size.width = size.width*self.scale
        size.height = size.height*self.scale
        
        print("image size: \(size)")
        let isPortrait = size.height > size.width
        if (isPortrait ? size.height > targetSizeWidth : size.width > targetSizeWidth) {
            let targetSize: CGSize
            if isPortrait {
                targetSize = CGSize(width: (size.width*targetSizeWidth)/size.height, height: targetSizeWidth)
            }else {
                targetSize = CGSize(width: targetSizeWidth, height: (size.height*targetSizeWidth)/size.width)
            }
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            print("new image size: \(newImage?.size)")
            
            return newImage ?? self
        }else {
            return self
        }
    }
}

extension CAFMFilePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let pickedImage = info[.originalImage] as? UIImage {
            let fileName: String
            if let asset = info[.phAsset] as? PHAsset {
                fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename ?? "file"
            }else {
                fileName = "file"
            }
            handlePickedImage(pickedImage.resizeImage(targetSizeWidth: minImageFileSize), fromURL: URL(fileURLWithPath: fileName), tag: picker.view.tag)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

protocol CAFMFilePickerDelegate: AnyObject {
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int)
    func filePickerDidClose(tag: Int)
}
