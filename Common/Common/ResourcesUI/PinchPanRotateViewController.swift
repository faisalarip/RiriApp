//
//  PinchPanRotateViewController.swift
//  Common
//
//  Created by Tech Dev on 5/3/23.
//

import UIKit

public protocol PinchPanRotateViewControllerDelegate: AnyObject {
  func statePanGesture(_ state: UIGestureRecognizer.State)
  func statePinchGesture(_ state: UIGestureRecognizer.State)
  func stateRotateGesture(_ state: UIGestureRecognizer.State)
}

public final class PinchPanRotateViewController: UIViewController, UIGestureRecognizerDelegate {
  
  public static let shared = PinchPanRotateViewController()
  
  public weak var delegate: PinchPanRotateViewControllerDelegate?
  
  private init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let window = view.window!
    let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
    let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
    gr0.delaysTouchesBegan = false
    gr1.delaysTouchesBegan = false
  }
  
  public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
      return .all
  }
  
  public func addSubViews(_ subView: UIView, controller: UIViewController, isLoadData: Bool = false) {
    if !isLoadData {
      if let textview = subView as? UITextView {
        textview.frame = CGRect(origin: view.center , size: CGSize(width: 50, height: 50)) // an initial frame
      }
      subView.center = self.view.center
    }
    
    if let textview = subView as? UITextView {
      textview.delegate = controller as? UITextViewDelegate
    }
    subView.layer.cornerRadius = 16
    subView.layer.masksToBounds = true
    subView.isUserInteractionEnabled = true
    
    //add pan gesture
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    gestureRecognizer.delegate = self
    subView.addGestureRecognizer(gestureRecognizer)
    
    //add pinch gesture
    let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(handlePinch(_:)))
    pinchGesture.delegate = self
    subView.addGestureRecognizer(pinchGesture)
    
    //add rotate gesture.
    let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(_:)))
    rotate.delegate = self
    subView.addGestureRecognizer(rotate)
    
    self.view.addSubview(subView)
  }
  
  @objc func handlePan(_ pan: UIPanGestureRecognizer) {
    if pan.state == .began || pan.state == .changed {
      guard let v = pan.view else { return }
      let translation = pan.translation(in: self.view)
      v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
      pan.setTranslation(CGPoint.zero, in: self.view)
    }
    delegate?.statePanGesture(pan.state)
  }
  
  @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
    if let view = recognizer.view, let parent = self.view.superview {
      
      // this will only let it scale to half size
      let minimumThreshold: CGFloat = 0.2
      var scale: CGFloat = recognizer.scale
      
      // assuming your view is square, which based on your example it is
      let newSize = view.frame.height * scale
      
      // prevents the view from growing larger than the smallest dimension of the parent view
      let allowableSize = max(parent.frame.height, parent.frame.width)
      let maximumScale: CGFloat = allowableSize/view.frame.height
      
      // change scale if it breaks either bound
      if scale < minimumThreshold {
        print("size is too small")
        scale = minimumThreshold
      }
      
      if newSize > allowableSize {
        print("size is too large")
        scale = maximumScale
      }
      
      // apply the transform
      // view.transform = CGAffineTransformMakeScale(scale, scale)
      view.transform = view.transform.scaledBy(x: scale, y: scale)
      recognizer.scale = 1
      delegate?.statePanGesture(recognizer.state)
    }
  }
  
  @objc func handleRotate(_ rotate: UIRotationGestureRecognizer) {
    guard let v = rotate.view else { return }
    v.transform = v.transform.rotated(by: rotate.rotation)
    rotate.rotation = 0
    delegate?.statePanGesture(rotate.state)
  }
  
  public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
    return true
  }
  
}
