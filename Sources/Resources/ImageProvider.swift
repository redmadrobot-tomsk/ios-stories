//
//  ImageProvider.swift
//  Stories
//

import UIKit

class ImageProvider {
  static func close() -> UIImage? {
    return image(named: "close")
  }
  
  static func image(named: String) -> UIImage? {
    return UIImage(named: named, in: Bundle(for: self), compatibleWith: nil)
  }
}
