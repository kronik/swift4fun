//
//  AppDelegate.swift
//  LeaveList
//
//  Created by Dmitry on 14/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import Appz
import EZSwiftExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        let controller = createRootViewController()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = controller.view.backgroundColor
        self.window!.rootViewController = controller
        
        self.window!.makeKeyAndVisible()

        initializeServices(launchOptions)
        
        return true
    }
    
    func initializeServices(launchOptions: [NSObject: AnyObject]?) {
        if !ez.isSimulator {
            
            /*
            Fabric.with([Crashlytics.self()])
            
            let branch = Branch.getInstance()
            
            branch.initSessionWithLaunchOptions(launchOptions, isReferrable: true, andRegisterDeepLinkHandler: { [unowned self] (params, error) -> Void in
                
                guard let params = params else {
                    return
                }
                
                let json     = JSON(params)
                let company  = json["company"].stringValue
                let username = json["username"].stringValue
                let claimId  = json["claimId"].stringValue
                
            })
             */
        }
    }
    
    func createRootViewController() -> UIViewController {
        let controller = ViewController()
        
        controller.title = tr(.DontForgetTo)
        
        let navController = UINavigationController(rootViewController: controller)
        
        navController.navigationBar.tintColor = UIColor.darkGrayColor()
        
        return navController
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.NewData)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
}

extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct LeaveList: ExternalApplication {
        
        typealias ActionType = Applications.LeaveList.Action
        
        let scheme = "leavelist:"
        let fallbackURL = ""
        var appStoreId: String = {
            return Config.AppStoreAppId
        }()
    }
}

extension Applications.LeaveList {
    enum Action: ExternalApplicationAction {
        case Open
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .Open:
                return ActionPaths()
            }
        }
    }
}


