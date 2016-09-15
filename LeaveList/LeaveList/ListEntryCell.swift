//
//  ListEntryCell.swift
//  LeaveList
//
//  Created by Dmitry on 14/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import DateTools

protocol ListEntryCellDelegate {
    func requestEditing(textLabel: UILabel, indexPath: NSIndexPath)
}

class ListEntryCell: UITableViewCell {
    class func heightForText(text: String) -> CGFloat {
        let size = text.size(UIFont.systemFontOfSize(layout.textSize),
                             width: layout.screenWidth - layout.timeStampWidth - layout.textViewPadding - 15)
        
        return ceil(max(size.height + layout.textViewPadding * 2 , layout.tableViewCellHeight))
    }
    
    var titleView: UILabel = {
        let label = UILabel()
        
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(layout.textSize)
        label.textAlignment = .Left
        label.textColor = UIColor.darkGrayColor()
        label.autoresizesSubviews = false
        label.autoresizingMask = .None
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(layout.smallTextSize)
        label.textAlignment = .Center
        label.textColor = UIColor.darkGrayColor()
        
        return label
    }()
    
    private let timeLabel = UILabel().then {
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(layout.smallTextSize)
        label.textAlignment = .Center
        label.textColor = UIColor.darkGrayColor()
    }
    
    private var isInitialised = false
    
    var indexPath: NSIndexPath?
    var key = ""
    var delegate: ListEntryCellDelegate?
    
    var title = "" {
        didSet {
            titleView.text = title            
        }
    }
    
    var timestamp = NSDate() {
        didSet {
            if abs(timestamp.yearsAgo()) > 10 {
                dateLabel.text = ""
                timeLabel.text = ""
            } else {
                dateLabel.text = timestamp.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
                timeLabel.text = timestamp.toString(dateStyle: .NoStyle, timeStyle: .ShortStyle)
            }
        }
    }
    
    func tryStartEditing() {
//        if titleView.text.length == 0 {
//            titleView.becomeFirstResponder()
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isInitialised {
            isInitialised = true
            
            contentView.addSubview(titleView)
            contentView.addSubview(dateLabel)
            contentView.addSubview(timeLabel)
            
            titleView.userInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ListEntryCell.didTapOnText))
            
            titleView.addGestureRecognizer(tapGesture)
        }
        
        let xOffset = frame.width - layout.timeStampWidth - layout.textViewPadding
    
        titleView.frame = CGRect(x: layout.textViewPadding, y: layout.textViewPadding,
                                 w: xOffset,
                                 h: frame.height - layout.textViewPadding * 2)
        
        dateLabel.frame = CGRect(x: xOffset, y: (frame.height / 2) - layout.timeStampHeight,
                                 w: layout.timeStampWidth, h: layout.timeStampHeight)
        timeLabel.frame = CGRect(x: xOffset, y: frame.height / 2, w: layout.timeStampWidth, h: layout.timeStampHeight)
    }
    
    var textRect: CGRect {
        get {
            return convertRect(titleView.frame, toView: self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.text = ""
        key = ""
    }
    
    func didTapOnText() {
        delegate?.requestEditing(titleView, indexPath: indexPath!)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    var first: String {
        return String(self[startIndex])
    }
    var last: String {
        return String(self[endIndex.predecessor()])
    }
    
    var lowercaseFirst:String {
        var original = self
        
        if original.isEmpty {
            return original
        }
        
        original.replaceRange(original.startIndex...original.startIndex, with: String(original[original.startIndex]).lowercaseString)
        
        return original
    }
    
    var uppercaseFirst:String {
        var original = self
        
        if original.isEmpty {
            return original
        }
        
        original.replaceRange(original.startIndex...original.startIndex, with: String(original[original.startIndex]).uppercaseString)
        
        return original
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
    }
    
    func size(font: UIFont, width: CGFloat) -> CGSize {
        let maximumTextSize = CGSizeMake(width, 9999)
        let textString = self as NSString
        
        let rect = textString.boundingRectWithSize(maximumTextSize, options: .UsesLineFragmentOrigin,
                                                   attributes: [NSFontAttributeName: font], context: nil)
        
        return CGSizeMake(rect.width, rect.height)
    }
}

class VerticallyCenteredTextView: UITextView {
//    override var contentSize: CGSize {
//        didSet {
//            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
//            topCorrection = max(0, topCorrection)
//            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
//        }
//    }
}
