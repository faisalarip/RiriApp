//
//  LocalDataSource.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation
import RxSwift

public enum ResponseResult <T, F> {
  case Success(T)
  case Error(F)
}

final class LocalDataSource: NSObject {
  
  public static let shared = LocalDataSource()
  
  private override init() {
  }
  
  public func saveStories(_ storiesData: [StoryResponse]) -> Observable<Bool> {
    return Observable<Bool>.create { observe in
      do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(storiesData)
        UserDefaults.standard.set(data, forKey: "stories_data_key")
        observe.onNext(true)
      } catch {
        print("Unable to Encode Data (\(error))")
        observe.onNext(false)
      }
      return Disposables.create()
    }
  }
  
  public func retriveStories() -> Observable<[StoryResponse]> {
    return Observable<[StoryResponse]>.create { observe in
      do {
        if let data = UserDefaults.standard.data(forKey: "stories_data_key") {
          do {
            let decoder = JSONDecoder()
            let data = try decoder.decode([StoryResponse].self, from: data)
            observe.onNext(data)
          } catch {
            print("Unable to Decode Data (\(error))")
            observe.onNext([])
          }
        }
      } catch _ {
        observe.onNext([])
      }
      return Disposables.create()
    }
  }

}