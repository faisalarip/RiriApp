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
  
  private var imagePicker = UIImagePickerController()
  private var drawView: SwiftyDrawView!
  
  private let pinchPanRotateViewController: PinchPanRotateViewController = PinchPanRotateViewController.shared
  
  private var storyPresenter: StoryPresenter!
  private var indexPathParentSelected: IndexPath?
  private var currentIndexChildStory: Int = 0
  
  init(indexPathSelected: IndexPath?) {
    super.init(nibName: "StoryViewController", bundle: Bundle(for: StoryViewController.self))
    self.indexPathParentSelected = indexPathSelected
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
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeContentDraw()
  }
  
  private func registerPresenter() {
    storyPresenter = StoryPresenter(storyInteractor: StoryInteractor.storyInteractor)
    if indexPathParentSelected == nil {
      storyPresenter.addInitalChildStoryData(0)
    }
  }
  
  private func setupLayout() {
    drawView = SwiftyDrawView(frame: vwContainer.frame)
    drawView.brush = Brush(color: .white, width: 9, opacity: 1, adjustedWidthFactor: 0, blendMode: .normal)
    drawView.delegate = self
    drawView.isEnabled = false // by default is false
    drawView.isUserInteractionEnabled = true
    vwContainer.isUserInteractionEnabled = true
    
    pinchPanRotateViewController.delegate = self
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
        self.collectionViewStories.reloadData()
      case .Error(let error):
        print("failed load data \(error)")
      }
    }

  }
  
  private func saveData() {
//    let image = UIGraphicsImageRenderer(bounds: vwContainer.bounds).image { _ in
//      vwContainer.drawHierarchy(in: vwContainer.bounds, afterScreenUpdates: true)
//    }
    
//    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//      let yourViewToData = UserDefaults.standard.data(forKey: "TEST_DATA")
//      if let yourViewFromData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(yourViewToData ?? Data()) as? [UIView] {
//        // Do what you want with your view
//        yourViewFromData.forEach { self.pinchPanRotateViewController.addSubViews($0, controller: self, isLoadData: true) }
//        self.addContentDraw()
//      }
//    })
    
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
  
  private func saveTemporaryChildStoryContents(childIndex: Int) {
    let rowSelected = indexPathParentSelected?.row ?? 0
    
    if imgBg.image != UIImage() ||
        !drawView.drawItems.isEmpty ||
        !pinchPanRotateViewController.view.subviews.isEmpty {
      var contentSubviews: [UIView] = [imgBg, drawView]
      contentSubviews.append(contentsOf: pinchPanRotateViewController.view.subviews)
      let contentData = (try? NSKeyedArchiver.archivedData(withRootObject: contentSubviews, requiringSecureCoding: false)) ?? Data()
      
      storyPresenter.saveChildStoryData(rowSelected, childIndex, contentData)
    }
  }
  
  private func defaultContainerView() {
    imgBg.image = UIImage()
    lblEditor.isHidden = false
    btnApplyBg.isHidden = false
    vwContainer.backgroundColor = .systemPurple
  }
  
  private func hideEditorContents() {
    lblEditor.isHidden = true
    btnApplyBg.isHidden = true
  }
  
  private func removeContentDraw() {
    for view in vwContainer.subviews where view == self.drawView {
      pinchPanRotateViewController.view.subviews.forEach { $0.removeFromSuperview() }
      drawView.subviews.forEach { $0.removeFromSuperview() }
      view.removeFromSuperview()
    }
  }
  
  private func addContentDraw() {
    for view in vwContainer.subviews where view != self.drawView {
      pinchPanRotateViewController.view.frame = drawView.bounds
      drawView.addSubview(pinchPanRotateViewController.view)
      vwContainer.addSubview(drawView)
    }
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
    
    if indexPath.item == storyPresenter.stories[rowSelected].childStoryContents.count {
      storyPresenter.addInitalChildStoryData(rowSelected)
      defaultContainerView()
    } else {
      if childStoryContents[indexPath.item].contents != Data() {
        // load temporary child contents data
      } else {
        // hideEditorContents()
        currentIndexChildStory = indexPath.item
      }
    }
    
    collectionView.reloadData()
    removeContentDraw()
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
  }
  
}

// MARK: LISTENER ACTIONS
extension StoryViewController {
  @objc private func didTapBtnBrowsePicture(_ sender: UIButton) {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      addContentDraw()
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      imagePicker.accessibilityValue = sender == btnApplyBg ? "1000" : "1001"
      
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @objc private func didTapBtnEnableDraw(_ sender: UIButton) {
    addContentDraw()
    drawView.isEnabled = !drawView.isEnabled
  }
  
  @objc private func didTapBtnAddText(_ sender: UIButton) {
    addContentDraw()
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
    textView.center = pinchPanRotateViewController.view.center
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

extension StoryViewController: SwiftyDrawViewDelegate {
  func swiftyDraw(shouldBeginDrawingIn drawingView: SwiftyDraw.SwiftyDrawView, using touch: UITouch) -> Bool {
    return true
  }
  
  func swiftyDraw(didBeginDrawingIn drawingView: SwiftyDraw.SwiftyDrawView, using touch: UITouch) {
  }
  
  func swiftyDraw(isDrawingIn drawingView: SwiftyDraw.SwiftyDrawView, using touch: UITouch) {
  }
  
  func swiftyDraw(didFinishDrawingIn drawingView: SwiftyDraw.SwiftyDrawView, using touch: UITouch) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      self.saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory)
    })
  }
  
  func swiftyDraw(didCancelDrawingIn drawingView: SwiftyDraw.SwiftyDrawView, using touch: UITouch) {
  }
  
}

extension StoryViewController: PinchPanRotateViewControllerDelegate {
  func statePanGesture(_ state: UIGestureRecognizer.State) {
    if state == .ended {
      saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory)
    }
  }
  
  func statePinchGesture(_ state: UIGestureRecognizer.State) {
    if state == .ended {
      saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory)
    }
  }
  
  func stateRotateGesture(_ state: UIGestureRecognizer.State) {
    if state == .ended {
      saveTemporaryChildStoryContents(childIndex: self.currentIndexChildStory)
    }
  }
}
