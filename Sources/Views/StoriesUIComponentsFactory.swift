//
//  StoriesUIComponentsFactory.swift
//  Stories
//

import UIKit

public protocol StoryErrorStateViewProtocol: UIView {
  /// A closure for story reloading
  var onDidRequestToReload: (() -> Void)? { get set }
  /// Configures error view for occurred error.
  ///
  /// - Parameter error: Type of error
  func configure(with error: NetworkError)
}

public protocol ActivityIndicatorViewProtocol: UIView {
  /// Starts indicator animation.
  func startAnimating()
  /// Stops indicator animation.
  func stopAnimating()
  /// Hides indicator when animation is stopped.
  var hidesWhenStopped: Bool { get set }
}

extension UIActivityIndicatorView: ActivityIndicatorViewProtocol {}

/// Class that creates customizable UI-components for stories.
open class StoriesUIComponentsFactory {
  public init() {}
  
  /// Returns a class that will be used as cell in stories list view.
  /// Override this method to set custom cell class.
  ///
  /// - Returns: `StoriesListCell` child class type.
  open func storiesListCellType() -> StoriesListCell.Type {
    return StoriesListCell.self
  }
  
  /// Configures and returns custom button that will be used as action button in stories.
  /// Override this method to make custom button.
  ///
  /// - Returns: `UIButton` child class.
  open func makeStoryActionButton() -> UIButton {
    UIButton.makeDefaultButton()
  }
  
  /// Returns a view that would be displayed if an error occurred.
  /// Override this method to make custom error view.
  ///
  /// - Returns: Any class conforming `StoryErrorStateViewProtocol`.
  open func makeErrorStateView() -> StoryErrorStateViewProtocol {
    return DefaultStoryErrorStateView()
  }
  
  /// Returns a view that will be displaying and animating while story is loading.
  /// Override this method to set custom activity indicator.
  ///
  /// - Returns: Any class conforming `ActivityIndicatorViewProtocol`.
  open func makeActivityIndicatorView() -> ActivityIndicatorViewProtocol {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.color = .gray
    return activityIndicator
  }
}
