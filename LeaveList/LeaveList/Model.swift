//
//  Model.swift
//  LeaveList
//
//  Created by Dmitry on 7/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import RealmSwift

public typealias DataDidChangeHandler = () -> Void

public class Model {
    static let sharedInstance = Model()
    
    private let realmDbSchemaVersion: UInt64 = 2
    
    private var updateToken: NotificationToken?
    
    public var dataChangeHandler: DataDidChangeHandler = { } {
        didSet {
            updateToken?.stop()
            
            let realm = try! Realm()

            updateToken = realm.addNotificationBlock { (notification, realm) in
                self.dataChangeHandler()
            }
        }
    }
    
    private init() {
        var config = Realm.Configuration(
            schemaVersion: realmDbSchemaVersion,
            migrationBlock: {(migration: Migration, oldSchemaVersion: UInt64) in
                if oldSchemaVersion < 1 { }
            }
        )
    
        let containerUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Model.appGroupId)
        
        if let containerUrl = containerUrl {
            config.fileURL = containerUrl.URLByAppendingPathComponent("db.realm", isDirectory: false)
        }
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    public class func save(object: ModelObject) {
        let objectToSave = object.copyToSave()
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(objectToSave, update: true)
        }
    }
    
    public class func delete(object: ModelObject) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(object)
        }
    }
    
    public class func update(block: (() -> Void)) {
        let realm = try! Realm()
        
        try! realm.write {
            block()
        }
    }
    
    deinit {
        updateToken?.stop()
    }
}

public class ModelObject: Object {
    dynamic var key = ""
    dynamic var isDeleted = false
    dynamic var createdAt = NSDate()

    public override class func primaryKey() -> String? {
        return "key"
    }
    
    public func copyToSave() -> ModelObject {
        return self
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? ModelObject {
            return key == rhs.key
        }
        return false
    }
}

public class ListEntry: ModelObject {
    dynamic var lastActionDate = NSDate()
    dynamic var textDescription = ""
    dynamic var listKey = ""
    dynamic var cachedDescription = ""
    
    public override func copyToSave() -> ModelObject {
        if key.isEmpty {
            key = String.uniqueString()
            
            return self
        }
        
        let newObject = ListEntry()
        
        newObject.key               = key
        newObject.listKey           = listKey
        newObject.isDeleted         = isDeleted
        newObject.lastActionDate    = lastActionDate
        newObject.textDescription   = textDescription
        newObject.createdAt         = createdAt
        newObject.cachedDescription = cachedDescription

        return newObject
    }
    
    public override static func ignoredProperties() -> [String] {
        return ["cachedDescription"]
    }

    public class func loadByKey(key: String) -> ListEntry? {
        var filter = NSPredicate(format: "key == %@ AND isDeleted == 0", key)
        let realm = try! Realm()
        var record: ListEntry?
        
        var results = realm.objects(ListEntry).filter(filter).sorted("createdAt", ascending: true)
        
        if results.count == 0 {
            filter = NSPredicate(format: "key == %@", key)
            results = realm.objects(ListEntry).filter(filter).sorted("createdAt", ascending: true)
        }
        
        record = results.first
        
        if let recordValue = record {
            record = recordValue.copyToSave() as? ListEntry
        }
        
        return record
    }
    
    public class func loadAllEntries() -> Results<ListEntry>? {
        let realm = try! Realm()
        
        let results = realm.objects(ListEntry).filter("isDeleted == 0").sorted("createdAt", ascending: false)
        
        return results
    }
    
    public class func loadEntriesContaining(text: String) -> Results<ListEntry>? {
        let realm = try! Realm()
        
        let results = realm.objects(ListEntry).filter("isDeleted == 0 AND textDescription CONTAINS[c] '\(text)'").sorted("createdAt", ascending: false)
        
        return results
    }
}

extension Model {
    static var bundleId: String {
        get {
            let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier;
            
            if let identifier = bundleIdentifier {
                return identifier
            } else {
                #if DEBUG
                    let appBundleId = "com.leave-list.ios-test"
                #else
                    let appBundleId = "com.leave-list.ios"
                #endif
                return appBundleId
            }
        }
    }
    
    static var appGroupId: String {
        get {
            return "group.\(Model.bundleId)"
        }
    }
}

extension String {
    static func uniqueString() -> String {
        return NSUUID().UUIDString
    }
}

