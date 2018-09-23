//
//  ViewController.swift
//  DeviceDiagnostic
//
//  Created by Niraj Jha on 20/09/18.
//  Copyright © 2018 Niraj Jha. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController {
    
    @IBOutlet weak var micSpeakerBtn: UIButton!
    @IBOutlet weak var bluetoothBtn: UIButton!
    @IBOutlet weak var deviceSensorsBtn: UIButton!
    @IBOutlet weak var smartphoneScreenBtn: UIButton!
    @IBOutlet weak var submitAndSendResultsBtn: UIButton!
    
    //MARK:- self methods
    override func viewDidLoad() {
        super.viewDidLoad()
        formatUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- privte methods
    
    func formatUI() {
        micSpeakerBtn.layer.cornerRadius = 20.0
        micSpeakerBtn.clipsToBounds = true
        bluetoothBtn.layer.cornerRadius  = 20.0
        bluetoothBtn.clipsToBounds = true
        smartphoneScreenBtn.layer.cornerRadius = 20.0
        smartphoneScreenBtn.clipsToBounds = true
        deviceSensorsBtn.layer.cornerRadius = 20.0
        deviceSensorsBtn.clipsToBounds = true
        submitAndSendResultsBtn.layer.cornerRadius = 20.0
        submitAndSendResultsBtn.clipsToBounds = true
    }
    
    func showMailAlertError(title:String, msg:String) {
        let alertController = UIAlertController(title:title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    func configureMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        let body = "Here are the results of device diagnostics:-<br><br><p>Bluetooth:-\(UserDefaults.standard.bool(forKey: "BLUETOOTHRESULT"))<br>Mic/Speaker:-\(String(describing: UserDefaults.standard.bool(forKey: "MICSPEAKERRESULT")))<br>Device sensors:-\(UserDefaults.standard.bool(forKey: "DEVICESENSORSRESULT"))<br></p>"
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["nirajdev.jha@gmail.com"])
        mailComposerVC.setSubject("Device Diagnostic result")
        if let imageData = UserDefaults.standard.value(forKey: "CAPTUREDPHOTO"){
        mailComposerVC.addAttachmentData(imageData as! Data, mimeType: "image/png", fileName: "capturedPhoto.png")
        }
    
        mailComposerVC.setMessageBody(body, isHTML: true)
        return mailComposerVC
    }
    
    //MARK:- Button Action methods
    @IBAction func testDeviceMicAndSpeaker(_ sender: Any) {
        let micSpeakerTestVC = MicSpeakerTestViewController.storyboardInstance()
        micSpeakerTestVC.delegate = self
        self.navigationController?.pushViewController(micSpeakerTestVC, animated: true)
        
    }
    
    @IBAction func testBluetooth(_ sender: Any) {
        let bluetoothTestVC = BluetoothTestViewController.storyboardInstance()
        bluetoothTestVC.delegate = self
        self.navigationController?.pushViewController(bluetoothTestVC, animated: true)
    }
    
    @IBAction func testDeviceSensors(_ sender: Any) {
        let sensorsTestVC = MotionSensorTestViewController.storyboardInstance()
        sensorsTestVC.delegate = self
        self.navigationController?.pushViewController(sensorsTestVC, animated: true)
    }
    
    @IBAction func captureScreen(_ sender: Any) {
        let captureVC = CaptureScreenViewController.storyboardInstance()
        self.navigationController?.pushViewController(captureVC, animated: true)
        
    }
    
    @IBAction func submitAndSendResults(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = configureMailComposeViewController()
            self.present(mailComposeVC, animated: true, completion: nil)
        }
        else {
            showMailAlertError(title: "Error", msg: "Your device can't send mail.Please check e-mail configuration and try again")
        }
    }
    
}

extension ViewController:BluetoothResultDelegate {
    
    func bluetoothTestResult(isWorking: Bool) {
        if isWorking {
            print("Bluetooth is working")
            bluetoothBtn.backgroundColor = .green
            UserDefaults.standard.set(true, forKey:"BLUETOOTHRESULT")
            
        }
        else {
            print("Bluetooth is not working")
            bluetoothBtn.backgroundColor = .red
            UserDefaults.standard.set(false, forKey:"BLUETOOTHRESULT")
        }
    }
    
}

extension ViewController:MicSpeakerResultDelegate {
    func micSpeakerTestResult(isMicWorking: Bool, isSpeakerWorking: Bool) {
        if isSpeakerWorking && isMicWorking {
            micSpeakerBtn.backgroundColor = .green
            UserDefaults.standard.set(true, forKey:"MICSPEAKERRESULT")
        }
        else{
            micSpeakerBtn.backgroundColor = .red
            UserDefaults.standard.set(false, forKey:"MICSPEAKERRESULT")
        }
        
    }
    
}

extension ViewController:SensorsResultDelegate {
    
    func sensorsTestResult(isAccelorometerWorking:Bool,isGyroscopeWorking:Bool,
                           isMagnetometerWorking:Bool,isdeviceMotionWorking:Bool) {
        if isAccelorometerWorking && isGyroscopeWorking && isdeviceMotionWorking && isMagnetometerWorking {
            deviceSensorsBtn.backgroundColor = .green
            UserDefaults.standard.set(true, forKey:"DEVICESENSORSRESULT")
        }
        else{
            deviceSensorsBtn.backgroundColor = .red
            UserDefaults.standard.set(false, forKey:"DEVICESENSORSRESULT")
        }
    }
}

extension ViewController:CapturedPhotoDelegate {
    func cameraResult(isCameraWorking: Bool) {
        if isCameraWorking{
                smartphoneScreenBtn.backgroundColor = .green
        }
        else{
                smartphoneScreenBtn.backgroundColor = .red
        }
    }
}

extension ViewController:MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            self.dismiss(animated: true, completion: nil)
            break
        case .cancelled:
            self.dismiss(animated: true, completion: nil)
            
        case .failed:
            self.dismiss(animated: true) {
                    self.showMailAlertError(title: "Error", msg: "Check Your device settings for mail")
            }
        case .saved:
            self.dismiss(animated: true) {
                self.showMailAlertError(title: "Alert", msg: "Check your draft for saved mail")
            }
            
        }
        
    }
    
}





