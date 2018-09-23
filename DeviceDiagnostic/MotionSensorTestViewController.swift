//
//  MotionSensorTestViewController.swift
//  DeviceDiagnostic
//
//  Created by Niraj Jha on 22/09/18.
//  Copyright © 2018 Niraj Jha. All rights reserved.
//

import UIKit
import CoreMotion

protocol SensorsResultDelegate:class {
    func sensorsTestResult(isAccelorometerWorking:Bool,isGyroscopeWorking:Bool,
                             isMagnetometerWorking:Bool,isdeviceMotionWorking:Bool)
}

class MotionSensorTestViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    let motionManager = CMMotionManager()
    var isAccelorometerWorking = false
    var isGyroscopeWorking = false
    var isMagnetometerWorking = false
    var isdeviceMotionWorking = false
    weak var delegate: SensorsResultDelegate?
    
    //Mark: Self methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Mark: Private methods
    
    func formatUI() {
        
        startBtn.layer.cornerRadius = 20.0
        stopBtn.layer.cornerRadius = 20.0
        startBtn.clipsToBounds = true
        stopBtn.clipsToBounds = true
    }
    
    //MARK:- public methods
    class func storyboardInstance() -> MotionSensorTestViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SensorsTest") as! MotionSensorTestViewController
        return vc
    }
    
    //MARK:- Button Action methods
    @IBAction func testSensors(_ sender: Any) {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                if data != nil{
                    self.isAccelorometerWorking = true
                }
                print("Accelerometer Data is\(String(describing: data))")
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: OperationQueue.main) { (data, error) in
                print("Gyroscope Data is\(String(describing: data))")
                if data != nil{
                    self.isGyroscopeWorking = true
                }
            }
        }
        
        if motionManager.isMagnetometerAvailable {
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (data, error) in
                print("magnetometer Data is\(String(describing: data))")
                if data != nil{
                    self.isMagnetometerWorking = true
                }
            }
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                print("device-motion Data is\(String(describing: data))")
                if data != nil{
                    self.isdeviceMotionWorking = true
                }
            }
        }
    }
    
    @IBAction func stopAndSubmitTest(_ sender: Any) {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopMagnetometerUpdates()
        self.delegate?.sensorsTestResult(isAccelorometerWorking: isAccelorometerWorking, isGyroscopeWorking: isGyroscopeWorking, isMagnetometerWorking: isMagnetometerWorking, isdeviceMotionWorking: isdeviceMotionWorking)
        self.navigationController?.popViewController(animated: true)
    }
}
