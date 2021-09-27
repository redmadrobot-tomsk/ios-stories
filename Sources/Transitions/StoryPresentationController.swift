//
//  StoryPresentationController.swift
//  Stories
//

import UIKit

private extension Constants {
  static let closeStoryThreshold: CGFloat = 48
  static let rubberBandCoefficient: CGFloat = 0.25
  static let maxDistance: CGFloat = UIScreen.main.bounds.height
  static let minScale: CGFloat = 0.75
}

class StoryPresentationController: UIPresentationController {
  // MARK: - Properties
  
  private let overlayView = UIView()
  
  private var storiesContainerViewController: StoriesContainerViewController? {
    return presentedViewController as? StoriesContainerViewController
  }
  
  // MARK: - Init
  
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setup()
  }
  
  // MARK: - Overrides
  
  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()
    containerView?.insertSubview(overlayView, at: 0)
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
      self?.overlayView.alpha = 1
    }, completion: nil)
  }
  
  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    overlayView.frame = containerView?.frame ?? .zero
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    super.presentationTransitionDidEnd(completed)
    if !completed {
      self.overlayView.removeFromSuperview()
    }
  }
  
  override func dismissalTransitionWillBegin() {
    super.dismissalTransitionWillBegin()
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
      self?.overlayView.alpha = 0
    }, completion: nil)
  }
  
  override func dismissalTransitionDidEnd(_ completed: Bool) {
    super.dismissalTransitionDidEnd(completed)
    if completed {
      self.overlayView.removeFromSuperview()
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    presentedViewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                                             action: #selector(handlePan(_:))))
    
    overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
    overlayView.alpha = 0
  }
  
  // MARK: - Actions
  
  @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
    let translationY = recognizer.translation(in: presentedViewController.view).y
    guard translationY >= 0 else { return }
    
    switch recognizer.state {
    case .began:
      storiesContainerViewController?.pause()
    case .changed:
      handleTranslation(translationY)
    case .ended, .cancelled:
      if rubberBandClamp(translation: translationY) > Constants.closeStoryThreshold {
        storiesContainerViewController?.close()
      } else {
        animateToDefaultState()
      }
    case .failed:
      animateToDefaultState()
    default:
      break
    }
  }
  
  // MARK: - Private methods
  
  private func handleTranslation(_ translation: CGFloat) {
    let clampedTranslation = rubberBandClamp(translation: translation)
    let translate = CGAffineTransform(translationX: 0, y: clampedTranslation)
    let sideScale = max((Constants.maxDistance - clampedTranslation) / Constants.maxDistance,
                        Constants.minScale)
    let scale = CGAffineTransform(scaleX: sideScale, y: sideScale)
    presentedViewController.view.transform = translate.concatenating(scale)
  }
  
  private func animateToDefaultState() {
    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
      let translate = CGAffineTransform(translationX: 0, y: 0)
      let scale = CGAffineTransform(scaleX: 1, y: 1)
      self.presentedViewController.view.transform = translate.concatenating(scale)
    } completion: { _ in
      self.storiesContainerViewController?.resume()
    }
  }
  
  private func rubberBandClamp(translation: CGFloat) -> CGFloat {
    let coefficient: CGFloat = Constants.rubberBandCoefficient
    let maxDestination: CGFloat = Constants.maxDistance
    
    return (1 - (1 / ((translation * coefficient / maxDestination) + 1))) * maxDestination
  }
}
