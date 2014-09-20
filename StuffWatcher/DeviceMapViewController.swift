//
//  DeviceMapViewController.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 13/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit
import MapKit

class DeviceMapViewController: UIViewController
{
    var device: Device!
    
    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Device Location"

        // Do any additional setup after loading the view.
        setupMap()
        
        loadDeviceMarkerInMap()
    }
    
    // MARK: - Other Methods
    
    private func setupMap() {
        self.mapView.showsUserLocation = false
        self.mapView.pitchEnabled = false
        
        //Center map in device location
        let region = MKCoordinateRegionMakeWithDistance(self.device.location!, 1500, 1500)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func loadDeviceMarkerInMap() {
        //Load device marker after 2 seconds
        let delay = 2 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.device.location!
            annotation.title = self.device.alias
            annotation.subtitle = self.device.deviceId
                            
            self.mapView.addAnnotation(annotation)
        })
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView: MKAnnotationView!
        
        let pinIdentifier = "DeviceMapPinIdentifier"
        var pinView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier) as MKPinAnnotationView?
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            pinView!.animatesDrop = true
            pinView!.pinColor = MKPinAnnotationColor.Green
            pinView!.canShowCallout = true
            pinView!.enabled = true
        }
        
        annotationView = pinView
        
        return annotationView
    }
}