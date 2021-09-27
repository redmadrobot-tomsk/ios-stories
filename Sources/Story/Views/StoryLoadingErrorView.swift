//
//  StoryLoadingErrorView.swift
//  Stories
//

import UIKit

class StoryLoadingErrorView: UIView {
  // MARK: - Properties
  
  var onDidRequestToRefresh: (() -> Void)?
  
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let refreshButton = UIButton()
  
  private var viewModel: StoryLoadingErrorViewModelProtocol?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: StoryLoadingErrorViewModelProtocol) {
    self.viewModel = viewModel
    titleLabel.configure(with: viewModel.titlePropertiesForOfflineError)
    titleLabel.snp.removeConstraints()
    titleLabel.setEqualToSuperviewConstraints(from: viewModel.titleConstraints)
    
    refreshButton.configure(with: viewModel.refreshButtonProperties)
    
    if let subtitleProperties = viewModel.subtitlePropertiesForOfflineError,
      let subtitleConstraints = viewModel.subtitleConstraints {
      subtitleLabel.configure(with: subtitleProperties)
      subtitleLabel.isHidden = false
      subtitleLabel.snp.removeConstraints()
      setSubtitleLabelConstraints(from: subtitleConstraints)
      setRefreshButtonConstraints(from: viewModel.refreshButtonConstraints, hasSubtitle: true)
    } else {
      subtitleLabel.isHidden = true
      setRefreshButtonConstraints(from: viewModel.refreshButtonConstraints, hasSubtitle: false)
    }
  }
  
  func update(for error: NetworkError) {
    guard let viewModel = self.viewModel else { return }
    switch error {
    case .offline:
      titleLabel.configure(with: viewModel.titlePropertiesForOfflineError)
      if let subtitleProperties = viewModel.subtitlePropertiesForOfflineError {
        subtitleLabel.configure(with: subtitleProperties)
      }
    case .serverError:
      titleLabel.configure(with: viewModel.titlePropertiesForServerError)
      if let subtitleProperties = viewModel.subtitlePropertiesForServerError {
        subtitleLabel.configure(with: subtitleProperties)
      }
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    setupRefreshButton()
  }
  
  private func setupRefreshButton() {
    addSubview(refreshButton)
    refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
  }
  
  // MARK: - Actions
  
  @objc private func refresh() {
    onDidRequestToRefresh?()
  }
}

// MARK: - Private Methods

private extension StoryLoadingErrorView {
  func setSubtitleLabelConstraints(from constraints: ViewConstraintsContainer) {
    subtitleLabel.snp.makeConstraints { make in
      if let top = constraints.topOffset {
        make.top.equalTo(titleLabel.snp.bottom).offset(top)
      }
    }
    makeCommonConstraints(for: subtitleLabel, from: constraints)
  }
  func setRefreshButtonConstraints(from constraints: ViewConstraintsContainer, hasSubtitle: Bool) {
    refreshButton.snp.makeConstraints { make in
      if let top = constraints.topOffset {
        if hasSubtitle {
          make.top.equalTo(subtitleLabel.snp.bottom).offset(top)
        } else {
          make.top.equalTo(titleLabel.snp.bottom).offset(top)
        }
      }
    }
    makeCommonConstraints(for: refreshButton, from: constraints)
  }
  func makeCommonConstraints(for view: UIView, from constraints: ViewConstraintsContainer) {
    view.snp.makeConstraints { make in
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
