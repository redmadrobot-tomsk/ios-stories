//
//  UIButton+Configure.swift
//  Stories
//

import UIKit

extension UIButton {
  func configure(with properties: ButtonPropertiesContainer) {
    var configuration = UIButton.Configuration.plain()
    configuration.background.backgroundColor = properties.backgroundColor
    configuration.background.cornerRadius = properties.cornerRadius
    configuration.cornerStyle = .fixed
    configuration.title = properties.title
    configuration.image = properties.image
    configuration.contentInsets = properties.contentEdgeInsets
    configuration.imagePadding = properties.imagePadding
    configuration.titlePadding = properties.titlePadding
    configuration.titleTextAttributesTransformer = titleTextAttributesTransformer(
      isHighlighted: false,
      properties: properties
    )
    self.configuration = configuration
    self.configurationUpdateHandler = { [weak self] button in
      switch button.state {
      case .highlighted:
        configuration.image = properties.highlightedImage
        button.configuration?.titleTextAttributesTransformer = self?.titleTextAttributesTransformer(
          isHighlighted: true,
          properties: properties
        )
      default:
        configuration.image = properties.image
        button.configuration?.titleTextAttributesTransformer = self?.titleTextAttributesTransformer(
          isHighlighted: false,
          properties: properties
        )
      }
    }
  }
  
  private func titleTextAttributesTransformer(
    isHighlighted: Bool,
    properties: ButtonPropertiesContainer
  ) -> UIConfigurationTextAttributesTransformer {
    UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = properties.font
      outgoing.foregroundColor = isHighlighted ? properties.highlightedColor : properties.titleColor
      return outgoing
    }
  }
}
