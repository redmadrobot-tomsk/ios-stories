//
//  LabelPropertiesContainer.swift
//  Stories
//

import UIKit

struct LabelPropertiesContainer {
  var text: String?
  var lineHeightMultiple: CGFloat
  var font: UIFont
  var textColor: UIColor
  var textAlignment: NSTextAlignment
  var numberOfLines: Int
  var spacingAfterLabel: CGFloat?
  
  init(text: String?,
       lineHeightMultiple: CGFloat,
       font: UIFont,
       textColor: UIColor,
       textAlignment: NSTextAlignment,
       numberOfLines: Int,
       spacingAfterLabel: CGFloat? = nil) {
    self.text = text
    self.lineHeightMultiple = lineHeightMultiple
    self.font = font
    self.textColor = textColor
    self.textAlignment = textAlignment
    self.numberOfLines = numberOfLines
    self.spacingAfterLabel = spacingAfterLabel
  }
}
