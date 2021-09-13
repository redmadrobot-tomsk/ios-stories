//
//  StoriesPresentAnimationController.swift
//  Stories
//

import UIKit

class StoriesPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  private let storyImageOptions: StoriesListCellImageOptions?
  private let imageURL: URL?

  init(storyImageOptions: StoriesListCellImageOptions?, imageURL: URL?) {
    self.storyImageOptions = storyImageOptions
    self.imageURL = imageURL
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let destinationViewController = transitionContext.viewController(forKey: .to) else { return }
    
    let originalDestinationViewControllerFrame = transitionContext.finalFrame(for: destinationViewController)
    let imageViewRect = imageInitialFrame(shownFromRect: storyImageOptions?.frame,
                                          destinationViewControllerFrame: destinationViewController.view.frame)

    transitionContext.containerView.addSubview(destinationViewController.view)
    
    destinationViewController.view.frame = originalDestinationViewControllerFrame

    var firstFrameImageView: UIImageView?
    let frameImageView = createFirstFrameImageView(transitionContext: transitionContext)
    frameImageView.frame = imageViewRect
    firstFrameImageView = frameImageView
    firstFrameImageView?.image = destinationViewController.view.snapshotImage()

    let imageView = createStoryImageView(imageURL: imageURL, transitionContext: transitionContext)
    imageView.frame = imageViewRect

    let duration = transitionDuration(using: transitionContext)
    let fadeOutDuration: TimeInterval = 0.15
    
    destinationViewController.view.isHidden = true
    
    CATransaction.begin()
    CATransaction.setAnimationDuration(duration - fadeOutDuration)
    
    UIView.animate(withDuration: duration - fadeOutDuration, animations: {
       imageView.frame = originalDestinationViewControllerFrame
       if let frameImageView = firstFrameImageView {
         frameImageView.frame = originalDestinationViewControllerFrame
         imageView.alpha = 0
       }
     }, completion: { _ in
      destinationViewController.view.isHidden = false
      if let frameImageView = firstFrameImageView {
        imageView.removeFromSuperview()
        frameImageView.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      } else {
        UIView.animate(withDuration: fadeOutDuration, animations: {
          imageView.alpha = 0
        }, completion: { _ in
          imageView.removeFromSuperview()
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
      }
    })
    
    let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
    cornerAnimation.fromValue = storyImageOptions?.cornerRadius ?? 0
    cornerAnimation.toValue = 0

    imageView.layer.cornerRadius = 0
    imageView.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
    
    firstFrameImageView?.layer.cornerRadius = 0
    firstFrameImageView?.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
    
    CATransaction.commit()
  }

  private func createFirstFrameImageView(transitionContext: UIViewControllerContextTransitioning) -> UIImageView {
    let frameImageView = UIImageView()
    transitionContext.containerView.addSubview(frameImageView)
    frameImageView.contentMode = .scaleAspectFill
    frameImageView.clipsToBounds = true
    frameImageView.layer.cornerRadius = storyImageOptions?.cornerRadius ?? 0
    frameImageView.layer.maskedCorners = storyImageOptions?.maskedCorners ?? []
    return frameImageView
  }

  private func createStoryImageView(imageURL: URL?,
                                    transitionContext: UIViewControllerContextTransitioning) -> UIImageView {
    let imageView = UIImageView()
    imageView.setImage(with: imageURL)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = storyImageOptions?.cornerRadius ?? 0
    imageView.layer.maskedCorners = storyImageOptions?.maskedCorners ?? []
    transitionContext.containerView.addSubview(imageView)
    return imageView
  }

  private func imageInitialFrame(shownFromRect: CGRect?, destinationViewControllerFrame: CGRect) -> CGRect {
    var imageViewRect: CGRect
    if let rect = shownFromRect {
      imageViewRect = rect
    } else {
      var rect = destinationViewControllerFrame
      rect.origin.y += rect.size.height
      imageViewRect = rect
    }
    return imageViewRect
  }
}
