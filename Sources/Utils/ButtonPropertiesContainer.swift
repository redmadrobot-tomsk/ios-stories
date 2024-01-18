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
  var imagePadding: CGFloat
  var titlePadding: CGFloat
  var contentEdgeInsets: NSDirectionalEdgeInsets
  
  init(backgroundColor: UIColor,
       cornerRadius: CGFloat = 0,
       titleColor: UIColor,
       highlightedColor: UIColor? = nil,
       title: String?,
       font: UIFont,
       image: UIImage?,
       highlightedImage: UIImage? = nil,
       imagePadding: CGFloat = 0,
       titlePadding: CGFloat = 0,
       contentEdgeInsets: NSDirectionalEdgeInsets = .zero) {
    self.backgroundColor = backgroundColor
    self.cornerRadius = cornerRadius
    self.titleColor = titleColor
    self.highlightedColor = highlightedColor
    self.title = title
    self.font = font
    self.image = image
    self.highlightedImage = highlightedImage
    self.imagePadding = imagePadding
    self.titlePadding = titlePadding
    self.contentEdgeInsets = contentEdgeInsets
  }
}
