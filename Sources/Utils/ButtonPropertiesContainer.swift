//
//  ButtonPropertiesContainer.swift
//  Stories
//

import UIKit

struct ButtonPropertiesContainer {
  var backgroundColor: UIColor
  var cornerRadius: CGFloat
  var titleColor: UIColor
  var highlightedColor: UIColor?
  var title: String?
  var font: UIFont
  var image: UIImage?
  var highlightedImage: UIImage?
  var imageEdgeInsets: UIEdgeInsets
  var titleEdgeInsets: UIEdgeInsets
  var contentEdgeInsets: UIEdgeInsets
  
  init(backgroundColor: UIColor,
       cornerRadius: CGFloat = 0,
       titleColor: UIColor,
       highlightedColor: UIColor? = nil,
       title: String?,
       font: UIFont,
       image: UIImage?,
       highlightedImage: UIImage? = nil,
       imageEdgeInsets: UIEdgeInsets = .zero,
       titleEdgeInsets: UIEdgeInsets = .zero,
       contentEdgeInsets: UIEdgeInsets = .zero) {
    self.backgroundColor = backgroundColor
    self.cornerRadius = cornerRadius
    self.titleColor = titleColor
    self.highlightedColor = highlightedColor
    self.title = title
    self.font = font
    self.image = image
    self.highlightedImage = highlightedImage
    self.imageEdgeInsets = imageEdgeInsets
    self.titleEdgeInsets = titleEdgeInsets
    self.contentEdgeInsets = contentEdgeInsets
  }
}
