//
//  UserNotifications.swift
//  LeaveList
//
//  Created by Dmitry on 18/8/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation

enum NotificationAction: String {
    case MarkAsDone
}

enum NotificationCategory: String {
    case RecordActions
}

class UserNotifications {
    class func scheduleNotification(date: NSDate, message: String, recordKey: String) {
        let notification = UILocalNotification()
        
        notification.category = NotificationCategory.RecordActions.rawValue
        notification.alertLaunchImage = nil
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = nil
        notification.timeZone = NSTimeZone.localTimeZone()
//        notification.soundName = ""
        notification.userInfo = ["key": recordKey]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

extension AppDelegate {
    func registerLocalNotifications() {
        let markDoneAction = UIMutableUserNotificationAction()
        
        markDoneAction.identifier = NotificationAction.MarkAsDone.rawValue
        markDoneAction.destructive = false
        markDoneAction.title = tr(.MarkAsDone)
        markDoneAction.activationMode = .Foreground
        markDoneAction.authenticationRequired = false
        
        let category = UIMutableUserNotificationCategory()
        
        category.identifier = NotificationCategory.RecordActions.rawValue
        
        category.setActions([markDoneAction], forContext: .Minimal)
        category.setActions([markDoneAction], forContext: .Default)
        
        let categories = Set(arrayLiteral: category)
        
        let settingsRequest = UIUserNotificationSettings(forTypes: [.Alert , .Badge , .Sound], categories: categories)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settingsRequest)
    }
    
    func handleLocalNotification(notification: UILocalNotification) {
        if (UIApplication.sharedApplication().applicationState == UIApplicationState.Active) {
        } else {
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        handleLocalNotification(notification)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        handleLocalNotification(notification)
        
        if let actionId = identifier where actionId == NotificationAction.MarkAsDone.rawValue  {
            if let key = notification.userInfo?["key"] as? String {
                let record = ListEntry.loadByKey(key)
            
                record?.markAsDone()
                
                self.eventManager.registerEventForListEntry(key)
            }
        }
        
        completionHandler()
    }
}





























