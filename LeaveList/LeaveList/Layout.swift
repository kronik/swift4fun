//
//  Layout.swift
//  LeaveList
//
//  Created by Dmitry on 14/7/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit

protocol Layout {
    var timeStampWidth:CGFloat { get }
    var timeStampHeight:CGFloat { get }
    var textSize:CGFloat { get }
    var smallTextSize:CGFloat { get }
    var textPadding:CGFloat { get }
    var textViewPadding:CGFloat { get }
    var screenRect:CGRect { get }
    var screenWidth:CGFloat { get }
    var screenHeight:CGFloat { get }
    var tableViewCellHeight:CGFloat { get }
    var navigationBarHeight:CGFloat { get }
}

extension Layout {
    var timeStampWidth: CGFloat { get { return 100.0 } }
    var timeStampHeight: CGFloat { get { return 15.0 } }
    var textSize: CGFloat { get { return 15.0 } }
    var smallTextSize: CGFloat { get { return 12.0 } }
    var textPadding: CGFloat { get { return 8.0 } }
    var textViewPadding: CGFloat { get { return 10.0 } }
    var screenRect:CGRect { get { return UIScreen.mainScreen().bounds } }
    var screenWidth:CGFloat { get { return UIScreen.mainScreen().bounds.size.width } }
    var screenHeight:CGFloat { get { return UIScreen.mainScreen().bounds.size.height } }
    var tableViewCellHeight:CGFloat { get { return 50.0 } }
    var navigationBarHeight:CGFloat { get { return 68.0 } }
}

let layout: Layout = UIScreen.mainScreen().bounds.size.height > 568.0 ? LayoutForIPhone6() : LayoutForIPhoneSE()

struct LayoutForIPhone6: Layout {
}

struct LayoutForIPhoneSE: Layout {
}
