//
//  AppDelegate.swift
//  WorkoutTracker
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    // DataModel object for accessing app data storage methods
    let dataModel = DataModel()
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Use app delegate's window property to find the UIWindow object that contains the storyboard
        let navigationController = window!.rootViewController as! UINavigationController
        
        // Convert it to AllWorkoutsViewController
        let controller = navigationController.viewControllers[0] as! AllWorkoutsViewController
        
        // Set the DataModel object in AllWorkoutsViewController to the one loaded here
        controller.dataModel = dataModel
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to
    // restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Save app data
        saveData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Save app data
        saveData()
    }
    
    // Saves app data when the app is terminated
    func saveData()
    {
        dataModel.saveWorkouts()
    }
}
