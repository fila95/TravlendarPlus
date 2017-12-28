//
//  AppDelegate.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 25/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Utilities

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupGraphics()
        
        
        _ = Secret.shared
        _ = Database.shared
        _ = API.shared
        
        
        if !Secret.shared.appPreviouslyLaunched {
            Secret.shared.appPreviouslyLaunched = true
        }
        
        Location.shared.subscribe { (coordinates) in
            print(coordinates)
        }
        
        
        Location.shared.requestLocationUpdate()
        delay(10) {
            Location.shared.requestLocationUpdate()
        }
        
        // Reset badge number
        Badge.reset()
        
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print(granted == true ? "Notification Authorization Granted" : "Notification Authorization Error: \(error.debugDescription)")
        }
        application.registerForRemoteNotifications()
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // Print it to console
        print("APNs device token:\n\t\(deviceTokenString)")
        API.shared.pushNotificationTokenToServer(token: deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }

    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: Utils
    func setupGraphics() {
        UIApplication.shared.keyWindow?.tintColor = UIColor.application
        
    }

}

