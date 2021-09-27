//
//  UIView+SnapshotImage.swift
//  Stories
//

import UIKit

extension UIView {
  func snapshotImage(applyScaling: Bool = false) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    
    if applyScaling {
      context.concatenate(CGAffineTransform(scaleX: self.transform.a, y: self.transform.d))
    }
    
    self.layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}
