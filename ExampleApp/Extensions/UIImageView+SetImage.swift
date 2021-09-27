//
//  UIImageView+SetImage.swift
//  Stories
//

import UIKit
import Kingfisher

enum NetworkError: Error {
  case offline, serverError
}

extension UIImageView {
  func setImage(with url: URL?, placeholder: UIImage? = nil,
                completion: ((UIImage?, NetworkError?) -> Void)? = nil) {
    if let fileURL = url, fileURL.isFileURL == true,
      FileManager.default.fileExists(atPath: fileURL.path), let fileImage = UIImage(contentsOfFile: fileURL.path) {

      DispatchQueue.main.async {
        self.image = fileImage
        completion?(fileImage, nil)
      }
      return
    }

    kf.setImage(with: url, placeholder: placeholder, completionHandler:
                  { [weak self] result in
      switch result {
      case .success(let value):
        completion?(value.image, nil)
      case .failure(let error):
        if case KingfisherError.responseError(let reason) = error,
           case KingfisherError.ResponseErrorReason.URLSessionError(let networkError) = reason,
           (self?.isOfflineError(networkError) ?? false) {
          completion?(nil, NetworkError.offline)
          return
        }
        completion?(nil, NetworkError.serverError)
      }
    })
  }
  
  private func isOfflineError(_ error: Error) -> Bool {
    let errorCodes = [NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost, NSURLErrorTimedOut,
                      NSURLErrorCannotFindHost, NSURLErrorCallIsActive, NSURLErrorNetworkConnectionLost,
                      NSURLErrorDataNotAllowed, NSURLErrorCannotLoadFromNetwork,
                      NSURLErrorInternationalRoamingOff, NSURLErrorSecureConnectionFailed]
    return errorCodes.contains((error as NSError).code)
  }
}
