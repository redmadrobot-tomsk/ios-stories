//
//  UILabel+Configure.swift
//  Stories
//

import UIKit

extension UILabel {
  func configure(with properties: LabelPropertiesContainer) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = properties.lineHeightMultiple
    paragraphStyle.alignment = properties.textAlignment
    let attributes: [NSAttributedString.Key: Any] = [.font: properties.font,
                                                     .foregroundColor: properties.textColor,
                                                     .paragraphStyle: paragraphStyle]
    attributedText = NSAttributedString(string: properties.text ?? "",
                                        attributes: attributes)
    numberOfLines = properties.numberOfLines
  }
}
