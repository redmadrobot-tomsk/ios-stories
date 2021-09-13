//
//  StoriesDismissAnimationController.swift
//  Stories
//

import UIKit

class StoriesDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  private let storyImageOptions: StoriesListCellImageOptions?
  private let imageURL: URL?
  
  init(storyImageOptions: StoriesListCellImageOptions?, imageURL: URL?) {
    self.storyImageOptions = storyImageOptions
    self.imageURL = imageURL
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return storyImageOptions == nil ? 0.3 : 0.2
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if let frame = storyImageOptions?.frame {
      animateCloseToPreview(context: transitionContext, finalFrame: frame)
    } else {
      animateCloseDown(context: transitionContext)
    }
  }
  
  private func animateCloseToPreview(context: UIViewControllerContextTransitioning, finalFrame: CGRect) {
    guard let sourceViewController = context.viewController(forKey: .from) else { return }
    let duration = transitionDuration(using: context)
    
    CATransaction.begin()
    CATransaction.setAnimationDuration(duration)
    
    let originalImageView = createTransitioningImageView()
    originalImageView.image = sourceViewController.view.snapshotImage(applyScaling: true)
    originalImageView.frame = sourceViewController.view.frame
    context.containerView.addSubview(originalImageView)
    
    let destinationImageView = createTransitioningImageView()
    destinationImageView.setImage(with: imageURL)
    destinationImageView.frame = sourceViewController.view.frame
    destinationImageView.alpha = 0
    context.containerView.addSubview(destinationImageView)
    
    let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
    cornerAnimation.fromValue = 0
    cornerAnimation.toValue = storyImageOptions?.cornerRadius ?? 0

    originalImageView.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
    destinationImageView.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
    
    sourceViewController.view.isHidden = true
    
    UIView.animate(withDuration: duration) {
      originalImageView.frame = finalFrame
      destinationImageView.frame = finalFrame
      destinationImageView.alpha = 1
    } completion: { _ in
      context.completeTransition(!context.transitionWasCancelled)
    }
    
    CATransaction.commit()
  }
  
  private func animateCloseDown(context: UIViewControllerContextTransitioning) {
    guard let sourceViewController = context.viewController(forKey: .from) else { return }
    let duration = transitionDuration(using: context)
    
    var finalFrame = sourceViewController.view.frame
    finalFrame.origin.y += finalFrame.size.height
    
    UIView.animate(withDuration: duration) {
      sourceViewController.view.frame = finalFrame
    } completion: { _ in
      context.completeTransition(!context.transitionWasCancelled)
    }
  }
  
  private func createTransitioningImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = storyImageOptions?.cornerRadius ?? 0
    imageView.layer.maskedCorners = storyImageOptions?.maskedCorners ?? []
    return imageView
  }
}
