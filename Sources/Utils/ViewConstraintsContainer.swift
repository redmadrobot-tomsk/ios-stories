//
//  ViewConstraintsContainer.swift
//  Stories
//

import UIKit

struct ViewConstraintsContainer {
  var topOffset: CGFloat?
  var bottomOffset: CGFloat?
  var leadingOffset: CGFloat?
  var trailingOffset: CGFloat?
  var centerYOffset: CGFloat?
  var centerXOffset: CGFloat?
  var width: CGFloat?
  var height: CGFloat?
  
  init(topOffset: CGFloat? = nil,
       bottomOffset: CGFloat? = nil,
       leadingOffset: CGFloat? = nil,
       trailingOffset: CGFloat? = nil,
       centerYOffset: CGFloat? = nil,
       centerXOffset: CGFloat? = nil,
       width: CGFloat? = nil,
       height: CGFloat? = nil) {
    self.topOffset = topOffset
    self.bottomOffset = bottomOffset
    self.leadingOffset = leadingOffset
    self.trailingOffset = trailingOffset
    self.centerYOffset = centerYOffset
    self.centerXOffset = centerXOffset
    self.width = width
    self.height = height
  }
}
