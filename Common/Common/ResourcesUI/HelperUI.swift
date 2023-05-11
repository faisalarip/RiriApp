//
//  HelperUI.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit
import SwiftyDraw

public final class HelperUI {
  
  public static let HELPER_KEY_STORY_DATA = "stories_data_key"
  
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
    textView.sizeToFit()
    textView.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    textView.textAlignment = .left
    textView.textColor = UIColor.white
    textView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    textView.layer.cornerRadius = 16
    textView.layer.masksToBounds = true
    return textView
  }
  
  public static func getDraftBackgroundContent(_ views: [UIView]) -> UIImageView {
    if views.isEmpty {
      return UIImageView()
    } else {
      // A first index of draft contents is background's content
      guard let imgViewBg = views[0] as? UIImageView else { return UIImageView() }
      return imgViewBg
    }
  }
  
  public static func getDraftAdditionalContents(_ views: [UIView]) -> [UIView] {
    var viewContents: [UIView] = []
    if views.isEmpty || views.count < 2 {
      return []
    } else {
      // A second index..n of draft contents is an additional content, i.e. image, textfield, etc.
      for index in 1..<views.count {
        viewContents.append(views[index])
      }
      return viewContents
    }
  }
  
  //image compression
  public static func resizeImage(image: UIImage) -> UIImage {
    var actualHeight: Float = Float(image.size.height)
    var actualWidth: Float = Float(image.size.width)
    let maxHeight: Float = 300.0
    let maxWidth: Float = 400.0
    var imgRatio: Float = actualWidth / actualHeight
    let maxRatio: Float = maxWidth / maxHeight
    let compressionQuality: Float = 0.7
    //50 percent compression
    
    if actualHeight > maxHeight || actualWidth > maxWidth {
      if imgRatio < maxRatio {
        //adjust width according to maxHeight
        imgRatio = maxHeight / actualHeight
        actualWidth = imgRatio * actualWidth
        actualHeight = maxHeight
      }
      else if imgRatio > maxRatio {
        //adjust height according to maxWidth
        imgRatio = maxWidth / actualWidth
        actualHeight = imgRatio * actualHeight
        actualWidth = maxWidth
      }
      else {
        actualHeight = maxHeight
        actualWidth = maxWidth
      }
    }
    
    let rect = CGRectMake(0.0, 0.0, CGFloat(actualWidth), CGFloat(actualHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
    UIGraphicsEndImageContext()
    return UIImage(data: imageData!)!
  }
}
