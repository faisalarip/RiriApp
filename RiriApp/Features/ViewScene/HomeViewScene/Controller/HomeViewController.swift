//
//  HomeViewController.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit
import Core

class HomeViewController: UIViewController {
  
  @IBOutlet weak var btnCreate: UIButton!
  @IBOutlet weak var tableViewStories: UITableView!
  
  private var homePresenter: HomePresenter!
  
  init() {
    super.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      setupTableView()
      registerListener()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadData()
  }
  
  private func setupTableView() {
    tableViewStories.register(UINib(nibName: StoryTableCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: StoryTableCell.cellIdentifier)
    tableViewStories.dataSource = self
    tableViewStories.delegate = self
  }
  
  private func registerListener() {
    homePresenter = HomePresenter(storyInteractor: StoryInteractor.storyInteractor)
    btnCreate.addTarget(self, action: #selector(didTapBtnCreate(_:)), for: .touchUpInside)
  }
  
  private func loadData() {
    homePresenter.reqStories { state in
      print("isLoad \(state)")
    } completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .Success(_):
        self.tableViewStories.reloadData()
      case .Error(let error):
        print("failed to load data \(error)")
      }
    }

  }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return homePresenter.stories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableCell.cellIdentifier, for: indexPath)
            as? StoryTableCell else { return UITableViewCell() }
            
    return cell
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

// MARK: LISTENER ACTIONS
extension HomeViewController {
  @objc private func didTapBtnCreate(_ sender: UIButton) {
    let vc = StoryViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
