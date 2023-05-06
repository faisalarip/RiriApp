//
//  HelperUI.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit

public final class HelperUI {
  public static func setDefaultImageView(_ img: UIImage, _ containerView: UIView) -> UIImageView {
    let imageView = ScaledHeightImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = img
    let ratio = img.size.width / img.size.height
    if containerView.frame.width > containerView.frame.height {
      let newHeight = containerView.frame.width / ratio
      imageView.frame.size = CGSize(width: containerView.frame.width, height: newHeight)
    }
    else{
      let newWidth = containerView.frame.height * ratio
      imageView.frame.size = CGSize(width: newWidth, height: containerView.frame.height)
    }
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    return imageView
  }
  
  public static func setDefaultTextview() -> UITextView {
    let textView = UITextView()
    textView.isScrollEnabled = false
    // textView.sizeToFit()
    textView.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    textView.textAlignment = .left
    textView.textColor = UIColor.white
    textView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    textView.layer.cornerRadius = 16
    textView.layer.masksToBounds = true
    return textView
  }
}
