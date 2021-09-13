//
//  ImageDownloadUtility.swift
//  Stories
//

import Foundation
import Kingfisher

struct ImageDownloadUtility {
  private static let cache = ImageCache.default
  
  static func cacheImage(with url: URL?) {
    guard let url = url else { return }
    
    guard !cache.isCached(forKey: url.absoluteString) else { return }
    
    DispatchQueue.global().async {
      ImagePrefetcher(urls: [url]).start()
    }
  }
  
  static func removeImageCache(for url: URL?) {
    guard let url = url else { return }
    
    cache.removeImage(forKey: url.absoluteString)
  }
}
