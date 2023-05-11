//
//  LocalDataSource.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation

public enum ResponseResult <T, F> {
  case Success(T)
  case Error(F)
}

final class LocalDataSource: NSObject {
  
  public static let shared = LocalDataSource()
  
  private override init() {
  }
  
  public func saveStories<T: Codable>(_ storiesData: T,
                                      _ withKey: String,
                                      completion: @escaping(ResponseResult<Bool, String>) -> Void) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(storiesData)
      UserDefaults.standard.set(data, forKey: withKey)
      completion(.Success(true))
    } catch {
      completion(.Error("Unable to Encode Data (\(error))"))
    }
  }
  
  public func retriveStories<T: Codable>(_ objectResponse: T.Type,
                                         _ withKey: String,
                                         completion: @escaping(ResponseResult<T, String>) -> Void) {
    do {
      if let data = UserDefaults.standard.data(forKey: withKey) {
        do {
          let decoder = JSONDecoder()
          let dataDecode = try decoder.decode(objectResponse, from: data)
          completion(.Success(dataDecode))
        } catch {
          completion(.Error("Unable to Encode Data (\(error))"))
        }
      } else {
        completion(.Error("failed to retrive a data"))
      }
    } catch let err {
      completion(.Error("failed to persist data \(err.localizedDescription)"))
    }
  }

}
