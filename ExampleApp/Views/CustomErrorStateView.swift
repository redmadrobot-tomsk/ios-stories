//
//  CustomErrorStateView.swift
//  StoriesExampleApp
//

import UIKit
import Stories

class CustomErrorStateView: UIView, StoryErrorStateViewProtocol {
  var onDidRequestToReload: (() -> Void)?
  
  private let stackView = UIStackView()
  private let smileLabel = UILabel()
  private let titleLabel = UILabel()
  private let reloadButton = UIButton(type: .system)
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func didTapReload() {
    onDidRequestToReload?()
  }
  
  func configure(with error: Stories.NetworkError) {
    switch error {
    case .offline:
      titleLabel.text = "Нет интернета"
    case .serverError:
      titleLabel.text = "Ошибка сервера"
    }
  }
  
  private func setup() {
    backgroundColor = .black
    setupStackView()
    setupSmileLabel()
    setupTitleLabel()
    setupReloadButton()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupSmileLabel() {
    stackView.addArrangedSubview(smileLabel)
    smileLabel.textColor = .white
    smileLabel.font = .boldSystemFont(ofSize: 56)
    smileLabel.text = ":("
    smileLabel.textAlignment = .center
    stackView.setCustomSpacing(16, after: smileLabel)
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .white
    titleLabel.font = .boldSystemFont(ofSize: 16)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    stackView.setCustomSpacing(24, after: titleLabel)
  }
  
  private func setupReloadButton() {
    stackView.addArrangedSubview(reloadButton)
    var configuration = UIButton.Configuration.plain()
    configuration.title = "Обновить"
    configuration.baseForegroundColor = .white
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    configuration.background.strokeWidth = 1
    configuration.background.strokeColor = .white
    configuration.cornerStyle = .capsule
    reloadButton.configuration = configuration
    reloadButton.addTarget(self, action: #selector(didTapReload), for: .touchUpInside)
    reloadButton.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
  }
}
