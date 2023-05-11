//
//  HomePresenter.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation
import Core

public final class HomePresenter {
  
  private var storyInteractor: StoryInteractor
  
  public var stories: [StoryContent] = []
  
  init(storyInteractor: StoryInteractor) {
    self.storyInteractor = storyInteractor
  }
  
  func reqStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Void, String>) -> Void) {
      isLoad(true)
      storyInteractor.retriveStories { result in
        isLoad(false)
        switch result {
        case .Success(let response):
          self.stories = response
          completion(.Success(()))
        case .Error(let error):
          completion(.Error(error))
        }
      }
  }
  
}
