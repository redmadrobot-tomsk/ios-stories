//
//  Storage.swift
//  Stories
//

import Foundation

enum StorageError: Error {
  case noDataSaved, couldNotSaveFile, notLoggedIn
}

extension StorageError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .noDataSaved, .couldNotSaveFile, .notLoggedIn:
      return ""
    }
  }
}

private extension Constants {
  static let positiveInfinity = "positiveInfinity"
  static let negativeInfinity = "negativeInfinity"
  static let nan = "nan"
}

struct Storage<T: Codable> {
  private let fileManager = FileManager.default
  private let folderName: String

  init(folderName: String = String(describing: T.self)) {
    self.folderName = folderName
  }

  func setObject(_ object: T, forKey key: String) throws {
    let fileURL = try directoryURL().appendingPathComponent(key, isDirectory: false)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: Constants.positiveInfinity,
                                                                  negativeInfinity: Constants.negativeInfinity,
                                                                  nan: Constants.nan)
    let data = try encoder.encode(object)
    if fileManager.fileExists(atPath: fileURL.path) {
      try fileManager.removeItem(at: fileURL)
    }
    let result = fileManager.createFile(atPath: fileURL.path, contents: data)
    guard result else {
      throw StorageError.couldNotSaveFile
    }
  }

  func object(forKey key: String) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: Constants.positiveInfinity,
                                                                    negativeInfinity: Constants.negativeInfinity,
                                                                    nan: Constants.nan)
    let fileURL = try directoryURL().appendingPathComponent(key, isDirectory: false)
    guard let data = fileManager.contents(atPath: fileURL.path) else {
      throw StorageError.noDataSaved
    }
    return try decoder.decode(T.self, from: data)
  }
  
  func remove(forKey key: String) throws {
    let fileURL = try directoryURL().appendingPathComponent(key, isDirectory: false)
    try fileManager.removeItem(at: fileURL)
  }

  func clearAllData() throws {
    let folderURL = try directoryURL()
    let contents = try fileManager.contentsOfDirectory(atPath: folderURL.path)
    for filePath in contents {
      let fullFileURL = folderURL.appendingPathComponent(filePath, isDirectory: false)
      try fileManager.removeItem(at: fullFileURL)
    }
  }

  private func directoryURL() throws -> URL {
    var directoryURL = try fileManager.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true).appendingPathComponent(folderName, isDirectory: true)
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try directoryURL.setResourceValues(resourceValues)
    return directoryURL
  }
}
