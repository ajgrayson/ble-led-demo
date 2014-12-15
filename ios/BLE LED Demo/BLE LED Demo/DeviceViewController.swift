//
//  ViewController.swift
//  BLE LED Demo
//
//  Created by Johnathan Grayson on 14/12/14.
//  Copyright (c) 2014 Johnathan Grayson. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController {
    
    var ble : BLE!
    
    var p : CBPeripheral?
    
    var device : BLEDevice!
    
    @IBOutlet weak var reconnectButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var consoleText: UITextView!
    @IBOutlet weak var swithLabel: UILabel!
    @IBOutlet weak var sw1: UISwitch!
    
    @IBAction func toggle(sender: AnyObject) {
        println("toggled is " + (sw1.on ? "on" : "off" ))
        
        var a : String! = "P"
        var b : String! = "2"
        var c : String! = (sw1.on ? "1" : "0" )
        
        var cmd : [Byte] = [a.utf8[a.utf8.startIndex], b.utf8[b.utf8.startIndex], c.utf8[c.utf8.startIndex]]
        
        var data : NSData? = NSData(bytes: cmd, length: 3)
        
        ble.write(data)
    }
    
    @IBAction func reconnectButtonClick(sender: AnyObject) {
        self.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connect() {
        if(self.p == nil) {
            self.p = findPeripheral()
        }
        
        ble.connectPeripheral(self.p)
    }
    
    func findPeripheral() -> CBPeripheral? {
        var i = 0, len = self.ble.peripherals.count
        for(i = 0; i < len; i++) {
            var p : CBPeripheral = self.ble.peripherals[i] as CBPeripheral
            if(p.identifier.UUIDString == device.identifier) {
                return self.ble.peripherals[i] as? CBPeripheral
            }
        }
        
        return nil
    }
    
    // MARK: - BLE
    
    func bleDidConnect()
    {
        println("->Connected")
        self.statusLabel.text = "Connected"
        self.reconnectButton.enabled = false
    }
    
    func bleDidDisconnect()
    {
        println("->disconnected")
        self.statusLabel.text = "Disconnected"
        self.reconnectButton.enabled = true
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {

        println("->received data")
        
        let nsd = NSData(bytes: data, length: Int(length))
        let str = NSString(data: nsd, encoding: NSUTF8StringEncoding)
        
        println(str)
        
        if(str == nil || str?.length == 0) {
            return
        }
        
        if(str?.substringToIndex(1) == "R") {
            var pin = str?.substringWithRange(NSRange(location: 1, length: 1))
            var state = str?.substringWithRange(NSRange(location: 2, length: 1))
            
            if(pin == "4") {
                self.swithLabel.text = (state == "1" ? "ON" : "OFF")
            }
        }
        
    }

}

