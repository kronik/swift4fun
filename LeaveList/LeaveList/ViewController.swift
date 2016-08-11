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

class ViewController: UIViewController, KeyboardStateDelegate, DataSourceDelegate, UISearchBarDelegate {
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private var lastVisibleView: UIView?
    private var newContentViewCenterPoint = CGPointZero
    private var dataSource: DataSource?
    private var searchBar: UISearchBar?
    
    private var keyword: String = "" {
        didSet {
            dataSource?.updateKeyword(keyword)
        }
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
        tableView.contentInset = UIEdgeInsets(top: -searchBar!.frame.size.height, left: 0, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: tr(.PullToClean))
        refreshControl.addTarget(self, action: #selector(ViewController.triggerRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshControl)
        
        view.addSubview(tableView)
        
        let dataSource = TableViewDataSource()
        
        dataSource.registerView(tableView, eventManager: EventsManager())
        dataSource.delegate = self
        
        self.dataSource = dataSource
        
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
}

