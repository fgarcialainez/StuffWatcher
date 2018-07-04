//
//  MainViewController.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 05/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, LoginViewControllerDelegate
{
    //Current devices
    var devicesArray: Array<Device>?
    
    //Add new devices
    var newDeviceId: String?
    var newDeviceType: Device.DeviceType?
    
    var alertController: UIAlertController?
    var activityIndicator : UIActivityIndicatorView?
    
    //Map stuff
    let currentUserLocation = CLLocationCoordinate2DMake(41.647159, -0.885856)
    var annotationsArray: Array<MKPointAnnotation> = Array()
    var fakeLocationAnnotation: MKPointAnnotation?
    
    //Other UI stuff
    var logoutActionSheet: UIActionSheet?
    var addDeviceActionSheet: UIActionSheet?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    // MARK: - Overriden from UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup navigation bar
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 25))
        headerView.addSubview(imageView)
        self.navigationItem.titleView = headerView
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        let signOutBarButtonItem = UIBarButtonItem(title: "Sign out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainViewController.signOutAction))
        self.navigationItem.leftBarButtonItem = signOutBarButtonItem
        
        let addDeviceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MainViewController.addDeviceAction))
        self.navigationItem.rightBarButtonItem = addDeviceBarButtonItem
        
        //Setup map
        setupMap()
        
        //Show login view
        showLoginView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reload view data
        refreshUI()
    }

    // MARK: - Action Methods
    
    @objc func signOutAction() {
        self.logoutActionSheet = UIActionSheet()
        self.logoutActionSheet!.delegate = self
        self.logoutActionSheet!.title = "Are you sure you want to sign out?"
        self.logoutActionSheet!.addButton(withTitle: "Sign out")
        self.logoutActionSheet!.addButton(withTitle: "Cancel")
        self.logoutActionSheet!.destructiveButtonIndex = 0
        self.logoutActionSheet!.cancelButtonIndex = 1
        self.logoutActionSheet!.show(in: self.view)
    }
    
    @objc func addDeviceAction() {
        self.addDeviceActionSheet = UIActionSheet()
        self.addDeviceActionSheet!.delegate = self
        self.addDeviceActionSheet!.title = "Add a new device"
        self.addDeviceActionSheet!.addButton(withTitle: "Add bluetooth device")
        self.addDeviceActionSheet!.addButton(withTitle: "Add device by identifier")
        self.addDeviceActionSheet!.addButton(withTitle: "Cancel")
        self.addDeviceActionSheet!.cancelButtonIndex = 2
        self.addDeviceActionSheet!.show(in: self.view)
    }
    
    @IBAction func segmentedValueChanged() {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.tableView.isHidden = false
            self.mapView.isHidden = true
        }
        else if self.segmentedControl.selectedSegmentIndex == 1 {
            self.tableView.isHidden = true
            self.mapView.isHidden = false
        }
    }
    
    // MARK: - Notifications
    
    func notificationMessageForDeviceWith(deviceIndex: Int) -> String {
        //Get notification message
        var notificationMessage: String = ""
        
        if let devicesArrayValue = self.devicesArray {
            if deviceIndex < devicesArrayValue.count {
                let device = devicesArrayValue[deviceIndex]
                
                notificationMessage = device.notificationMessage()
            }
        }
        
        return notificationMessage
    }
    
    func localNotificationFiredWith(deviceIndex: Int) {
        //Set device state to Alarm
        if let devicesArrayValue = self.devicesArray {
            if deviceIndex < devicesArrayValue.count {
                let device = devicesArrayValue[deviceIndex]
                
                //Modify device state
                device.deviceState = Device.DeviceState.Alarm
                
                //Show device details view
                showDeviceDetailsView(device: device)
            }
        }
    }
    
    // MARK: - Other Methods
    
    private func showDeviceDetailsView(device: Device) {
        let deviceDetailsView = DeviceDetailsViewController(nibName: "DeviceDetailsViewController", bundle: nil)
        deviceDetailsView.device = device
        
        self.navigationController?.pushViewController(deviceDetailsView, animated: true)
    }
    
    private func showLoginView() {
        let loginView = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginView.delegate = self
        let navController = UINavigationController(rootViewController: loginView)
        
        self.navigationController!.present(navController, animated: true, completion: nil)
    }
    
    private func setupMap() {
        self.mapView.isHidden = true
        self.mapView.showsUserLocation = false
        self.mapView.isPitchEnabled = false
        
        //Center map in Zaragoza center
        let region = MKCoordinateRegionMakeWithDistance(self.currentUserLocation, 1500, 1500)
        self.mapView.setRegion(region, animated: true)
        
        //Load user location marker
        self.fakeLocationAnnotation = MKPointAnnotation()
        self.fakeLocationAnnotation!.coordinate = self.currentUserLocation
        self.fakeLocationAnnotation!.title = "Your Location"
        self.mapView.addAnnotation(self.fakeLocationAnnotation!)
    }
    
    private func loadDeviceMarkersInMap() {
        //Remove old markers
        for currentAnnotation: MKPointAnnotation in self.annotationsArray {
            self.mapView.removeAnnotation(currentAnnotation)
        }
        
        self.annotationsArray.removeAll(keepingCapacity: true)
        
        //Load device markers after 3 seconds
        dispatch_after_delay(3) {
            if let devicesArrayValue = self.devicesArray {
                for currentDevice: Device in devicesArrayValue {
                    if currentDevice.showDeviceInMap {
                        if let locationValue = currentDevice.location {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
                            annotation.title = currentDevice.alias
                            annotation.subtitle = currentDevice.deviceId
                        
                            self.mapView.addAnnotation(annotation)
                            self.annotationsArray.append(annotation)
                        }
                    }
                }
            }
        }
    }
    
    private func refreshUI() {
        //Load device markers in map
        self.loadDeviceMarkersInMap()
        
        //Refresh table view content
        self.tableView.reloadData()
    }
    
    private func showActivityIndicatorInAlertController() {
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator!.center = CGPoint(x: 130, y: 58)
        self.activityIndicator!.hidesWhenStopped = true
        self.activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.alertController?.view.addSubview(self.activityIndicator!)
        self.activityIndicator!.startAnimating()
    }
    
    private func hideActivityIndicatorInAlertController() {
        self.activityIndicator?.removeFromSuperview()
        self.activityIndicator = nil
    }
    
    // MARK: - Add new device related methods
    
    private func enterDeviceIdentifierAction() {
        //Simulate enter device identifier
        DispatchQueue.main.async(execute: {
            self.alertController = UIAlertController(title: "Search Device", message: "Please enter your device identifier with the following format XXXXX-XXXX-XXXX (you can find it in your device packing box)", preferredStyle: UIAlertControllerStyle.alert)
            self.alertController?.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = "Device Identifier"
            
                NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            })
        
            self.alertController!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.alertController!.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.default, handler: { action in
                self.newDeviceId = (self.alertController?.textFields![0])!.text!.uppercased()
            
                self.searchForDevicesAction()
            }))
        
            (self.alertController!.actions[1] ).isEnabled = false
            self.present(self.alertController!, animated: true, completion: nil)
        })
    }
    
    private func searchForDevicesAction() {
        //Simulate device search
        DispatchQueue.main.async(execute: {
            self.alertController = UIAlertController(title: "Searching for Devices", message: " ", preferredStyle: UIAlertControllerStyle.alert)
            self.present(self.alertController!, animated: true, completion: nil)
            self.showActivityIndicatorInAlertController()
            
            dispatch_after_delay(2) {
                //Simulate new device found
                DispatchQueue.main.async(execute: {
                    //Dismiss search dialog
                    self.alertController?.dismiss(animated: true, completion: nil)
                    
                    self.alertController = UIAlertController(title: "Device Found", message: "Do you want to link the device with identifier \(self.newDeviceId!) to your Stuff Watcher account?", preferredStyle: UIAlertControllerStyle.alert)
                    self.alertController!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                    self.alertController!.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.enterSecurityKeyAction))
                
                    self.present(self.alertController!, animated: true, completion: nil)
                })
            }
        })
    }
    
    private func enterSecurityKeyAction(action: UIAlertAction!) {
        //Simulate new device pairing
        DispatchQueue.main.async(execute: {
            self.alertController = UIAlertController(title: "Enter Security Key", message: "Please enter the device security key (you can find in your device packaging box)", preferredStyle: UIAlertControllerStyle.alert)
            self.alertController?.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = "Security Key"
                textField.isSecureTextEntry = true
                    
                NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            })
            
            self.alertController!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.alertController!.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: self.enterDeviceAliasAction))
                
            (self.alertController!.actions[1] ).isEnabled = false
            self.present(self.alertController!, animated: true, completion: nil)
        })
    }
    
    private func enterDeviceAliasAction(action: UIAlertAction!) {
        //Simulate enter device alias
        DispatchQueue.main.async(execute: {
            self.alertController = UIAlertController(title: "Enter Device Alias", message: "Please enter an alias for your new device", preferredStyle: UIAlertControllerStyle.alert)
            self.alertController?.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = "Device Alias"
                    
                NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            })
            
            self.alertController!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.alertController!.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.default, handler: self.finishAddDeviceProcessAction))
                
            (self.alertController!.actions[1] ).isEnabled = false
            self.present(self.alertController!, animated: true, completion: nil)
        })
    }
    
    private func finishAddDeviceProcessAction(action: UIAlertAction!) {
        //Add new device
        let newDeviceAlias = (self.alertController?.textFields![0])!.text
        let newDevice = Device(alias: newDeviceAlias!, deviceId: self.newDeviceId!, deviceType: self.newDeviceType!, deviceState: Device.DeviceState.Inactive)
        
        if self.newDeviceType! == Device.DeviceType.GPS_3G {
            newDevice.location = CLLocationCoordinate2DMake(41.647777, -0.889756)
        }
        
        self.devicesArray?.append(newDevice)
        
        //Refresh UI
        refreshUI()
    }
    
    @objc func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        (self.alertController!.actions[1]).isEnabled = !textField.text!.isEmpty
    }
    
    // MARK: - LoginViewControllerDelegate
    
    func loginCompletedWithSucess() {
        self.devicesArray = Device.loadInitialDevices()
        self.tableView.reloadData()
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if actionSheet == self.logoutActionSheet {
            switch buttonIndex {
                case 0:
                    showLoginView()
                    break
                default:
                    break;
            }
        }
        else if actionSheet == self.addDeviceActionSheet {
            switch buttonIndex {
            case 0:
                //Add Bluetooth Device
                self.newDeviceId = "3199A-SXVB-QEO4" //Enter default device identifier
                self.newDeviceType = Device.DeviceType.Bluetooth
                
                searchForDevicesAction()
                break
            case 1:
                //Add Device by Identifier
                self.newDeviceType = Device.DeviceType.GPS_3G
                
                enterDeviceIdentifierAction()
                break
            default:
                break
            }
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.devicesArray != nil) ? self.devicesArray!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let KCellId = "DeviceCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: KCellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: KCellId)
        }
        
        let selectedDevice = self.devicesArray![indexPath.row]
        
        cell!.textLabel?.text = selectedDevice.alias
        cell!.detailTextLabel?.text = selectedDevice.deviceId
        cell!.imageView?.image = UIImage(named: selectedDevice.imagePath)
        cell!.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0)
        
        if selectedDevice.deviceState == Device.DeviceState.Active {
            cell!.accessoryView = UIImageView(image: UIImage(named: "DeviceStateActive"))
        }
        else if selectedDevice.deviceState == Device.DeviceState.Inactive {
            cell!.accessoryView = UIImageView(image: UIImage(named: "DeviceStateInactive"))
        }
        else if selectedDevice.deviceState == Device.DeviceState.Alarm {
            cell!.accessoryView = UIImageView(image: UIImage(named: "DeviceStateAlarm"))
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Show device details view
        showDeviceDetailsView(device: self.devicesArray![indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        
        let pinIdentifier = "DevicePinIdentifier"
        var pinView = self.mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            pinView!.animatesDrop = true
            pinView!.pinColor = (annotation.title! == self.fakeLocationAnnotation?.title) ? MKPinAnnotationColor.purple : MKPinAnnotationColor.green
            pinView!.canShowCallout = true
            pinView!.isEnabled = true
            
            if annotation.title! != self.fakeLocationAnnotation?.title! {
                let disclosureIndicatorButton = UIButton(type: UIButtonType.detailDisclosure)
                disclosureIndicatorButton.tintColor = UIColor.clear
                disclosureIndicatorButton.isEnabled = false
                disclosureIndicatorButton.setBackgroundImage(UIImage(named: "DisclosureIndicator")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState())
                pinView!.rightCalloutAccessoryView = disclosureIndicatorButton
            }
            else {
                pinView!.rightCalloutAccessoryView = nil
            }
        }
        
        annotationView = pinView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Find tapped annotation
        var selectedDevice: Device?
        
        if let devicesArrayValue = self.devicesArray {
            for currentDevice: Device in devicesArrayValue {
                if currentDevice.alias == view.annotation!.title! {
                    selectedDevice = currentDevice
                    break
                }
            }
        }
        
        //Show device details view
        if let selectedDeviceValue = selectedDevice {
            showDeviceDetailsView(device: selectedDeviceValue)
        }
    }
}
