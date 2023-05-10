//
//  ChildStoryCollectCell.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit

class ChildStoryCollectCell: UICollectionViewCell {

    static let cellIdentifier = "ChildStoryCollectCell"
  
    @IBOutlet weak var btnAdd: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  public func setupSelectedCell(_ isSelected: Bool) {
    if isSelected {
      self.layer.borderWidth = 6
      self.layer.borderColor = UIColor.white.cgColor
    } else {
      self.layer.borderWidth = 0
    }
  }

}
