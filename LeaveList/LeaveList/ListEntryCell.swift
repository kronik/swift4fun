//
//  ListEntryCell.swift
//  LeaveList
//
//  Created by Dmitry on 14/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import DateTools
import Then

protocol ListEntryCellDelegate {
    func didUpdateDescriptionForCellAtIndexPath(indexPath: NSIndexPath, textView: UITextView, text: String)
    func didBeginEditing(textView: UITextView)
}

class ListEntryCell: UITableViewCell, UITextViewDelegate {
    class func heightForText(text: String) -> CGFloat {
        let size = text.size(UIFont.systemFontOfSize(layout.textSize),
                             width: layout.screenWidth - layout.timeStampWidth - layout.textViewPadding - 15)
        
        return ceil(max(size.height + layout.textViewPadding * 2 , layout.tableViewCellHeight))
    }
    
    private let titleView = VerticallyCenteredTextView().then {
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: $0,
            action: #selector(UITextView.resignFirstResponder))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        $0.backgroundColor = UIColor.clearColor()
        $0.font = UIFont.systemFontOfSize(layout.textSize)
        $0.textAlignment = .Left
        $0.textColor = UIColor.darkGrayColor()
        $0.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        $0.scrollEnabled = false
        $0.autoresizesSubviews = false
        $0.autoresizingMask = .None
        $0.inputAccessoryView = toolBar
    }
    
    private let dateLabel = UILabel().then {
        $0.backgroundColor = UIColor.clearColor()
        $0.font = UIFont.systemFontOfSize(layout.smallTextSize)
        $0.textAlignment = .Center
        $0.textColor = UIColor.darkGrayColor()
    }
    
    private let timeLabel = UILabel().then {
        $0.backgroundColor = UIColor.clearColor()
        $0.font = UIFont.systemFontOfSize(layout.smallTextSize)
        $0.textAlignment = .Center
        $0.textColor = UIColor.darkGrayColor()
    }
    
    private var isInitialised = false
    
    var indexPath: NSIndexPath?
    var key = ""
    var delegate: ListEntryCellDelegate?
    
    var title = "" {
        didSet {
            titleView.text = title
            updateTextView()
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
        if titleView.text.length == 0 {
            titleView.becomeFirstResponder()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isInitialised {
            isInitialised = true
            
            titleView.delegate = self
            
            contentView.addSubview(titleView)
            contentView.addSubview(dateLabel)
            contentView.addSubview(timeLabel)
        }
        
        let xOffset = frame.width - layout.timeStampWidth - layout.textViewPadding
    
        titleView.frame = CGRect(x: layout.textViewPadding, y: layout.textViewPadding,
                                 w: xOffset,
                                 h: frame.height - layout.textViewPadding * 2)
        
        dateLabel.frame = CGRect(x: xOffset, y: (frame.height / 2) - layout.timeStampHeight,
                                 w: layout.timeStampWidth, h: layout.timeStampHeight)
        timeLabel.frame = CGRect(x: xOffset, y: frame.height / 2, w: layout.timeStampWidth, h: layout.timeStampHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.text = ""
        key = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        updateTextView()
        delegate?.didUpdateDescriptionForCellAtIndexPath(indexPath!, textView: textView, text: textView.text)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.didBeginEditing(textView)
    }
    
    private func updateTextView() {
        let size = titleView.sizeThatFits(CGSizeMake(CGRectGetWidth(titleView.bounds), CGFloat(MAXFLOAT)))
        
        var topoffset = (titleView.bounds.size.height - size.height * titleView.zoomScale) / 2.0
        
        topoffset = topoffset < 0.0 ? 0.0 : topoffset
        
        titleView.contentOffset = CGPointMake(0, -topoffset)
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
