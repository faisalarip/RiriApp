//
//  ScaledHeightImageView.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit

public class ScaledHeightImageView: UIImageView {

  public override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width-100
            let myImageHeight = myImage.size.height-100
            let myViewWidth = self.frame.size.width
 
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
