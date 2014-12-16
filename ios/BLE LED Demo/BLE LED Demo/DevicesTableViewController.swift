//
//  DevicesTableViewController.swift
//  BLE LED Demo
//
//  Created by Johnathan Grayson on 14/12/14.
//  Copyright (c) 2014 Johnathan Grayson. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController, BLEDelegate {

    var ble : BLE!
    
    var devices : [BLEDevice]!

    var deviceViewController : DeviceViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ble = BLE()
        ble.controlSetup()
        ble.delegate = self
        
        self.devices = [BLEDevice]()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.refreshPeripherals()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.devices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        var device = self.devices[indexPath.item]
        
        cell.textLabel?.text = device.name + " (" + device.identifier + ")"

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openDevice") {
            var nvc : UINavigationController = segue.destinationViewController as UINavigationController
            var vc : DeviceViewController = nvc.topViewController as DeviceViewController
            
            var indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
            
            var device = self.devices[indexPath.item]
            
            vc.device = device
            vc.ble = self.ble
            
            self.deviceViewController = vc
        }
    }

    // MARK: - Buttons
    
    @IBAction func refreshClicked(sender: AnyObject) {
        self.refreshPeripherals()
    }
    
    // MARK: - BLE Helpers
    
    func getIdentifier(identifier: NSUUID) -> String! {
        return identifier.UUIDString
    }
    
    func connectionTimer(timer: NSTimer) {
        self.devices.removeAll(keepCapacity: false)
        
        if(self.ble.peripherals != nil && self.ble.peripherals.count > 0) {
            var i = 0, len = self.ble.peripherals.count;
            for(i = 0; i < len; i++) {
                var p : CBPeripheral = self.ble.peripherals.objectAtIndex(i) as CBPeripheral
                if(p.identifier != nil) {
                    var d = BLEDevice()
                    d.name = p.name
                    d.identifier = self.getIdentifier(p.identifier)
                    d.index = i
                    
                    self.devices.append(d)
                }
            }
        }
        
        self.tableView.reloadData()
    }

    func refreshPeripherals() {
        if(self.ble.activePeripheral != nil) {
            return;
        }

        if(self.ble.peripherals != nil) {
            self.ble.peripherals = nil
        }

        self.ble.findBLEPeripherals(3)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "connectionTimer:", userInfo: nil, repeats: false)
    }
    
    
    // MARK : - BLE Delegate
    
    func bleDidConnect()
    {
        println("->Connected");
        self.deviceViewController.bleDidConnect()
    }
    
    func bleDidDisconnect()
    {
        println("->disconnected");
        self.deviceViewController.bleDidDisconnect()
    }

    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
        self.deviceViewController.bleDidReceiveData(data, length: length)
    }
    
//    func bleDidReceiveData(data : UnsafeMutablePointer<UInt8>, len : Int!) {
//        self.deviceViewController.bleDidReceiveData(data, length: len)
//    }
    
}
