//
//  DefaultStoryErrorStateView.swift
//  Stories
//

import UIKit

class DefaultStoryErrorStateView: UIView, StoryErrorStateViewProtocol {
  // MARK: - Properties
  
  var onDidRequestToReload: (() -> Void)?
  
  private let stackView = UIStackView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let reloadButton = UIButton.makeDefaultButton()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  
  @objc private func didTapReload() {
    onDidRequestToReload?()
  }
  
  // MARK: - Configure
  
  func configure(with error: NetworkError) {
    titleLabel.text = Strings.error
    
    switch error {
    case .offline:
      subtitleLabel.text = Strings.internetErrorDescription
    case .serverError:
      subtitleLabel.text = Strings.serverErrorDescription
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    backgroundColor = .black
    setupStackView()
    setupTitleLabel()
    setupSubtitleLabel()
    setupReloadButton()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
    titleLabel.textColor = .white
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
    }
    stackView.setCustomSpacing(4, after: titleLabel)
  }
  
  private func setupSubtitleLabel() {
    stackView.addArrangedSubview(subtitleLabel)
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
    subtitleLabel.font = UIFont.systemFont(ofSize: 16)
    subtitleLabel.textColor = .white
    subtitleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
    }
    stackView.setCustomSpacing(16, after: subtitleLabel)
  }
  
  private func setupReloadButton() {
    stackView.addArrangedSubview(reloadButton)
    reloadButton.setTitle(Strings.reload, for: .normal)
    reloadButton.addTarget(self, action: #selector(didTapReload), for: .touchUpInside)
  }
}
