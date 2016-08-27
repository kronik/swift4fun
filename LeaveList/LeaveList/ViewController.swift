//
//  ViewController.swift
//  LeaveList
//
//  Created by Dmitry on 14/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import RealmSwift
import EZSwiftExtensions
import Keyboardy

class ViewController: UIViewController, KeyboardStateDelegate, DataSourceDelegate,
                      UISearchBarDelegate, UITextViewDelegate {
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private var lastVisibleView: UIView?
    private var newContentViewCenterPoint = CGPointZero
    private var dataSource: DataSource?
    private var searchBar: UISearchBar?
    private var eventManager: EventsManager?
    
    private let editBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    private let textEditField = UITextView()
    private var textEditingRect = CGRectZero
    private var currentEntry: ListEntry?
    
    private var keyword: String = "" {
        didSet {
            dataSource?.updateKeyword(keyword)
        }
    }
    
    convenience init(eventManager: EventsManager) {
        self.init()
        
        self.eventManager = eventManager
    }
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.redColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, w: view.frame.size.width, h: 50))
        
        searchBar!.delegate = self
        
        tableView.tableHeaderView = searchBar
        tableView.frame = view.bounds
        tableView.contentOffset = CGPoint(x: 0, y: searchBar!.frame.size.height)

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: tr(.PullToClean))
        refreshControl.addTarget(self, action: #selector(ViewController.triggerRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshControl)
        
        view.addSubview(tableView)
        
        let dataSource = TableViewDataSource()
        
        dataSource.registerView(tableView, eventManager: EventsManager())
        dataSource.delegate = self
        
        self.dataSource = dataSource
        
        initEditingControls()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: tr(.Add),
                                                            style: .Plain,
                                                            target: self,
                                                            action: #selector(ViewController.onAddButtonTap))
        ez.runThisInMainThread {
            Model.sharedInstance.dataChangeHandler = {
            }
            
            self.registerForKeyboardNotifications(self)
            self.keyword = ""
        }
    }
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    
    func triggerRefresh() {
        searchBar?.text = ""
        dataSource?.clean()
    }
    
    func didFinishReloading() {
        refreshControl.endRefreshing()
    }

    func onAddButtonTap() {
        dataSource?.addRecord("", date: NSDate.distantPast())
    }
    
    func keyboardWillTransition(state: KeyboardState) {
//        guard let lastVisibleView = self.lastVisibleView else {
//            return
//        }
//        
//        let contentView = tableView
//        
        /*
        // keyboard will show or hide
        newContentViewCenterPoint = contentView.center
        
        switch state {
        case .ActiveWithHeight(let height):
            let visibleHeight = contentView.frame.size.height - height
            let lastVisiblePointY = lastVisibleView.frame.origin.y + lastVisibleView.frame.size.height
            
            if (visibleOffset == 0.0) && ((lastVisiblePointY + visibleMargin) > visibleHeight) {
                
                visibleOffset = lastVisiblePointY - visibleHeight + visibleMargin
                
                newContentViewCenterPoint.y -= visibleOffset
            }
            
            logoView.alpha = 0.0
            
            break
        case .Hidden:
            visibleOffset = 0.0
            logoView.alpha = 1.0
            
            newContentViewCenterPoint = CGPointMake(Config.ScreenWidth / 2, Config.ScreenHeight / 2)
            break
        }
 */
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        keyword = searchText
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        keyword = ""
        
        searchBar.resignFirstResponder()
    }
    
    func keyboardTransitionAnimation(state: KeyboardState) {
//        contentView.center = newContentViewCenterPoint
    }
    
    func keyboardDidTransition(state: KeyboardState) {
        // keyboard animation finished
    }
    
    func didChangeRecord(record: ListEntry) {
        print(record)
    }
    
    func initEditingControls() {
        editBackgroundView.frame = view.bounds
            editBackgroundView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapOnBackground))
        
        editBackgroundView.addGestureRecognizer(tapGesture)
        
        /*
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self,
                                         action: #selector(ViewController.didTapOnBackground))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        */
        
        textEditField.backgroundColor = UIColor.clearColor()
        textEditField.font = UIFont.systemFontOfSize(layout.textSize)
        textEditField.textAlignment = .Left
        textEditField.textColor = UIColor.whiteColor()
        textEditField.tintColor = UIColor.whiteColor()
        textEditField.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textEditField.scrollEnabled = false
        textEditField.autoresizesSubviews = false
        textEditField.autoresizingMask = .None
        textEditField.delegate = self
//        textEditField.inputAccessoryView = toolBar
        textEditField.frame = CGRect(x: 0, y: 0, w: layout.screenWidth, h: layout.navigationBarHeight)
        
        editBackgroundView.addSubview(textEditField)
        
        view.addSubview(editBackgroundView)
    }
    
    func requestEditing(record: ListEntry, cell: ListEntryCell) {
        textEditField.text = record.textDescription
        currentEntry = record
        
        let tRect = cell.textRect
        let textRect = tableView.convertRect(cell.frame, toView: view)
        textEditingRect = tableView.convertRect(textRect, toView: view)
        
        textEditField.frame = textEditingRect
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.editBackgroundView.alpha = 1.0
            }) { (finished) in
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.textEditField.frame = CGRect(x: 0, y: layout.navigationBarHeight, w: self.textEditingRect.size.width, h: self.textEditingRect.size.height * 3)
                }) { (finished) in
                    self.textEditField.becomeFirstResponder()
                }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                                            target: self,
                                                            action: #selector(ViewController.didTapOnBackground))

    }
    
    func didTapOnBackground() {
        textEditField.resignFirstResponder()
        currentEntry = nil

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.textEditField.frame = self.textEditingRect
        }) { (finished) in
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.editBackgroundView.alpha = 0.0
            }) { (finished) in
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: tr(.Add),
                                                            style: .Plain,
                                                            target: self,
                                                            action: #selector(ViewController.onAddButtonTap))
        navigationItem.leftBarButtonItem = nil

    }
    
    func textViewDidChange(textView: UITextView) {
        guard let record = currentEntry else {return}
        
        dataSource?.updateDescriptionForEntry(record, text: textView.text)
    }
}

