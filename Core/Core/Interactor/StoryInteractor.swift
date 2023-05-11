//
//  StoryInteractor.swift
//  Core
//
//  Created by Tech Dev on 5/4/23.
//

import Foundation
import Common

public final class StoryInteractor: NSObject {
  public static let storyInteractor = StoryInteractor()
  
  private let localDataSource = LocalDataSource.shared
  
  public func retriveStories(completion: @escaping((ResponseResult<[StoryContent], String>) -> Void)) {
    localDataSource.retriveStories([StoryContentResponse].self,
                                   HelperUI.HELPER_KEY_STORY_DATA,
                                   completion: { result in
      switch result {
      case .Success(let response):
        let dataStoryContent = StoryMapper.transformStoryRespToModel(response: response)
        completion(.Success(dataStoryContent))
      case .Error(let error):
        completion(.Error(error))
      }
    })
  }
  
  public func setStories(_ data: [StoryContent],
                         completion: @escaping((ResponseResult<Bool, String>) -> Void)) {
    let storyResponse = StoryMapper.transformStoryModelToResp(data: data)
    localDataSource.saveStories(storyResponse,
                                HelperUI.HELPER_KEY_STORY_DATA,
                                completion: completion)
  }
}
