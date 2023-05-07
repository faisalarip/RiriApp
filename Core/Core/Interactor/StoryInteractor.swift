//
//  StoryInteractor.swift
//  Core
//
//  Created by Tech Dev on 5/4/23.
//

import Foundation
import RxSwift

public final class StoryInteractor: NSObject {
  public static let storyInteractor = StoryInteractor()
  
  private let localDataSource = LocalDataSource.shared
  
  public func retriveStories() -> Observable<[StoryContent]> {
    return localDataSource.retriveStories()
      .map { StoryMapper.transformStoryRespToModel(response: $0) }
  }
  
  public func setStories(_ data: [StoryContent]) -> Observable<Bool> {
    let storyResponse = StoryMapper.transformStoryModelToResp(data: data)
    return localDataSource.saveStories(storyResponse)
  }
}
