//
//  AlphaSlider.swift
//  ChildViewController
//
//  Created by Masatoshi Nishikata on 10/08/19.
//  Copyright © 2019 Catalystwo Limited. All rights reserved.
//

import Foundation
import UIKit
import simd
#if canImport(PencilKit)
import PencilKit
#endif

class AlphaSliderBGView: UIView {
  var color: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 0) {
    didSet {
      components1 = [CGFloat(color[0]), CGFloat(color[1]), CGFloat(color[2]), CGFloat(color[3]) ]
      components2 = [CGFloat(color[0]), CGFloat(color[1]), CGFloat(color[2]), 0 ]
    }
  }
  
  var components1: [CGFloat]!
  var components2: [CGFloat]!

  var splitBorder: Float? = nil {
    didSet {
      setNeedsDisplay()
    }
  }
  var vertical = false {
    didSet {
      setNeedsDisplay()
    }
  }

  var darkMode: Bool = false {
    didSet {
     setNeedsDisplay()
    }
  }
  
  var drawCheckers = true
  
  override func draw(_ rect: CGRect) {
    guard rect.size.height > 0 && rect.size.width > 0 else { return }
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    guard components1 != nil && components2 != nil else { return }
    
    //crash_info_entry_0  /Library/Caches/com.apple.xbs/Sources/CoreGraphics/CoreGraphics/Paths/CGPath.cc:525: failed assertion `corner_height >= 0 && 2 * corner_height <= CGRectGetHeight(rect)'

    let corner_height = min(floor(rect.size.height/2), 10)
    let corner_width = min(floor(rect.size.width/2), 10)
    
    guard corner_height >= 0 else { return }
    guard corner_width >= 0 else { return }

    guard 2 * corner_height <= CGRectGetHeight(rect) else { return }
    guard 2 * corner_width <= CGRectGetHeight(rect) else { return }
    
    let path = CGMutablePath()
    path.addRoundedRect(in: rect, cornerWidth: corner_width, cornerHeight: corner_height)
    ctx.addPath(path)
    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fillPath()
    
    if drawCheckers {
      let bgImage = UIImage(named: darkMode ? "SliderAlphaBGDark" : "SliderAlphaBG", in: Bundle(for: AlphaSliderBGView.self), compatibleWith: nil)
      ctx.setBlendMode(.sourceAtop);
      bgImage?.drawAsPattern(in: rect)
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    guard let colorRef1 = CGColor(colorSpace: colorSpace, components: components1) else { return }
    guard let colorRef2 = CGColor(colorSpace: colorSpace, components: components2) else { return }
    
    
    if splitBorder == nil {
      
      let array = [colorRef1, colorRef2]
      
      let locations: [CGFloat] = [0 , 1]
      
      let gradient = CGGradient( colorsSpace: colorSpace, colors: array as CFArray, locations: locations)!
      
      ctx.saveGState()
      ctx.setBlendMode(.sourceAtop);
      
      if vertical {
        let startPoint = CGPoint(x: 0, y: self.bounds.size.height)
        let endPoint = CGPoint(x: 0, y: 0)
        
        ctx.drawLinearGradient(gradient, start: endPoint, end: startPoint, options: [] );

      }else {
        let startPoint = CGPoint(x: self.bounds.size.width, y: 0)
        let endPoint = CGPoint(x: 0, y: 0)
        
        ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [] );
      }
      ctx.restoreGState()
      
    }else {
      ctx.saveGState()
      ctx.setBlendMode(.sourceAtop);

      ctx.addPath(path)
      ctx.setFillColor(colorRef1)
      ctx.fillPath()
      
      let path = CGMutablePath()
      path.addRect(CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * CGFloat(splitBorder!), height: rect.size.height))
      ctx.addPath(path)
      ctx.setFillColor(colorRef2)
      ctx.fillPath()

      
      ctx.restoreGState()
    }
    
    let edgePath = CGMutablePath()
    edgePath.addRoundedRect(in: rect.insetBy(dx: 0.25, dy: 0.25), cornerWidth: min(floor(rect.size.width/2), 9.5), cornerHeight: min(floor(rect.size.height/2), 9.5))
    
    ctx.addPath(edgePath)
    ctx.setLineWidth(0.5)
    if #available(iOS 13.0, *) {
      ctx.setStrokeColor(UIColor.separator.cgColor)
    } else {
      ctx.setStrokeColor(UIColor.lightGray.cgColor)
    }
    ctx.strokePath()
  }
}

open class AlphaSlider: UIControl {
  
  var darkMode: Bool = false {
    didSet {
     background.darkMode = darkMode
    }
  }
  open override var isEnabled: Bool {
    didSet {
      if isEnabled {
        alpha = 1
      }else {
        alpha = 0.2
      }
    }
  }
  var splitWithKnob = false
  var vertical = false {
    didSet {
      if vertical == false {
        background.frame = CGRect(x: 10, y: 10, width: self.bounds.size.width-20, height: 20)
      }else {
        background.frame = CGRect(x: 10, y: 10, width: 20, height: self.bounds.size.height-20)
      }
      background.vertical = vertical
    }
  }
  
  weak var background: AlphaSliderBGView!
  weak var knob: UIImageView!
  open var value: Float = 0 {
    didSet {
      if splitWithKnob {
        background.splitBorder = value
      }
      setNeedsLayout()
    }
  }
  var touchedLocation: CGPoint?
  var knobRect: CGRect!
  var knobBeginX: CGFloat!
  var color: SIMD4<Float> {
    set {
      background.color = SIMD4<Float>(newValue[0], newValue[1], newValue[2], 1)
      if vertical {
        value = 1 - newValue[3]
        
      }else {
        value = newValue[3]
      }
      background.setNeedsDisplay()
    }
    get {
      return background.color
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    knobRect = CGRect(x: 0, y: 3, width: 34, height: 38)
    let view = UIImageView(frame: knobRect)
    view.image = UIImage(named: "SliderKnob", in: Bundle(for: AlphaSlider.self), compatibleWith: nil)
    knob = view
    
    
    let bg = AlphaSliderBGView(frame: CGRect(x: 10, y: 10, width: self.bounds.size.width-20, height: 20))
    bg.isUserInteractionEnabled = false
    bg.darkMode = darkMode
    bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    background = bg
    background.backgroundColor = .clear
    background.isOpaque = false
    self.addSubview(background)
    self.addSubview(knob)

  }
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    
    if vertical {
      let maxY = bounds.size.height - knobRect.size.height
      knobRect = CGRect(x: 2, y: CGFloat(1 - value) * maxY, width: 34, height: 38)
      
    }else {
      let maxX = bounds.size.width - knobRect.size.width
      knobRect = CGRect(x: CGFloat(value) * maxX, y: 3, width: 34, height: 38)
    }
    knob.frame = knobRect
  }
  
  override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let loc = touch.location(in: self)
    touchedLocation = loc
    if vertical {
      knobBeginX = knobRect.origin.y
    }else {
      knobBeginX = knobRect.origin.x
    }
    return knobRect.contains(loc)
  }
  
  override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard let touchedLocation = touchedLocation else { return false }
    var sliderValue: CGFloat
    if vertical {
      let loc = touch.location(in: self)
      let y = loc.y - touchedLocation.y
      let xknobX =  knobBeginX + y
      let maxY = bounds.size.height - knobRect.size.height
      
      sliderValue = xknobX / CGFloat(maxY)
    }else {
      let loc = touch.location(in: self)
      let x = loc.x - touchedLocation.x
      let xknobX =  knobBeginX + x
      let maxX = bounds.size.width - knobRect.size.width
      
      sliderValue = xknobX / CGFloat(maxX)
    }
    
    sliderValue = max(0.0, sliderValue)
    sliderValue = min(1, sliderValue)
    if vertical {
      self.value = 1 - Float(sliderValue)
      
    }else {
      self.value = Float(sliderValue)
    }
    sendActions(for: UIControl.Event.valueChanged)
    
    return true
  }
  
  override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    knobRect = knob.frame
    sendActions(for: UIControl.Event.valueChanged)

  }

  override open func cancelTracking(with event: UIEvent?) {
    super.cancelTracking(with: event)
    knobRect = knob.frame
  }
}

public class SimpleSlider: AlphaSlider {
  
  override public var color: SIMD4<Float> {
    set {
      background.components1 = [0, 0, 0, 0.3]
      background.components2 = [CGFloat(newValue[0]), CGFloat(newValue[1]), CGFloat(newValue[2]), 1]
      
      background.setNeedsDisplay()
    }
    get {
      return background.color
    }
  }
  
  public func setColor(_ color1: SIMD4<Float>, and color2: SIMD4<Float>) {
    background.components1 = [CGFloat(color1[0]), CGFloat(color1[1]), CGFloat(color1[2]), 1]
    background.components2 = [CGFloat(color2[0]), CGFloat(color2[1]), CGFloat(color2[2]), 1]

    background.setNeedsDisplay()

  }
  
  override func setup() {
    super.setup()
    splitWithKnob = true
    background.drawCheckers = false
  }
}


class AlphaSnippet: UIControl {
  var gesture: MNDragGestureRecognizer!
  
  var myBackgroundColor: SIMD4<Float>? {
    didSet {
      setNeedsDisplay()
    }
  }
  var convertDarkColor = false
  func setup(forParentViewController controller: UIViewController) {
    super.awakeFromNib()
    let gesture = MNDragGestureRecognizer(target: self, action: nil)
    gesture.parentViewController = controller
    addGestureRecognizer(gesture)
  }
  
  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    let darkMode: Bool
    if #available(iOS 13.0, *) {
      darkMode = traitCollection.userInterfaceStyle == .dark
    } else {
      darkMode = false
    }
    
    let path = CGMutablePath()
    
    if let myBackgroundColor = myBackgroundColor {
      path.addEllipse(in: rect.insetBy(dx: 0.25, dy: 0.25))
      ctx.setBlendMode(.normal);
      ctx.addPath(path)
      let c = UIColor(red: CGFloat(myBackgroundColor[0]), green: CGFloat(myBackgroundColor[1]), blue: CGFloat(myBackgroundColor[2]), alpha: CGFloat(myBackgroundColor[3]))
      
      ctx.setFillColor(c.cgColor)
      ctx.fillPath()
      ctx.addPath(path)
      if #available(iOS 13.0, *) {
        ctx.setStrokeColor(UIColor.separator.cgColor)
      } else {
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
      }
      ctx.setLineWidth(0.5)
      ctx.strokePath()
      
      if #available(iOS 13.0, *) {
        if darkMode && convertDarkColor {
          let darkColor = PKInkingTool.convertColor(c, from: .light, to: .dark)

          var path = CGMutablePath()
          path.addEllipse(in: rect.insetBy(dx: 3, dy: 3))
          ctx.addPath(path)
          ctx.clip()
          ctx.clear(rect)
          
          path = CGMutablePath()
          path.addEllipse(in: rect.insetBy(dx: 3, dy: 3))
          ctx.setBlendMode(.normal);
          ctx.addPath(path)
          ctx.setFillColor(darkColor.cgColor)
          ctx.fillPath()
          
        }
      }
      
      let alpha = myBackgroundColor[3]
      if alpha < 1 {
        let title = NSString(format: "%2.0d", Int(alpha*100))
        if #available(iOS 13.0, *) {
          
          let attr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.label]
          let size = title.size(withAttributes: attr)
          let p = CGPoint(x: (bounds.size.width - size.width)/2, y: (bounds.size.height - size.height)/2)
          title.draw(at: p, withAttributes: attr)
        }else {
          let attr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.darkText]
          let size = title.size(withAttributes: attr)
          let p = CGPoint(x: (bounds.size.width - size.width)/2, y: (bounds.size.height - size.height)/2)
          title.draw(at: p, withAttributes: attr)
        }
      }
      
    }else {
      path.addEllipse(in: rect.insetBy(dx: 1, dy: 1))

      ctx.addPath(path)
      ctx.setLineDash(phase: 2, lengths: [4, 2])
      if #available(iOS 13.0, *) {
        ctx.setStrokeColor(UIColor.placeholderText.cgColor)
      } else {
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
      }
      ctx.setLineWidth(1)
      ctx.strokePath()

    }
  }
  
  deinit {
    forusRing?.removeFromSuperview()
  }
  
  weak var forusRing: NailDroppingView?
  func showFocusRing() {
    let ringFrame = frame.insetBy(dx: -10, dy: -10)
    
    let view = NailDroppingView(frame: superview!.convert(ringFrame, to: window))

    view.tintColor = tintColor
    
    forusRing = view
    window?.addSubview(view)
    forusRing?.appearAnimation()
  }

}

class NailDroppingView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame.insetBy(dx: -15, dy: -15))
    
    self.isOpaque = false;
    self.backgroundColor = .clear;
    self.clearsContextBeforeDrawing = true;
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    let strokeRect = rect.insetBy(dx: 5, dy: 5);
    let path = UIBezierPath(roundedRect: strokeRect, cornerRadius: rect.size.width/2)
    
    tintColor.setStroke()
    path.lineWidth = 8
    path.stroke()
    
  }
  
  func appearAnimation() {
    transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    
    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: [], animations: {
      self.transform = .identity
    }) { (_) in
      
    }

  }
}

extension AlphaSnippet: MNDraggingDestination {
  func canAccept(_ draggingObject: MNDraggingObject!) -> Bool {
    return draggingObject.source != self
  }
  
  func draggingObjectEntered(_ draggingObject: MNDraggingObject!) {
    if forusRing == nil {
      showFocusRing()
    }
    draggingObject.destination = self
    
    guard let window = draggingObject.parentViewController.view.window else { return }
    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)

    let tooltip = draggingObject.userInfo.object(forKey: "tooltip") as? DraggingTooltipView
    tooltip?.showDraggingTooltip(at: point, in: window, message: NSLocalizedString("Set", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: ""), type: TooltipViewCommand, afterDelay: 0)

  }
  
  func draggingDestinationUpdated(_ draggingObject: MNDraggingObject!) {
    let tooltip = draggingObject.userInfo.object(forKey: "tooltip") as? DraggingTooltipView
    guard let window = draggingObject.parentViewController.view.window else { return }
    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)

    tooltip?.showDraggingTooltip(at: point, in: window, message: NSLocalizedString("Set", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: ""), type: TooltipViewCommand, afterDelay: 0)

  }
  
  func draggingObjectExited(_ draggingObject: MNDraggingObject!) {
    forusRing?.removeFromSuperview()
    forusRing = nil
  }
  
  func draggingObjectDidDrop(_ draggingObject: MNDraggingObject!, onCompletion blockToExecute: ((Bool) -> Void)!) {
    forusRing?.removeFromSuperview()
    forusRing = nil
    
    blockToExecute(true)
  }
  
  func droppingDestination(_ draggingObject: MNDraggingObject!) -> CGPoint {
    let frameInSuper = superview!.convert(frame, to: superview!.superview!)
    return CGPoint(x: frameInSuper.midX, y: frameInSuper.midY)
  }
  
  func droppingDestinationScale(_ draggingObject: MNDraggingObject!) -> CGFloat {
    return 0.5
  }
  
  func concludeDroppingAnimationDidFinish(_ draggingObject: MNDraggingObject!) {
    let myBackgroundColor = draggingObject.userInfo.object(forKey: "color") as? SIMD4<Float>
    self.myBackgroundColor = myBackgroundColor
    
    sendActions(for: .applicationReserved)

    setNeedsDisplay()
  }
  
}

extension AlphaSnippet: MNDraggingSource {
  
   func canBeginDraggingImmediately(_ locationInView: CGPoint) -> Bool {
     return false
   }

   func canBeginDragging(_ locationInView: CGPoint) -> Bool {
     return myBackgroundColor != nil
   }
  
  func beganDragging(_ draggingObject: MNDraggingObject!) {
    guard let myBackgroundColor = myBackgroundColor else { return }
    let rect = CGRect(x: 0, y: 0, width: 60, height: 60)

    UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width, height: rect.size.height), false, 0)
    if let ctx = UIGraphicsGetCurrentContext() {

      let path = CGMutablePath()
      
      path.addEllipse(in: rect.insetBy(dx: 0.25, dy: 0.25))
      
      ctx.addPath(path)
      
      
      let c = UIColor(red: CGFloat(myBackgroundColor[0]), green: CGFloat(myBackgroundColor[1]), blue: CGFloat(myBackgroundColor[2]), alpha: CGFloat(myBackgroundColor[3]))
      
      ctx.setFillColor(c.cgColor)
      
      ctx.fillPath()
      ctx.addPath(path)
      if #available(iOS 13.0, *) {
        ctx.setStrokeColor(UIColor.separator.cgColor)
      } else {
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
      }
      ctx.setLineWidth(0.5)
      ctx.strokePath()
      
      let darkMode: Bool
      if #available(iOS 13.0, *) {
        darkMode = traitCollection.userInterfaceStyle == .dark
      } else {
        darkMode = false
      }
      
      if #available(iOS 13.0, *) {
        if darkMode && convertDarkColor {
          let darkColor = PKInkingTool.convertColor(c, from: .light, to: .dark)
          
          var path = CGMutablePath()
          path.addEllipse(in: rect.insetBy(dx: 3, dy: 3))
          ctx.addPath(path)
          ctx.clip()
          ctx.clear(rect)
          
          path = CGMutablePath()
          path.addEllipse(in: rect.insetBy(dx: 3, dy: 3))
          ctx.setBlendMode(.normal);
          ctx.addPath(path)
          ctx.setFillColor(darkColor.cgColor)
          ctx.fillPath()
          
        }
      }
      
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    var p = draggingObject.location
    
    p.x -= rect.size.width/2
    p.y -= rect.size.height/2
    draggingObject.setDragging(image, location: p)
    
    let tooltip = DraggingTooltipView.tooltip()!
    guard let window = draggingObject.parentViewController.view.window else { return }
    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)
    tooltip.showDraggingTooltip(at: point, in: window, message: NSLocalizedString("Drag", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: ""), type: TooltipViewInformation, afterDelay: 0)
draggingObject.userInfo.setObject(tooltip, forKey: "tooltip" as NSString)
    draggingObject.userInfo.setObject(myBackgroundColor, forKey: "color" as NSString)
  }
  
  
//  func willBeginDraggingSoon(_ draggingObject: MNDraggingObject!) {
//    let tooltip = DraggingTooltipView.tooltip()!
//    guard let window = draggingObject.parentViewController.view.window else { return }
//    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)
//    tooltip.showDraggingTooltip(at: point, in: window, message: "Hold to Drag", type: TooltipViewInformation, afterDelay: 0)
//    draggingObject.userInfo.setObject(tooltip, forKey: "tooltip" as NSString)
//
//    draggingObject.userInfo.setObject(myBackgroundColor!, forKey: "color" as NSString)
//
//  }

  
  //
  //  func draggingObject(_ draggingObject: MNDraggingObject!, needsCustomSlideBackPointInView pointPtr: UnsafeMutablePointer<CGPoint>!) -> Bool {
  //    <#code#>
  //  }
  //
  func draggingSourceUpdated(_ draggingObject: MNDraggingObject!) {
    if draggingObject.destination == nil {
      let tooltip = draggingObject.userInfo.object(forKey: "tooltip") as? DraggingTooltipView
      
      guard let window = draggingObject.parentViewController.view.window else { return }
      let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)
      tooltip?.showDraggingTooltip(at: point, in: window, message: NSLocalizedString("Drag", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: ""), type: TooltipViewInformation, afterDelay: 0)
    }
  }
  //
  func concludeDragging(_ draggingObject: MNDraggingObject!, success: Bool) {
    let tooltip = draggingObject.userInfo.object(forKey: "tooltip") as? DraggingTooltipView
    tooltip?.closeTooltip()

  }
//
//  func concludeDraggingAnimationDidStart(_ draggingObject: MNDraggingObject!) {
//    <#code#>
//  }
//
//  func concludeDraggingAnimationDidFinish(_ draggingObject: MNDraggingObject!) {
//    <#code#>
//  }
//

}
