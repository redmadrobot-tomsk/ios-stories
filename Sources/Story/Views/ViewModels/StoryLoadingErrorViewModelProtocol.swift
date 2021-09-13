//
//  StoryLoadingErrorViewModelProtocol.swift
//  Stories
//

import UIKit

protocol StoryLoadingErrorViewModelProtocol {
  var titlePropertiesForServerError: LabelPropertiesContainer { get set }
  var titlePropertiesForOfflineError: LabelPropertiesContainer { get set }
  var titleConstraints: ViewConstraintsContainer { get set }
  
  var subtitlePropertiesForServerError: LabelPropertiesContainer? { get set }
  var subtitlePropertiesForOfflineError: LabelPropertiesContainer? { get set }
  var subtitleConstraints: ViewConstraintsContainer? { get set }
  
  var refreshButtonProperties: ButtonPropertiesContainer { get set }
  var refreshButtonConstraints: ViewConstraintsContainer { get set }
}
