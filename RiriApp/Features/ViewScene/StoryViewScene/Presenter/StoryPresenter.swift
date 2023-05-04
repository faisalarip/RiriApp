//
//  StoryPresenter.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//
import Foundation
import RxSwift
import Core

public final class StoryPresenter {
  
  private var storyInteractor: StoryInteractor
  private let disposeBag = DisposeBag()
  
  public var stories: [StoryModel] = []
  
  init(storyInteractor: StoryInteractor) {
    self.storyInteractor = storyInteractor
  }
  
  func reqStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Void, String>) -> Void) {
    
      storyInteractor.retriveStories()
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { response in
          self.stories = response
          isLoad(false)
          completion(.Success(()))
        },
        onError: { error in
          isLoad(false)
          completion(.Error(error.localizedDescription))
        })
      .disposed(by: disposeBag)
  }
  
  func saveStories(
    story: StoryModel,
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Bool, String>) -> Void) {
      
      if let index = stories.firstIndex(where: { $0.id == story.id }) {
        stories[index] = story
      } else {
        stories.append(story)
      }
      
      storyInteractor.setStories(stories)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { response in
          isLoad(false)
          completion(.Success((response)))
        },
        onError: { error in
          isLoad(false)
          completion(.Error(error.localizedDescription))
        })
      .disposed(by: disposeBag)
  }
  
}
