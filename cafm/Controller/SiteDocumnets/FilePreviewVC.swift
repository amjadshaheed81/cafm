//
//  FilePreviewVC.swift
//  cafm
//
//  Created by ShitaRam on 02/09/24.
//

import UIKit
import ImageScrollView
import SCLAlertView
import Photos

class FilePreviewVC: UIViewController {

    @IBOutlet weak var viewScalten: UIView!
    @IBOutlet weak var imageView: ImageScrollView!
    
    var url: URL?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewScalten.isSkeletonable = true
        viewScalten.showSkeleton(usingColor: .lightGray)
        viewScalten.startSkeletonAnimation()
        if let url = url {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    viewScalten.isHidden = true
                    viewScalten.stopSkeletonAnimation()
                    if let image = image {
                        self.image = image
                        self.imageView.display(image: image)
                    }else {
                        SCLAlertView().showError("", subTitle: "Unable to download File please try again")
                    }
                }
            }
        }
    }
        
    @IBAction func btnDowanloadClick(_ sender: Any) {
        if let image = self.image {
            self.saveImageToPhotos(image: image) { [weak self] isSave, error in
                DispatchQueue.main.async { [weak self] in
                    if isSave {
                        SCLAlertView().showSuccess("", subTitle: "Saved Successfully")
                    }else {
                        SCLAlertView().showError("", subTitle: "Unable to download File please try again")
                    }
                }
            }
        }else {
            if let url = url {
                downloadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        viewScalten.isHidden = true
                        viewScalten.stopSkeletonAnimation()
                        if let image = image {
                            self.image = image
                            self.imageView.display(image: image)
                            self.saveImageToPhotos(image: image) { [weak self] isSave, error in
                                DispatchQueue.main.async { [weak self] in
                                    if isSave {
                                        SCLAlertView().showSuccess("", subTitle: "Saved Successfully")
                                    }else {
                                        SCLAlertView().showError("", subTitle: "Unable to download File please try again")
                                    }
                                }
                            }
                        }else {
                            SCLAlertView().showError("", subTitle: "Unable to download File please try again")
                        }
                    }
                }
            }

        }
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func saveImageToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        // Request authorization to save to Photos Library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "com.yourapp.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied to access Photos Library."]))
                }
                return
            }

            // Save the image to Photos Library
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }

}

func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    // Create a URLSession data task to download the image
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Check for any errors
        if let error = error {
            print("Error downloading image: \(error)")
            completion(nil)
            return
        }
        
        // Check if the response is valid and data is received
        guard let data = data, let image = UIImage(data: data) else {
            print("Failed to convert data to image")
            completion(nil)
            return
        }
        
        // Image downloaded successfully
        completion(image)
    }
    
    // Start the download task
    task.resume()
}

