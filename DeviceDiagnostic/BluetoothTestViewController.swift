//
//  BluetoothTestViewController.swift
//  DeviceDiagnostic
//
//  Created by Niraj Jha on 21/09/18.
//  Copyright © 2018 Niraj Jha. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothResultDelegate:class {
    func bluetoothTestResult(isWorking:Bool)
}

class BluetoothTestViewController: UIViewController {
    
    @IBOutlet weak var testBluetoothBtn: UIButton!
    @IBOutlet weak var submitBluetoothTest: UIButton!
    
    var bluetoothCentralManager:CBCentralManager!
    var genericPeripheral: CBPeripheral!
    weak var delegate: BluetoothResultDelegate?
    var isBluetoothWorking = false
    
    //MARK:- self methods
    override func viewDidLoad() {
        super.viewDidLoad()
        formatUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- private methods
    func formatUI() {
        testBluetoothBtn.layer.cornerRadius = 20.0
        submitBluetoothTest.layer.cornerRadius = 20.0
        testBluetoothBtn.clipsToBounds = true
        submitBluetoothTest.clipsToBounds = true
    }
    
    //MARK:- public methods
    class func storyboardInstance() -> BluetoothTestViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BluetoothTest") as! BluetoothTestViewController
        return vc
    }
    
    //MARK:- Button Action methods
    @IBAction func testBluetooth(_ sender: Any) {
        bluetoothCentralManager = CBCentralManager(delegate: self, queue: nil)
        bluetoothCentralManager.delegate = self
    }
    
    @IBAction func submitBluetoothTest(_ sender: Any) {
        self.delegate?.bluetoothTestResult(isWorking: isBluetoothWorking)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BluetoothTestViewController:CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is On")
            bluetoothCentralManager.scanForPeripherals(withServices: nil)
            break
        case .poweredOff:
            print("Bluetooth is Off")
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        genericPeripheral = peripheral
        bluetoothCentralManager.stopScan()
        bluetoothCentralManager.connect(genericPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("successfully connected")
        isBluetoothWorking = true
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connection failure")
        isBluetoothWorking = false
    }
    
}
