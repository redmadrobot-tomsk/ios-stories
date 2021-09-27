//
//  UIButton+Configure.swift
//  Stories
//

import UIKit

extension UIButton {
  func configure(with properties: ButtonPropertiesContainer) {
    backgroundColor = properties.backgroundColor
    layer.cornerRadius = properties.cornerRadius
    setTitle(properties.title, for: .normal)
    setTitleColor(properties.titleColor, for: .normal)
    setTitleColor(properties.highlightedColor, for: .highlighted)
    titleLabel?.font = properties.font
    setImage(properties.image, for: .normal)
    setImage(properties.highlightedImage, for: .highlighted)
    imageEdgeInsets = properties.imageEdgeInsets
    titleEdgeInsets = properties.titleEdgeInsets
    contentEdgeInsets = properties.contentEdgeInsets
  }
}
