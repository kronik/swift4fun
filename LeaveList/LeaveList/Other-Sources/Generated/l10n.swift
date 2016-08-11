// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
  case DontForgetTo
  case PullToReload
  case PullToClean
  case Add
  case Refreshing
  case Deleting
  case Delete
  case MarkAsDone
}

extension L10n : CustomStringConvertible {
  var description : String { return self.string }

  var string : String {
    switch self {
      case .DontForgetTo:
        return L10n.tr("DontForgetTo")
      case .PullToReload:
        return L10n.tr("PullToReload")
      case .PullToClean:
        return L10n.tr("PullToClean")
      case .Add:
        return L10n.tr("Add")
      case .Refreshing:
        return L10n.tr("Refreshing")
      case .Deleting:
        return L10n.tr("Deleting")
      case .Delete:
        return L10n.tr("Delete")
      case .MarkAsDone:
        return L10n.tr("MarkAsDone")
    }
  }

  private static func tr(key: String, _ args: CVarArgType...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}

