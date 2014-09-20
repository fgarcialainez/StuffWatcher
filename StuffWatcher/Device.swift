//
//  Device.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 06/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import Foundation
import MapKit

class Device
{
    // MARK: - Type declaration
    enum DeviceType {
        case Bluetooth, GPS_3G
    }
    
    enum StuffType {
        case Baggage_Bag, Bike, Car, Person, Pet, Other
    }
    
    enum TrackingType {
        case Motion, Distance
    }
    
    enum DeviceState {
        case Inactive, Active, Alarm
    }
    
    // MARK: - Properties declaration
    
    var alias: String
    var deviceId: String
    
    var location: CLLocationCoordinate2D?
    var deviceType: DeviceType
    var deviceState: DeviceState
    
    var stuffType:StuffType?
    var trackingType: TrackingType?
    
    //Used in TrackingType.Distance
    var distanceToFireAlarm: Int = 0
    
    var imagePath: String {
        return (self.deviceType == DeviceType.Bluetooth) ? "DeviceTypeBluetooth" : "DeviceTypeGPS3G"
    }
    
    var showDeviceInMap: Bool {
        return (self.deviceState != Device.DeviceState.Inactive && self.location != nil)
    }
    
    // MARK: - Initializers
    
    init(alias: String, deviceId: String, deviceType: DeviceType, deviceState: DeviceState) {
        self.alias = alias
        self.deviceId = deviceId
        self.deviceType = deviceType
        self.deviceState = deviceState
    }
    
    // MARK: - Other Methods
    
    func notificationMessage () -> String {
        var message: String!
        
        if self.trackingType == Device.TrackingType.Motion {
            message = "Alarm (Device Motion Detected)"
        }
        else if self.trackingType == Device.TrackingType.Distance {
            message = "Alarm (Distance to Object)"
        }
        
        return message
    }
    
    func notificationDeviceDetailsMessage () -> String {
        var message: String!
        
        if self.trackingType == Device.TrackingType.Motion {
            message = "This device has detected that its object associated is in movement. Please check that everything is ok and disable the alarm after that."
        }
        else if self.trackingType == Device.TrackingType.Distance {
            message = "This device has detected that its object associated is further than \(self.distanceToFireAlarm) meters away. Please check that everything is ok and disable the alarm after that."
        }
        
        return message
    }
    
    // MARK: - Static Data
    
    class func loadInitialDevices() -> Array<Device> {
        var devices: Array<Device> = Array<Device>()
        
        let deviceOne = Device(alias: "My Baggage", deviceId: "4789C-CVDF-EWQS", deviceType: DeviceType.Bluetooth, deviceState: DeviceState.Active)
        deviceOne.stuffType = StuffType.Baggage_Bag
        deviceOne.trackingType = TrackingType.Motion
        devices.append(deviceOne)
        
        let deviceTwo = Device(alias: "My Bike", deviceId: "1256A-XUYT-POIN", deviceType: DeviceType.GPS_3G, deviceState: DeviceState.Active)
        deviceTwo.location = CLLocationCoordinate2DMake(41.646983, -0.889075)
        deviceTwo.stuffType = StuffType.Bike
        deviceTwo.trackingType = TrackingType.Distance
        deviceTwo.distanceToFireAlarm = 100
        devices.append(deviceTwo)
        
        let deviceThree = Device(alias: "My Child", deviceId: "4389I-BVDS-EWSX", deviceType: DeviceType.GPS_3G, deviceState: DeviceState.Inactive)
        deviceThree.location = CLLocationCoordinate2DMake(41.645539, -0.889182)
        devices.append(deviceThree)
        
        return devices
    }
}