//
//  AppDelegate.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 05/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var showFirstNotification: Bool = true
    
    var window: UIWindow?
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.mainViewController = (self.window!.rootViewController as! UINavigationController).topViewController as! MainViewController
        
        //Registering for sending user various kinds of notifications
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //Pop to root view controller
        (self.window?.rootViewController as! UINavigationController).popToRootViewControllerAnimated(false)
        
        //Setup a local notification
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = self.mainViewController.notificationMessageForDeviceWith(deviceIndex: self.showFirstNotification ? 0 : 1)
        notification.alertAction = "View"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Get local notification event
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // do your jobs here
        
        self.mainViewController.localNotificationFiredWith(deviceIndex: self.showFirstNotification ? 0 : 1)
        
        self.showFirstNotification = !self.showFirstNotification
    }
}