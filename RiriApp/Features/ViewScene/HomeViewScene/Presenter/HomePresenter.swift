//
//  HomePresenter.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation
import RxSwift
import Core

public final class HomePresenter {
  
  private var storyInteractor: StoryInteractor
  private let disposeBag = DisposeBag()
  
  public var stories: [StoryContent] = []
  
  init(storyInteractor: StoryInteractor) {
    self.storyInteractor = storyInteractor
  }
  
  func reqStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Void, String>) -> Void) {
      isLoad(true)
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
  
}
