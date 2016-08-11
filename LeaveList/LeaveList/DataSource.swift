//
//  DataSource.swift
//  LeaveList
//
//  Created by Dmitry on 2/8/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import EZSwiftExtensions

protocol DataSource {
    func registerView(view: UIView)
    func reload()
    func clean()
    func updateKeyword(keyword: String)
    func addRecord(description: String, date: NSDate)
}

protocol DataSourceDelegate {
    func didChangeRecord(record: ListEntry)
    func didFinishReloading()
}

class TableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource,
                           ListEntryCellDelegate, DataSource {
    
    private var dataCache = [String: String]()
    private var tableView: UITableView?
    private var items: Results<ListEntry>?
    private let cellid = "ListEntryCellId"
    private var keyword: String = "" {
        didSet {
            reloadTimer?.invalidate()
            
            reloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self,
                                                                 selector: #selector(TableViewDataSource.onReloadTimer),
                                                                 userInfo: nil, repeats: false)
        }
    }
    
    private var reloadTimer: NSTimer?
    private var saveTimer: NSTimer?
    
    private var lastTextView: UITextView?
    private var requestKeyboard = false
    
    var delegate: DataSourceDelegate?

    override init() {
    }
    
    func onReloadTimer() {
        reloadTimer?.invalidate()
        
        reloadData(keyword)
    }
    
    func updateKeyword(keyword: String) {
        self.keyword = keyword
    }

    func registerView(view: UIView) {
        guard let tableView = view as? UITableView else { return }
        
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(ListEntryCell.self, forCellReuseIdentifier: cellid)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = layout.tableViewCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounces = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, w: tableView.frame.size.width, h: 1))
        
        self.tableView = tableView
    }
    
    func reload() {
        reloadData(keyword)
    }
    
    func clean() {
        let allRecords = ListEntry.loadAllEntries()
        guard let records = allRecords else { return }
        
        Model.update { 
            while records.count > 0 {
                if let record = records.first {
                    record.isDeleted = true
                }
            }
        }

        updateKeyword("")
    }
    
    func reloadData(keyword: String) {
        items = ListEntry.loadEntriesContaining(keyword)
        
        tableView?.reloadData()
        
        delegate?.didFinishReloading()
        
        if self.requestKeyboard {
            self.requestKeyboard = false
            
            ez.runThisAfterDelay(seconds: 0.5) {
                
                if let cells = self.tableView?.visibleCells as? [ListEntryCell] where cells.count > 0 {
                    cells[0].tryStartEditing()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let listEntry = items![indexPath.row]
        if let text = dataCache[listEntry.key] {
            return ListEntryCell.heightForText(text)
        } else {
            return ListEntryCell.heightForText(listEntry.textDescription)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let itemsValue = items {
            return itemsValue.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellid, forIndexPath: indexPath) as! ListEntryCell
        
        let listEntry = items![indexPath.row]
        
        if let text = dataCache[listEntry.key] {
            cell.title = text
        } else {
            cell.title = listEntry.textDescription
        }
        
        cell.timestamp = listEntry.lastActionDate
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard editingStyle == .Delete else {
            return
        }
        
        let listEntry = items![indexPath.row].copyToSave()
        
        tableView.beginUpdates()
        
        listEntry.isDeleted = true
        
        Model.save(listEntry)
        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        tableView.endUpdates()
    }
    
    func markEntryDone(indexPath: NSIndexPath) {
        let listEntry = items![indexPath.row].copyToSave() as! ListEntry
        
        listEntry.lastActionDate = NSDate()
        
        Model.save(listEntry)
        
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        // add the action button you want to show when swiping on tableView's cell , in this case add the delete button.
        let deleteAction = UITableViewRowAction(style: .Destructive, title: tr(.Delete), handler: { (action , indexPath) -> Void in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        })
        
        let markDoneAction = UITableViewRowAction(style: .Normal, title: tr(.MarkAsDone), handler: { (action , indexPath) -> Void in
            self.markEntryDone(indexPath)
        })
        
        // You can set its properties like normal button
        deleteAction.backgroundColor = UIColor.redColor()
        markDoneAction.backgroundColor = UIColor.darkGrayColor()
        
        return [deleteAction, markDoneAction]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        lastTextView?.resignFirstResponder()
    }
    
    func didUpdateDescriptionForCellAtIndexPath(indexPath: NSIndexPath, textView: UITextView, text: String) {
        tableView?.beginUpdates()
        
        let listEntryKey = items![indexPath.row].key
        
        saveTimer?.invalidate()
        
        lastTextView = textView
        dataCache[listEntryKey] = text
        
        let userInfo = ["key": listEntryKey, "text": text]
        
        saveTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self,
                                                           selector: #selector(TableViewDataSource.onSaveTimer(_:)),
                                                           userInfo: userInfo, repeats: false)
        tableView?.endUpdates()
    }
    
    func didBeginEditing(textView: UITextView) {
        lastTextView = textView
    }
    
    func onSaveTimer(timer: NSTimer) {
        guard let userInfo = timer.userInfo as? [String: String] else { return }
        guard let listEntryKey = userInfo["key"], listEntryText = userInfo["text"] else { return }
        guard let listEntry = ListEntry.loadByKey(listEntryKey) else { return }
        
        listEntry.textDescription = listEntryText
        
        dataCache[listEntryKey] = listEntryText

        Model.save(listEntry)
        
        delegate?.didChangeRecord(listEntry)
    }

    func addRecord(description: String, date: NSDate) {
        requestKeyboard = true
        
        let newRecord = ListEntry()
        
        newRecord.textDescription = description
        newRecord.lastActionDate = date
        
        Model.save(newRecord)
        
        reload()
        
        delegate?.didChangeRecord(newRecord)
    }
}

