//
//  ScanViewController.swift
//  ScanCode
//
//  Created by Sneha gindi on 15/04/17.
//  Copyright © 2017 Sneha Gindi. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var qrcode: UILabel!
    @IBOutlet weak var codelabel: UILabel!
    
        var captureSession:AVCaptureSession?
        var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
        var qrCode:UIView?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.configureVideoCapture()
            self.addVideoPreviewLayer()
            self.initializeQRView()
        }
        
        func configureVideoCapture() {
            let objCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            var error:NSError?
            let objCaptureDeviceInput: AnyObject!
            do {
                objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
                
            } catch let error1 as NSError {
                error = error1
                objCaptureDeviceInput = nil
            }
            if (error != nil) {
                let alertView:UIAlertView = UIAlertView(title: "Device Error", message:"Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done")
                alertView.show()
                return
            }
            captureSession = AVCaptureSession()
            captureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
            let objCaptureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(objCaptureMetadataOutput)
            objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        func addVideoPreviewLayer() {
            captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            captureVideoPreviewLayer?.frame = view.layer.bounds
            self.view.layer.addSublayer(captureVideoPreviewLayer!)
            captureSession?.startRunning()
            self.view.bringSubview(toFront: codelabel)
            self.view.bringSubview(toFront: qrcode)
        }
        
        func initializeQRView() {
            qrCode = UIView()
            qrCode?.layer.borderColor = UIColor.red.cgColor
            qrCode?.layer.borderWidth = 5
            self.view.addSubview(qrCode!)
            self.view.bringSubview(toFront: qrCode!)
        }
        
        func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
            if metadataObjects == nil || metadataObjects.count == 0 {
                qrCode?.frame = CGRect.zero
                codelabel.text = "NO QRCode text detected"
                return
            }
            let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
                let objBarCode = captureVideoPreviewLayer?.transformedMetadataObject(for: objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                qrCode?.frame = objBarCode.bounds;
                if objMetadataMachineReadableCodeObject.stringValue != nil {
                    codelabel.text = objMetadataMachineReadableCodeObject.stringValue
                }
            }
        }
}
