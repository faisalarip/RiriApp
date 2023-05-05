//
//  BaseViewController.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit

open class BaseViewController: UIViewController {
  
  open override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  private func showActivityIndicator() {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
    activityIndicator.layer.cornerRadius = 6
    activityIndicator.center = self.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.large
    activityIndicator.tag = 1
    view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    view.isUserInteractionEnabled = false
  }
  
  private func hideActivityIndicator() {
    let activityIndicator = view.viewWithTag(1) as? UIActivityIndicatorView
    activityIndicator?.stopAnimating()
    activityIndicator?.removeFromSuperview()
    view.isUserInteractionEnabled = true
  }
  
  public func showDialogProgress(_ state: Bool) {
    if state {
      showActivityIndicator()
    } else {
      hideActivityIndicator()
    }
  }
  
  
}
