//
//  StoryContentViewModel.swift
//  Stories
//

import UIKit

class StoryContentViewModel: StoryContentViewModelProtocol {
  var contentAlignment: UIStackView.Alignment? = .leading
  var spacing: CGFloat? = 16
  var header1Properties: LabelPropertiesContainer?
  var header2Properties: LabelPropertiesContainer?
  var actionButtonTitle: String?
  var paragraphsProperties: [LabelPropertiesContainer]
  
  let componentsFactory: StoriesUIComponentsFactory
  
  init(frame: StoryFrame, componentsFactory: StoriesUIComponentsFactory) {
    self.componentsFactory = componentsFactory
    
    header1Properties = LabelPropertiesContainer(text: frame.content.header1,
                                                 lineHeightMultiple: 1.2,
                                                 font: .systemFont(ofSize: 32),
                                                 textColor: frame.content.textColor,
                                                 textAlignment: .natural,
                                                 numberOfLines: 0)
    header2Properties = LabelPropertiesContainer(text: frame.content.header2,
                                                 lineHeightMultiple: 1.4,
                                                 font: .systemFont(ofSize: 23),
                                                 textColor: frame.content.textColor,
                                                 textAlignment: .natural,
                                                 numberOfLines: 0)
    
    actionButtonTitle = frame.content.action?.text
    
    paragraphsProperties = frame.content.paragraphs.map {
      LabelPropertiesContainer(text: $0,
                               lineHeightMultiple: 1.5,
                               font: .systemFont(ofSize: 16),
                               textColor: frame.content.textColor,
                               textAlignment: .natural,
                               numberOfLines: 0)
    }
  }
}
