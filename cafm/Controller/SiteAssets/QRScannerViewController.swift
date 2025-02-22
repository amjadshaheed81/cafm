//
//  QRScannerViewController.swift
//  cafm
//
//  Created by Savan Lakhani on 09/12/24.
//

import UIKit
import AVFoundation
    
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var mainViewCamera: UIView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var complition: ((_ assetId: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize capture session
        captureSession = AVCaptureSession()
        
        // Set up camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoDeviceInput: AVCaptureDeviceInput
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Add video input to session
        if (captureSession.canAddInput(videoDeviceInput)) {
            captureSession.addInput(videoDeviceInput)
        } else {
            return
        }
        
        // Set up metadata output (to capture QR codes)
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Add metadata output to session
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            // Set delegate to self and specify the dispatch queue
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // We only want to scan QR codes
        } else {
            return
        }
        
        // Set up preview layer to show camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        mainViewCamera.layer.addSublayer(previewLayer)
        
        // Start capturing
        captureSession.startRunning()
    }
    
    
    // This delegate method will be called when a QR code is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // If no metadata objects are found, exit the function
        
        captureSession.stopRunning()

        
        if metadataObjects.count == 0 {
            captureSession.startRunning()
            return
        }
        

        // Get the first metadata object (QR code)
        guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            captureSession.startRunning()
            return
        }
        
        // Check if the metadata object is a QR code
        guard let readableObject = previewLayer?.transformedMetadataObject(for: metadataObject) else {
            captureSession.startRunning()
            return
        }
        
        // Process QR code
        if let stringValue = metadataObject.stringValue {
            //            foundQRCode(stringValue)
            
            if let assetId = extractAssetId(from: stringValue) {
                passFunction(with: assetId)
            }else {
                captureSession.startRunning()
            }
        }else {
            captureSession.startRunning()
        }
    }
    
    func extractAssetId(from urlString: String) -> Int? {
        // Split the URL at the '#', only consider the part after the '#'
        guard let url = URL(string: urlString),
              let fragment = url.fragment else {
            return nil
        }

        // Now, parse the fragment part like a query string
        let fragmentString = "?" + fragment  // Adding a '?' to make it look like a query string

        // Parse the fragment string into URL components
        if let urlComponents = URLComponents(string: fragmentString),
           let queryItems = urlComponents.queryItems {
            // Find the assetId parameter
            if let assetId = queryItems.first(where: { $0.name.lowercased() == "/view-asset?assetId".lowercased() })?.value {
                return Int(assetId)
            }
        }

        return nil
    }

    // Function that gets called after extracting assetId
    func passFunction(with assetId: Int) {
        print("Asset ID: \(assetId)")
        self.complition?(assetId)
        self.dismiss(animated: true)
    }

    
    // Handle QR code found
    func foundQRCode(_ qrCode: String) {
        print("QR Code found: \(qrCode)")
        
        // You can perform any action with the QR code here, for example, open a URL:
        if let url = URL(string: qrCode) {
            UIApplication.shared.open(url)
        }
    }
    
    // This will stop the camera session when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func btnTouchUpClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}



//{
//    
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
//    var captureSession: AVCaptureSession!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Initialize the capture session
//        captureSession = AVCaptureSession()
//
//        // Set up the device (camera)
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
//        let videoDeviceInput: AVCaptureDeviceInput
//
//        do {
//            // Create input from the camera device
//            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//        } catch {
//            print("Error setting up camera input: \(error)")
//            return
//        }
//
//        // Check if the input can be added to the session
//        if (captureSession.canAddInput(videoDeviceInput)) {
//            captureSession.addInput(videoDeviceInput)
//        } else {
//            print("Unable to add camera input to the session.")
//            return
//        }
//
//        // Set up metadata output (QR code scanning)
//        let metadataOutput = AVCaptureMetadataOutput()
//
//        if (captureSession.canAddOutput(metadataOutput)) {
//            captureSession.addOutput(metadataOutput)
//
//            // Set the delegate to handle metadata
//            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//        } else {
//            print("Unable to add metadata output to the session.")
//            return
//        }
//
//        // Set up the preview layer to show the camera feed
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        videoPreviewLayer.frame = view.layer.bounds
//        videoPreviewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(videoPreviewLayer)
//
//        // Start the capture session
//        captureSession.startRunning()
//    }
//
//    // Delegate method to handle the QR code detection
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        // If there's no metadata, return
//        if metadataObjects.isEmpty { return }
//        
//        // Get the first object in the metadata array
//        guard let metadataObject = metadataObjects.first else { return }
//        
//        // Get the readable QR code object
//        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
//        
//        // Get the string value of the QR code
//        guard let qrCodeString = readableObject.stringValue else { return }
//        
//        // Call the function with the extracted assetId
//        if let assetId = extractAssetId(from: qrCodeString) {
//            passFunction(with: assetId)
//        }
//    }
//
//    // Function to extract assetId from the URL
//    func extractAssetId(from urlString: String) -> String? {
//        guard let url = URL(string: urlString),
//              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
//            return nil
//        }
//        
//        // Find the assetId parameter
//        if let assetId = queryItems.first(where: { $0.name == "assetId" })?.value {
//            return assetId
//        }
//        
//        return nil
//    }
//
//    // Function that gets called after extracting assetId
//    func passFunction(with assetId: String) {
//        print("Asset ID: \(assetId)")
//        
//        // Your logic here, for example, navigating to another view or making a network request
//        // Example: navigate to another view controller
//        // let nextVC = YourNextViewController(assetId: assetId)
//        // navigationController?.pushViewController(nextVC, animated: true)
//    }
//}
