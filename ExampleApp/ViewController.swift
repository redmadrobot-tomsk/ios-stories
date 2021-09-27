//
//  ViewController.swift
//  Stories
//

import UIKit
import Stories

class ViewController: BaseViewController {
  
  private let listView = StoriesListView()
  
  private let storiesStorage = StoriesStoringFactory.defaultStorage()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStories()
    loadData()
  }
  
  private func setupStories() {
    view.addSubview(listView)
    listView.presentingViewController = self
    listView.spacing = 16
    listView.horizontalInset = 16
    listView.uiComponentsFactory = CustomComponentsFactory()
    listView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(120)
      make.leading.trailing.equalToSuperview()
    }
    
    storiesStorage.configurator.setStoriesLifetime(.infinity).deleteExpiredStories(false)
      .orderBy(.date).orderDirection(.desc).show(.all).prefetchImages(true).reload()
  }
  
  private func loadData() {
    let session = URLSession.shared
    guard let url = URL(string: "https://demo.dev.kode-t.ru/mobile/api/v1/stories") else { return }
    session.dataTask(with: url) { [weak self] data, respnse, error in
      if let data = data {
        self?.handleResponse(data: data)
      }
    }.resume()
  }
  
  private func handleResponse(data: Data) {
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let response = try decoder.decode(StoriesResponse.self, from: data)
      DispatchQueue.main.async {
        try? self.storiesStorage.replace(with: response.stories)
      }
    } catch {
      print(error)
    }
  }
}
