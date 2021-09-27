//
//  StoryProgressBar.swift
//  Stories
//

import UIKit

enum StoryProgressBarState {
  case reset, pause, resume, start(TimeInterval)
}

class StoryProgressBar: UIStackView {
  
  // MARK: - Properties
  
  var onDidFinishShowFrame: (() -> Void)?
  
  private var currentFrameIndex: Int = -1
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(framesCount: Int, startFrameIndex: Int, trackColor: UIColor, progressColor: UIColor, spacing: CGFloat) {
    self.spacing = spacing
    currentFrameIndex = startFrameIndex
    for index in 0..<framesCount {
      let progressView = StoryProgressView()
      setupProgressView(progressView)
      if index < startFrameIndex {
        progressView.setProgress(1, animated: false)
      }

      configureColors(trackColor: trackColor, progressColor: progressColor, for: progressView)
    }
  }
  
  func reconfigure(startFrameIndex: Int, trackColor: UIColor, progressColor: UIColor) {
    let progressViews = arrangedSubviews.filter { $0 is StoryProgressView }
    guard let currentProgressView = progressViews.element(at: currentFrameIndex) as? StoryProgressView,
      let futureProgressView = progressViews.element(at: startFrameIndex) as? StoryProgressView else {
        return
    }
    currentProgressView.resetProgress()
    
    if startFrameIndex != currentFrameIndex {
      let progress: Float = startFrameIndex > currentFrameIndex ? 1 : 0
      currentProgressView.setProgress(progress, animated: false)
      currentFrameIndex = startFrameIndex
      futureProgressView.resetProgress()
    }
    
    progressViews.forEach {
      if let progressView = $0 as? UIProgressView {
        configureColors(trackColor: trackColor, progressColor: progressColor, for: progressView)
      }
    }
  }
  
  private func configureColors(trackColor: UIColor, progressColor: UIColor, for progressView: UIProgressView) {
    progressView.trackTintColor = trackColor
    progressView.progressTintColor = progressColor
  }
  
  // MARK: - Setup
  
  private func setup() {
    axis = .horizontal
    distribution = .fillEqually
  }
  
  private func setupProgressView(_ progressView: StoryProgressView) {
    addArrangedSubview(progressView)
    progressView.progressViewStyle = .bar
    progressView.layer.masksToBounds = true
  }
  
  func start(duration: TimeInterval) {
    let currentProgressView = arrangedSubviews.element(at: currentFrameIndex) as? StoryProgressView
    currentProgressView?.simulateProgress(withDuration: duration) { [unowned self] finished in
      if finished {
        self.currentFrameIndex += 1
        self.onDidFinishShowFrame?()
      }
    }
  }
  
  func reset() {
    let progressViews = arrangedSubviews.filter { $0 is StoryProgressView }
    guard let currentProgressView = progressViews.element(at: currentFrameIndex) as? StoryProgressView else {
        return
    }
    currentProgressView.resetProgress()
  }
  
  func updateCurrentFrameIndex(with frameIndex: Int) {
    currentFrameIndex = frameIndex
  }
  
  // MARK: - Controls
  
  func pause() {
    let currentProgressView = arrangedSubviews.element(at: currentFrameIndex) as? StoryProgressView
    currentProgressView?.pauseSimulation()
  }
  
  func resume() {
    let currentProgressView = arrangedSubviews.element(at: currentFrameIndex) as? StoryProgressView
    currentProgressView?.resumeSimulation()
  }
}
