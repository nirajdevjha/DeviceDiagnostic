//
//  CaptureScreenViewController.swift
//  DeviceDiagnostic
//
//  Created by Niraj Jha on 22/09/18.
//  Copyright © 2018 Niraj Jha. All rights reserved.
//

import UIKit
import AVFoundation

protocol CapturedPhotoDelegate:class {
    func cameraResult(isCameraWorking:Bool)
}
class CaptureScreenViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureBtn: UIButton!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate:CapturedPhotoDelegate?
    // MARK: - Self methods
    override func viewDidLoad() {
        super.viewDidLoad()
        captureBtn.layer.cornerRadius = 10.0
        captureBtn.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupPreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- public methods
    class func storyboardInstance() -> CaptureScreenViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CaptureScreen") as! CaptureScreenViewController
        return vc
    }
    
    //MARK:- private methods
    func setupPreview() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspect
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(cameraPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            self.cameraPreviewLayer.frame = self.cameraView.bounds
        }
    }

    //MARK:- Button action methods
    @IBAction func captureImage(_ sender: Any) {
        if #available(iOS 11.0, *) {
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                 stillImageOutput.capturePhoto(with: settings, delegate: self)
        } else {
            //handling for iOS 10 and below
        }
    }
    
}

extension CaptureScreenViewController:AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
            else { return }
       UserDefaults.standard.set(imageData, forKey: "CAPTUREDPHOTO")
        self.delegate?.cameraResult(isCameraWorking: true)
//        let image = UIImage(data: imageData)
        //
        
    }
}
