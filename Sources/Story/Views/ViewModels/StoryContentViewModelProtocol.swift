//
//  StoryContentViewModelProtocol.swift
//  Stories
//

import UIKit

protocol StoryContentViewModelProtocol {
  var contentAlignment: UIStackView.Alignment? { get set }
  var spacing: CGFloat? { get set }
  
  var header1Properties: LabelPropertiesContainer? { get set }
  var header2Properties: LabelPropertiesContainer? { get set }
  
  var paragraphsProperties: [LabelPropertiesContainer] { get set }
  
  var actionButtonTitle: String? { get }
  
  var componentsFactory: StoriesUIComponentsFactory { get }
}
