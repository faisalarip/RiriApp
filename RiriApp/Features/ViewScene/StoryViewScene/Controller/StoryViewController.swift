//
//  StoryViewController.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit
import Common
import Core
import SwiftyDraw

class StoryViewController: BaseViewController {
  
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnAddImage: UIButton!
  @IBOutlet weak var btnAddText: UIButton!
  @IBOutlet weak var btnEnableDraw: UIButton!
  @IBOutlet weak var btnSave: UIButton!
  @IBOutlet weak var btnApplyBg: UIButton!
  
  @IBOutlet weak var lblEditor: UILabel!
  @IBOutlet weak var vwContainer: UIView!
  @IBOutlet weak var imgBg: UIImageView!
  @IBOutlet weak var collectionViewStories: UICollectionView!
  @IBOutlet weak var vwContainerDraw: UIView!
  
  private var imagePicker = UIImagePickerController()
  private var drawView: SwiftyDrawView!
  
  private let pinchPanRotateViewController: PinchPanRotateViewController = PinchPanRotateViewController.shared
  
  private var storyPresenter: StoryPresenter!
  private var indexPathParentSelected: IndexPath?
  private var currentIndexChildStory: Int = 0
  private var isCreateNew: Bool = false
  
  init(indexPathSelected: IndexPath?, isCreateNew: Bool) {
    super.init(nibName: "StoryViewController", bundle: Bundle(for: StoryViewController.self))
    self.indexPathParentSelected = indexPathSelected
    self.isCreateNew = isCreateNew
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerPresenter()
    setupLayout()
    setupCollectionView()
    setupListener()
    loadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let window = view.window!
    let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
    let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
    gr0.delaysTouchesBegan = false
    gr1.delaysTouchesBegan = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeContentDraw()
    vwContainer.removeFromSuperview()
  }
  
  open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
      return .all
  }
  
  private func registerPresenter() {
    storyPresenter = StoryPresenter(storyInteractor: StoryInteractor.storyInteractor)
    if storyPresenter.stories.isEmpty {
      self.storyPresenter.addInitalChildStoryData(false, self.indexPathParentSelected?.row ?? 0)
    }
  }
  
  private func setupLayout() {
    drawView = SwiftyDrawView(frame: vwContainer.frame)
    drawView.brush = Brush(color: .white, width: 9, opacity: 1, adjustedWidthFactor: 0, blendMode: .normal)
    drawView.isEnabled = false // by default is false
    drawView.isUserInteractionEnabled = true
    
    vwContainer.isUserInteractionEnabled = true
    vwContainerDraw.isUserInteractionEnabled = true
    
    pinchPanRotateViewController.view.frame = drawView.bounds
    drawView.addSubview(pinchPanRotateViewController.view)
    vwContainer.addSubview(drawView)
    vwContainer.bringSubviewToFront(drawView)
  }
  
  private func setupCollectionView() {
    collectionViewStories.register(UINib(nibName: ChildStoryCollectCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: ChildStoryCollectCell.cellIdentifier)
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 50, height: 50)
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.scrollDirection = .horizontal
    collectionViewStories.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    collectionViewStories.collectionViewLayout = layout
    collectionViewStories.alwaysBounceHorizontal = true
    collectionViewStories.dataSource = self
    collectionViewStories.delegate = self
  }
  
  private func setupListener() {
    btnApplyBg.addTarget(self, action: #selector(didTapBtnBrowsePicture(_:)), for: .touchUpInside)
    btnAddImage.addTarget(self, action: #selector(didTapBtnBrowsePicture(_:)), for: .touchUpInside)
    btnEnableDraw.addTarget(self, action: #selector(didTapBtnEnableDraw(_:)), for: .touchUpInside)
    btnAddText.addTarget(self, action: #selector(didTapBtnAddText(_:)), for: .touchUpInside)
    btnSave.addTarget(self, action: #selector(didTapBtnDone(_:)), for: .touchUpInside)
    btnBack.addTarget(self, action: #selector(didTapBtnBack(_:)), for: .touchUpInside)
  }
  
  private func loadData() {
    storyPresenter.reqStories { state in
      self.showDialogProgress(state)
    } completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .Success(_):
        if self.isCreateNew {
          self.storyPresenter.addInitalChildStoryData(false, self.indexPathParentSelected?.row ?? 0)
        }
        self.collectionViewStories.reloadData()
        self.loadChildStoryContentDrafts(self.storyPresenter.stories[self.indexPathParentSelected?.row ?? 0].childStoryContents[0])
      case .Error(let error):
        print("failed load data \(error)")
      }
    }

  }
  
  private func saveData() {
    self.saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory, completion: {})
    
    storyPresenter.saveStories { state in
      self.showDialogProgress(state)
    } completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .Success(_):
        self.navigationController?.popViewController(animated: true)
      case .Error(let error):
        print("failed to save data \(error)")
      }
    }

  }
  
  private func saveTemporaryChildStoryContents(childIndex: Int, completion: @escaping() -> Void) {
    let rowSelected = indexPathParentSelected?.row ?? 0
    
    if imgBg.image != nil ||
        !drawView.drawItems.isEmpty ||
        !pinchPanRotateViewController.view.subviews.isEmpty {
      self.showDialogProgress(true)
      
      var pinchPanRotateViews = pinchPanRotateViewController.view.subviews
      drawView.subviews.forEach({ $0.removeFromSuperview() })
      self.view.setNeedsLayout()
      UIGraphicsBeginImageContextWithOptions(vwContainer.frame.size, vwContainer.isOpaque, 0.0)
      vwContainer.layer.render(in: UIGraphicsGetCurrentContext()!)
      let imageWithDraw = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      imgBg.image = imageWithDraw
      
      var contentSubviews: [UIView] = [imgBg]
      contentSubviews.append(contentsOf: pinchPanRotateViews)
      contentSubviews.forEach { $0.accessibilityValue = "\(childIndex)" }
      do {
        let contentData = try NSKeyedArchiver.archivedData(withRootObject: contentSubviews, requiringSecureCoding: false)
        
        self.storyPresenter.saveChildStoryData(rowSelected, childIndex, contentData)
        self.showDialogProgress(false)
        completion()
      } catch let err {
        print(" error archived data \(err.localizedDescription)")
      }
    } else {
      completion()
    }
  }
  
  private func loadChildStoryContentDrafts(_ content: ChildStoryContent) {
    if content.contents == Data() {
      defaultContainerView()
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
        guard let self = self else { return }
        if let contentViewDrafts = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(content.contents) as? [UIView] {
          self.removeContentDraw()
          
          self.showDialogProgress(true)
          self.drawView = nil
          self.imgBg.image = HelperUI.getDraftBackgroundContent(contentViewDrafts).image
          let draftAdditionalContents = HelperUI.getDraftAdditionalContents(contentViewDrafts)
          draftAdditionalContents.forEach {
            self.pinchPanRotateViewController.addSubViews($0, controller: self, isLoadData: true)
          }
          self.setupLayout()
          self.hideEditorContents()
          self.vwContainer.layoutSubviews()
          self.view.layoutSubviews()
          self.showDialogProgress(false)
        }
      })
    }
  }
  
  private func defaultContainerView() {
    self.removeContentDraw()
    self.setupLayout()
    imgBg.image = nil
    lblEditor.isHidden = false
    btnApplyBg.isHidden = false
    vwContainer.backgroundColor = .systemPurple
    self.showDialogProgress(false)
  }
  
  private func hideEditorContents() {
    lblEditor.isHidden = true
    btnApplyBg.isHidden = true
  }
  
  private func removeContentDraw() {
    imgBg.image = nil
    pinchPanRotateViewController.view.subviews.forEach { $0.removeFromSuperview() }
    drawView.subviews.forEach { $0.removeFromSuperview() }
    drawView.clear()
  }
}

// MARK: COLLECTION VIEW DATA SOURCE
extension StoryViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let rowSelected = indexPathParentSelected?.row ?? 0
    return storyPresenter.stories[rowSelected].childStoryContents.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChildStoryCollectCell.cellIdentifier, for: indexPath) as? ChildStoryCollectCell else { return UICollectionViewCell() }
    let rowSelected = indexPathParentSelected?.row ?? 0
    if indexPath.item == storyPresenter.stories[rowSelected].childStoryContents.count {
      cell.btnAdd.isHidden = false
    } else {
      cell.setupSelectedCell(self.currentIndexChildStory == indexPath.item)
      cell.btnAdd.isHidden = true
    }
    return cell
  }
  
}

// MARK: COLLECTION VIEW DELEGATE
extension StoryViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let rowSelected = indexPathParentSelected?.row ?? 0
    let childStoryContents = storyPresenter.stories[rowSelected].childStoryContents
    saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory) {
      self.currentIndexChildStory = indexPath.item
      
      if indexPath.item == self.storyPresenter.stories[rowSelected].childStoryContents.count {
        self.storyPresenter.addInitalChildStoryData(true, rowSelected)
        self.defaultContainerView()
      } else {
        if childStoryContents[indexPath.item].contents != Data() {
          self.loadChildStoryContentDrafts(childStoryContents[indexPath.item])
        } else {
          self.defaultContainerView()
        }
      }
      
      self.collectionViewStories.reloadData()
    }
  }
  
}

// MARK: LISTENER ACTIONS
extension StoryViewController {
  @objc private func didTapBtnBrowsePicture(_ sender: UIButton) {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      imagePicker.accessibilityValue = sender == btnApplyBg ? "1000" : "1001"
      
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @objc private func didTapBtnEnableDraw(_ sender: UIButton) {
    drawView.isEnabled = !drawView.isEnabled
  }
  
  @objc private func didTapBtnAddText(_ sender: UIButton) {
    let textview = HelperUI.setDefaultTextview()
    textview.delegate = self
    pinchPanRotateViewController.addSubViews(textview, controller: self)
    textview.becomeFirstResponder()
    self.view.layoutIfNeeded()
  }
  
  @objc private func didTapBtnDone(_ sender: UIButton) {
    saveData()
    view.endEditing(true)
  }
  
  @objc private func didTapBtnBack(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
}

// MARK: - IMAGE PICKER DELEGATE
extension StoryViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      if picker.accessibilityValue == "1001" {
        let imgView = HelperUI.setDefaultImageView(image, pinchPanRotateViewController.view)
        pinchPanRotateViewController.addSubViews(imgView, controller: self)
      } else {
        hideEditorContents()
        imgBg.image = image
      }
      drawView.frame = vwContainer.frame
      self.view.layoutIfNeeded()
    }
    
  }
}

// MARK: - TEXTVIEW DELEGATE
extension StoryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let maxWidth = UIScreen.main.bounds.width - 20
    let maxHeight = UIScreen.main.bounds.height - 20
    let newSize = textView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
    textView.frame.size = newSize
    if textView.text.isEmpty {
      textView.center = pinchPanRotateViewController.view.center
    }
    self.view.layoutIfNeeded()
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
}
