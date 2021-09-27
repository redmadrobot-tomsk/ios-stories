//
//  StoryControlView.swift
//  Stories
//

import UIKit

class StoryControlView: UIView {
  // MARK: - Properties
  
  var onDidRequestToClose: (() -> Void)?
  var onDidTapLike: (() -> Void)?
  var onDidRequestToShowNextStory: (() -> Void)?
  
  private let progressBar = StoryProgressBar()
  private let closeButton = UIButton(type: .system)
  private let likeButton = UIButton(type: .system)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
   setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: StoryControlViewModelProtocol) {
    closeButton.tintColor = viewModel.controlsTintColor
    likeButton.tintColor = viewModel.controlsTintColor
    closeButton.setImage(viewModel.closeIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
    
    progressBar.snp.removeConstraints()
    progressBar.setEqualToSuperviewConstraints(from: viewModel.progressViewConstraints)
    
    makeConstraints(from: viewModel.closeButtonConstraints, for: closeButton)
    if let likeButtonConstraints = viewModel.likeButtonConstraints {
      likeButton.isHidden = false
      makeConstraints(from: likeButtonConstraints, for: likeButton)
    } else {
      likeButton.isHidden = true
    }
  }
  
  // MARK: Setup
  
  private func setup() {
    addSubview(progressBar)
    setupCloseButton()
    setupLikeButton()
  }
  
  private func setupCloseButton() {
    closeButton.addTarget(self, action: #selector(onCloseButtonTap(_:)), for: .touchUpInside)
    addSubview(closeButton)
  }
  
  private func setupLikeButton() {
    likeButton.addTarget(self, action: #selector(onLikeButtonTap(_:)), for: .touchUpInside)
    addSubview(likeButton)
    
    likeButton.snp.makeConstraints { make in
      make.centerY.width.height.equalTo(closeButton)
      make.leading.equalToSuperview().offset(16)
    }
  }
  
  // MARK: - Actions
  
  @objc private func onCloseButtonTap(_ sender: UIButton) {
    onDidRequestToClose?()
  }
  
  @objc private func onLikeButtonTap(_ sender: UIButton) {
    onDidTapLike?()
  }
}

// MARK: Public Methods

extension StoryControlView {
  func setLikeButtonImage(image: UIImage?) {
    likeButton.setImage(image, for: .normal)
  }
  
  func setControlsVisibility(withAnimationDuration duration: TimeInterval, isVisible: Bool) {
    UIView.animate(withDuration: duration) {
      self.closeButton.alpha = isVisible ? 1 : 0
      self.progressBar.alpha = isVisible ? 1 : 0
      self.likeButton.alpha = isVisible ? 1 : 0
    }
  }
}

private extension StoryControlView {
  func makeConstraints(from constraints: ViewConstraintsContainer, for view: UIView) {
    view.snp.remakeConstraints { make in
      if let top = constraints.topOffset {
        make.top.equalTo(progressBar.snp.bottom).offset(top)
      }
      if let bottom = constraints.bottomOffset {
        make.bottom.equalToSuperview().offset(bottom)
      }
      if let trailing = constraints.trailingOffset {
        make.trailing.equalToSuperview().offset(trailing)
      }
      if let leading = constraints.leadingOffset {
        make.leading.equalToSuperview().offset(leading)
      }
      if let centerXOffset = constraints.centerXOffset {
        make.centerX.equalToSuperview().offset(centerXOffset)
      }
      if let centerYOffset = constraints.centerYOffset {
        make.centerY.equalToSuperview().offset(centerYOffset)
      }
      if let width = constraints.width {
        make.width.equalTo(width)
      }
      if let height = constraints.height {
        make.height.equalTo(height)
      }
    }
  }
}

// MARK: ProgressBar

extension StoryControlView {
  func configureProgressBar(viewModel: StoryViewModelProtocol,
                            isReconfiguring: Bool,
                            trackColor: UIColor,
                            progressColor: UIColor,
                            spacing: CGFloat) {
    likeButton.setImage(viewModel.likeButtonImage, for: .normal)
    if isReconfiguring {
      progressBar.reconfigure(startFrameIndex: viewModel.currentFrameIndex,
                              trackColor: trackColor,
                              progressColor: progressColor)
    } else {
      progressBar.configure(framesCount: viewModel.framesCount,
                            startFrameIndex: viewModel.currentFrameIndex,
                            trackColor: trackColor,
                            progressColor: progressColor,
                            spacing: spacing)
      progressBar.onDidFinishShowFrame = { [weak self] in
        self?.onDidRequestToShowNextStory?()
      }
    }
  }
  func updateProgressBarFrameIndex(with frameIndex: Int) {
    progressBar.updateCurrentFrameIndex(with: frameIndex)
  }
  func changeProgressBarState(_ state: StoryProgressBarState) {
    switch state {
    case .reset:
      progressBar.reset()
    case .pause:
      progressBar.pause()
    case .resume:
      progressBar.resume()
    case .start(let duration):
      progressBar.start(duration: duration)
    }
  }
}
