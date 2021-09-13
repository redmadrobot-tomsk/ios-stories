//
//  UIView+Gradient.swift
//  Stories
//

import UIKit

private let gradientLayerName = "gradientLayer"

extension UIView {
  func addGradient(startColor: UIColor,
                   endColor: UIColor,
                   startPoint: CGPoint,
                   endPoint: CGPoint) {
    if let sublayers = layer.sublayers {
      for sublayer in sublayers where sublayer.name == gradientLayerName {
        sublayer.frame = bounds
        return
      }
    }
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.name = gradientLayerName
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
    
    layer.insertSublayer(gradientLayer, at: 0)
  }

  func removeGradient() {
    if let sublayer = layer.sublayers?.first(where: { $0.name == gradientLayerName }) {
      sublayer.removeFromSuperlayer()
    }
  }
}
