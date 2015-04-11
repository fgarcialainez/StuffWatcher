//
//  DeviceDetailsViewController.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 13/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit

class DeviceDetailsViewController: UIViewController
{
    var device: Device!
    
    var distanceAlertController: UIAlertController?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Device"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.refreshUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Show warning dialog
        if self.device.deviceState == Device.DeviceState.Alarm {
            //Custom message
            var alertMessage: String = self.device.notificationDeviceDetailsMessage()
            
            let alertController = UIAlertController(title: "Warning", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Other Methods

    @IBAction func actionButtonPressed() {
        var alertController: UIAlertController?
        
        if self.device.deviceState == Device.DeviceState.Active {
            //Stop tracking
            alertController = UIAlertController(title: "Stop Tracking", message: "Are you sure you want to stop tracking with this device?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            alertController!.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {action in
                self.device.deviceState = Device.DeviceState.Inactive
                self.device.stuffType = nil
                self.device.trackingType = nil
                self.refreshUI()
            }))
        }
        else if self.device.deviceState == Device.DeviceState.Inactive {
            //Start tracking
            alertController = UIAlertController(title: "Start Tracking", message: "Are you sure you want to start tracking with this device?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            alertController!.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {action in
                self.selectStuffType()
            }))
        }
        else if self.device.deviceState == Device.DeviceState.Alarm {
            //Disable alarm
            alertController = UIAlertController(title: "Disable Alarm", message: "Are you sure you want to disable the fired alarm?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            alertController!.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {action in
                self.device.deviceState = Device.DeviceState.Active
                self.refreshUI()
            }))
        }
        
        self.presentViewController(alertController!, animated: true, completion: nil)
    }
    
    private func refreshUI() {
        if self.device.deviceState == Device.DeviceState.Active {
            self.actionButton.setImage(UIImage(named: "DeviceButtonActive"), forState: UIControlState.Normal)
        }
        else if self.device.deviceState == Device.DeviceState.Inactive {
            self.actionButton.setImage(UIImage(named: "DeviceButtonInactive"), forState:UIControlState.Normal)
        }
        else if self.device.deviceState == Device.DeviceState.Alarm {
            self.actionButton.setImage(UIImage(named: "DeviceButtonAlarm"), forState:UIControlState.Normal)
        }
        
        self.tableView.reloadData()
    }
    
    private func selectStuffType() {
        //Select stuff type
        var alertController = UIAlertController(title: "Select Stuff Type", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Baggage / Bag", style: UIAlertActionStyle.Default, handler: {action in
            self.device.stuffType = Device.StuffType.Baggage_Bag
            
            self.selectTrackingType()
        }))
        alertController.addAction(UIAlertAction(title: "Bike", style: UIAlertActionStyle.Default, handler: {action in
            self.device.stuffType = Device.StuffType.Bike
            
            self.selectTrackingType()
        }))
        
        //Tracking cars should be done by GPS/3G devices
        if self.device.deviceType == Device.DeviceType.GPS_3G {
            alertController.addAction(UIAlertAction(title: "Car", style: UIAlertActionStyle.Default, handler: {action in
                self.device.stuffType = Device.StuffType.Car
                
                self.selectTrackingType()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Person", style: UIAlertActionStyle.Default, handler: {action in
            self.device.stuffType = Device.StuffType.Person
            
            self.selectTrackingType()
        }))
        alertController.addAction(UIAlertAction(title: "Pet", style: UIAlertActionStyle.Default, handler: {action in
            self.device.stuffType = Device.StuffType.Pet
            
            self.selectTrackingType()
        }))
        alertController.addAction(UIAlertAction(title: "Other", style: UIAlertActionStyle.Default, handler: {action in
            self.device.stuffType = Device.StuffType.Other
            
            self.selectTrackingType()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func selectTrackingType() {
        //Select tracking type
        var alertController = UIAlertController(title: "Select Tracking Type", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Object Motion", style: UIAlertActionStyle.Default, handler: {action in
            self.device.trackingType = Device.TrackingType.Motion
            self.device.deviceState = Device.DeviceState.Active
            
            self.refreshUI()
        }))
        alertController.addAction(UIAlertAction(title: "Distance to Object", style: UIAlertActionStyle.Default, handler: {action in
            self.device.trackingType = Device.TrackingType.Distance
           
            self.selectDistanceToFireAlarm()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {action in
            self.device.stuffType = nil
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func selectDistanceToFireAlarm() {
        //Select minimum distance to fire the alarm
        self.distanceAlertController = UIAlertController(title: "Enter Distance", message: "Please enter the minimum distance to fire the alarm", preferredStyle: UIAlertControllerStyle.Alert)
        distanceAlertController!.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Distance (meters)"
            textField.keyboardType = UIKeyboardType.NumberPad
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: textField)
        })
        
        self.distanceAlertController!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {action in
            self.device.stuffType = nil
            self.device.trackingType = nil;
        }))
        self.distanceAlertController!.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.Default, handler: {action in
            self.device.deviceState = Device.DeviceState.Active
            
            let distanceStr = (self.distanceAlertController!.textFields![0] as! UITextField).text
            self.device.distanceToFireAlarm = distanceStr.toInt()!
            
            self.refreshUI()
        }))
        
        (self.distanceAlertController!.actions[1] as! UIAlertAction).enabled = false
        self.presentViewController(self.distanceAlertController!, animated: true, completion: nil)
    }
    
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        (self.distanceAlertController!.actions[1] as! UIAlertAction).enabled = !textField.text.isEmpty
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.05
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (UIScreen.mainScreen().bounds.height == 568) ? 20 : 0.05
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView {
        return UIView()
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.device.showDeviceInMap ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if indexPath.section == 0 {
            let KCellIdOne = "DeviceDetailsCellOne"
            
            cell = tableView.dequeueReusableCellWithIdentifier(KCellIdOne) as! UITableViewCell?
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: KCellIdOne)
                cell!.selectionStyle = UITableViewCellSelectionStyle.None
            }
            
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Alias"
                cell!.detailTextLabel?.text = self.device.alias
            }
            else if indexPath.row == 1 {
                cell!.textLabel?.text = "Identifier"
                cell!.detailTextLabel?.text = self.device.deviceId
            }
            else if indexPath.row == 2 {
                cell!.textLabel?.text = "Device Type"
            
                if self.device.deviceType == Device.DeviceType.Bluetooth {
                    cell!.detailTextLabel?.text = "Bluetooth"
                }
                else if self.device.deviceType == Device.DeviceType.GPS_3G {
                    cell!.detailTextLabel?.text = "GPS / 3G"
                }
            }
            else if indexPath.row == 3 {
                cell!.textLabel?.text = "Stuff Type"
            
                if let stuffTypeValue = self.device.stuffType {
                    if stuffTypeValue ==  Device.StuffType.Baggage_Bag {
                        cell!.detailTextLabel?.text = "Baggage / Bag"
                    }
                    else if stuffTypeValue ==  Device.StuffType.Bike {
                        cell!.detailTextLabel?.text = "Bike"
                    }
                    else if stuffTypeValue ==  Device.StuffType.Car {
                        cell!.detailTextLabel?.text = "Car"
                    }
                    else if stuffTypeValue ==  Device.StuffType.Person {
                        cell!.detailTextLabel?.text = "Person"
                    }
                    else if stuffTypeValue ==  Device.StuffType.Pet {
                        cell!.detailTextLabel?.text = "Pet"
                    }
                    else if stuffTypeValue ==  Device.StuffType.Other {
                        cell!.detailTextLabel?.text = "Other"
                    }
                }
                else {
                    cell!.detailTextLabel?.text = "-"
                }
            }
            else if indexPath.row == 4 {
                cell!.textLabel?.text = "Tracking Type"
                
                if let trackingTypeValue = self.device.trackingType {
                    if trackingTypeValue == Device.TrackingType.Motion {
                        cell!.detailTextLabel?.text = "Object Motion"
                    }
                    else if trackingTypeValue == Device.TrackingType.Distance {
                        cell!.detailTextLabel?.text = "Distance (>\(self.device.distanceToFireAlarm)m)"
                    }
                }
                else {
                    cell!.detailTextLabel?.text = "-"
                }
            }
        }
        else if indexPath.section == 1 {
            let KCellIdTwo = "DeviceDetailsCellTwo"
            
            cell = tableView.dequeueReusableCellWithIdentifier(KCellIdTwo) as! UITableViewCell?
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: KCellIdTwo)
                cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
                cell!.textLabel!.textAlignment = NSTextAlignment.Center
                cell!.textLabel!.textColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0)
            }
            
            cell!.textLabel!.text = "Show Location"
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //Show device location
        if indexPath.section == 1 {
            let deviceMapView = DeviceMapViewController(nibName: "DeviceMapViewController", bundle: nil)
            deviceMapView.device = self.device
            
            self.navigationController?.pushViewController(deviceMapView, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
