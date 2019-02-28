//
//  AppDelegate.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import UserNotifications
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    public static let realmUrl = Realm.Configuration.defaultConfiguration.fileURL!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DDLog.add(DDOSLogger.sharedInstance)
        
        DDLogInfo("IN APP DELEGATE")
        
//        registerForPushNotifications()
        
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kurt.Call-Control")!
        let realmPath = directory.appendingPathComponent("default.realm")
        let realmConfig = Realm.Configuration(fileURL: realmPath)
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
//        try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Only need to worry about Realm failing on the first intialization
        do {
            _ = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
        
        
        // Set up rule store for app
        let ruleStore = RuleStore()
        ruleStore.realmConfig = realmConfig
        
        let navController = window!.rootViewController as! UINavigationController
        let rulesController = navController.topViewController as! RulesViewController
        
        rulesController.ruleStore = ruleStore
        rulesController.numberDirectoryManager = NumberDirectoryManager()
        rulesController.numberDirectoryManager.attachObserver(observer: rulesController)
        rulesController.id = 0
        
        // Load rules into ruleStore from Realm
        rulesController.ruleStore.load()
        
        // Save settings into Realm
        Settings.instance.realmConfig = realmConfig
        Settings.instance.save()
        
        return true
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
        
        NumberDirectoryManager.refreshExtensionState()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token \(token)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register for remote notifications with error: \(error)")
        
    }

}

