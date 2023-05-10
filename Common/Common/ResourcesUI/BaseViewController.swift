//
//  BaseViewController.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit
import JGProgressHUD

open class BaseViewController: UIViewController {
  
  open override func viewDidLoad() {
    super.viewDidLoad()
  }
  private lazy var loadingDialog: JGProgressHUD = {
    let progressDialog = JGProgressHUD(style: .dark)
    progressDialog.backgroundColor = UIColor.black.withAlphaComponent(0.80)
    progressDialog.contentView.backgroundColor = .clear
    progressDialog.hudView.backgroundColor = .clear
    progressDialog.indicatorView?.backgroundColor = .clear
    
    for subview in progressDialog.hudView.subviews {
      for blurView in subview.subviews where blurView is UIVisualEffectView {
        if let blurEffect = blurView as? UIVisualEffectView {
          blurEffect.effect = .none
        }
        break
      }
    }
    
    return progressDialog
  }()
  
  private func showProgressDialog() {
    DispatchQueue.main.async {
      self.loadingDialog.show(in: self.view, animated: true)
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
  }
  
  private func hideProgressDialog() {
    DispatchQueue.main.async {
      self.loadingDialog.dismiss(animated: true)
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
  }
  
  public func showDialogProgress(_ state: Bool) {
    if state {
      showProgressDialog()
    } else {
      hideProgressDialog()
    }
  }
  
  
}
