//
//  UIScreen+DeviceSize.swift
//  Stories
//

import UIKit

extension UIScreen {
  static func isIPhone10ScreenSizeOrHigher() -> Bool {
    return UIScreen.main.bounds.height >= 812
  }
}
