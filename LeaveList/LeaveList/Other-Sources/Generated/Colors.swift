// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

extension UIColor {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension UIColor {
  enum Name {
    case Black
    case DarkColor
    case DarkGrey
    case Grey
    case LightColor
    case LightGrey
    case MainColor
    case MiddleColor
    case Red
    case White

    static let rgbaValues: [Name:UInt32] = [
      .Black : 0xff,
      .DarkColor : 0x212121ff,
      .DarkGrey : 0x222324ff,
      .Grey : 0x444a59ff,
      .LightColor : 0xfafafaff,
      .LightGrey : 0xb2b2c2ff,
      .MainColor : 0x9e9e9eff,
      .MiddleColor : 0xf5f5f5ff,
      .Red : 0xff0060ff,
      .White : 0xf5f3f7ff,
    ]

    var rgbaValue: UInt32! {
      return Name.rgbaValues[self]
    }
  }

  convenience init(named name: Name) {
    self.init(rgbaValue: name.rgbaValue)
  }
}

