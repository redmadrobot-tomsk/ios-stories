//
//  StoriesShowing.swift
//  Stories
//

import UIKit

protocol StoriesShowing: StoriesContainerViewControllerDelegate {
  var transitionAnimator: TransitionAnimator { get }
  
  func setupStories()
  func showStories(stories: [Story], storyIndex: Int, visibleStoryImageOptions: [Int: StoriesListCellImageOptions])
  func currentStoryIndexDidChange(to index: Int)
}

extension StoriesShowing where Self: StoriesListView {
  func setupStories() {
    presentingViewController?.transitioningDelegate = transitionAnimator
  }
  
  func showStories(stories: [Story], storyIndex: Int, visibleStoryImageOptions: [Int: StoriesListCellImageOptions]) {
    guard let imageURL = stories.element(at: storyIndex)?.imageURL else { return }
    let imageOptions = visibleStoryImageOptions[storyIndex]
    transitionAnimator.storiesPresentAnimationController = StoriesPresentAnimationController(storyImageOptions: imageOptions,
                                                                                             imageURL: imageURL)

    let viewControllers = stories.map { story in
      return StoryViewController(viewModel: StoryViewModel(story: story,
                                                           componentsFactory: uiComponentsFactory))
    }
    
    let container = StoriesContainerViewController(childViewControllers: viewControllers,
                                                   currentStoryIndex: storyIndex,
                                                   visibleStoryImageOptions: visibleStoryImageOptions)
    container.delegate = self
    container.transitioningDelegate = transitionAnimator
    container.modalPresentationStyle = .custom

    _ = container.view
    container.prepareForPresenting()
    
    presentingViewController?.present(container, animated: true, completion: nil)
  }
  
  func currentStoryIndexDidChange(to index: Int) {}
}
