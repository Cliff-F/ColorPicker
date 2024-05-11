//
//  ColorPicker.swift
//  ColorPicker
//
//  Created by Masatoshi Nishikata on 4/01/20.
//  Copyright © 2020 Catalystwo Limited. All rights reserved.
//

import Foundation
import UIKit
#if canImport(PencilKit)
import PencilKit
#endif

public protocol ColorPickerDelegate: AnyObject {
  func setColor(_ colorPicker: ColorPickerViewController, color: SIMD4<Float>?)
}

protocol ComponentDelegate: AnyObject {
  var darkMode: Bool { get }
  var color: SIMD4<Float> { get }
  func setRGBColor(_ : SIMD4<Float>)
}

protocol ColorPaletteViewSource: AnyObject {
  func color(at: CGPoint) -> SIMD4<Float>?
}

class ColorPaletteView: UIView {
  weak var delegate: ColorPaletteViewSource?
  var gesture: MNDragGestureRecognizer!
  var myColor: SIMD4<Float>?
  
  func setup(forParentViewController controller: UIViewController) {
    super.awakeFromNib()
    let gesture = MNDragGestureRecognizer(target: self, action: nil)
    gesture.parentViewController = controller
    
    addGestureRecognizer(gesture)
  }
  
  
  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    guard let image = UIImage(named: "IMG_FEFCFA86CCE7-1", in: Bundle(for: ColorPickerViewController.self), compatibleWith: nil) else { return }
    
    
    let size = image.size
    let data = image.cgImage!.dataProvider!.data
    let w = rect.size.width/12
    let h = rect.size.height/10

    for y in 0..<10 {
      let py: CGFloat = size.height/10 * CGFloat(y) + 5
      
      for x in 0..<12 {
        let px: CGFloat = size.width/12 * CGFloat(x) + 5
        
        let p = CGPoint(x: px, y: py)
        var simdcolor = image.getPixelColor(pos: p, in: data)
        var color = UIColor(red: CGFloat(simdcolor[0]), green: CGFloat(simdcolor[1]), blue: CGFloat(simdcolor[2]), alpha: CGFloat(simdcolor[3]))
//        if traitCollection.userInterfaceStyle == .dark {
//          color = PKInkingTool.convertColor(color, from: .light, to: .dark)
//        }
        ctx.setFillColor(color.cgColor)
        ctx.fill([CGRect(x: CGFloat(x)*w, y: CGFloat(y)*h, width: w, height: h)])
      }
    }
    
  }
}

extension ColorPaletteView: MNDraggingSource {
  
   func canBeginDraggingImmediately(_ locationInView: CGPoint) -> Bool {
    return false
  }
  
  func canBeginDragging(_ locationInView: CGPoint) -> Bool {
    guard let color = delegate?.color(at: locationInView) else { return false }
    myColor = color
    return true
  }
  
  func beganDragging(_ draggingObject: MNDraggingObject!) {
    let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width, height: rect.size.height), false, 0)
    if let ctx = UIGraphicsGetCurrentContext() {
      
      let path = CGMutablePath()
      
      path.addEllipse(in: rect.insetBy(dx: 0.25, dy: 0.25))
      
      ctx.addPath(path)
      if myColor != nil {
        let c = UIColor(red: CGFloat(myColor![0]), green: CGFloat(myColor![1]), blue: CGFloat(myColor![2]), alpha: CGFloat(myColor![3]))
        
        ctx.setFillColor(c.cgColor)
      }
      ctx.fillPath()
      ctx.addPath(path)
      if #available(iOS 13.0, *) {
        ctx.setStrokeColor(UIColor.separator.cgColor)
      } else {
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
      }
      ctx.setLineWidth(0.5)
      ctx.strokePath()
      
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    var p = draggingObject.location
    
    p.x -= rect.size.width/2
    p.y -= rect.size.height/2
    draggingObject.setDragging(image, location: p)
    
    guard let window = draggingObject.parentViewController.view.window else { return }
    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)
    
    let tooltip = DraggingTooltipView.tooltip()!
    tooltip.showDraggingTooltip(at: point, in: window, message: NSLocalizedString("Drag", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: ""), type: TooltipViewInformation, afterDelay: 0)
    draggingObject.userInfo.setObject(tooltip, forKey: "tooltip" as NSString)
    draggingObject.userInfo.setObject(myColor!, forKey: "color" as NSString)
  }
  
  
//  func willBeginDraggingSoon(_ draggingObject: MNDraggingObject!) {
//    let tooltip = DraggingTooltipView.tooltip()!
//    guard let window = draggingObject.parentViewController.view.window else { return }
//    let point = window.convert(draggingObject.location, from: draggingObject.parentViewController.view)
//
//    tooltip.showDraggingTooltip(at: point, in: window, message: "Hold to Drag", type: TooltipViewInformation, afterDelay: 0)
//    draggingObject.userInfo.setObject(tooltip, forKey: "tooltip" as NSString)
//    draggingObject.userInfo.setObject(myColor!, forKey: "color" as NSString)
//  }


//
//  func draggingObject(_ draggingObject: MNDraggingObject!, needsCustomSlideBackPointInView pointPtr: UnsafeMutablePointer<CGPoint>!) -> Bool {
//
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

class ColorWheelViewController: UIViewController {
  weak var delegate: ComponentDelegate?
  @IBOutlet weak var wheelView: SwiftHSVColorPicker!
  var vertical = false
  var convertDarkColor = false

  override func viewDidLoad() {
    super.viewDidLoad()
    wheelView.vertical = vertical
    updateColor()
    wheelView.delegate = delegate
  }
  
  func updateColor() {
    guard let delegate = delegate else { return }
    var c = UIColor(red: CGFloat(delegate.color[0]), green: CGFloat(delegate.color[1]), blue: CGFloat(delegate.color[2]), alpha: 1)
    
    if #available(iOS 13.0, *) {
      if traitCollection.userInterfaceStyle == .dark && convertDarkColor {
        c = PKInkingTool.convertColor(c, from: .light, to: .dark)
      }
    }
    wheelView.setViewColor(c)
  }
}



class ColorPaletteViewController: UIViewController, ColorPaletteViewSource {

  @IBOutlet weak var imageView: ColorPaletteView!
  var colors: [SIMD4<Float>] = []
  weak var indicatorView: UIImageView?
  weak var delegate: ComponentDelegate?
  var convertDarkColor = false
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    guard let image = UIImage(named: "IMG_FEFCFA86CCE7-1", in: Bundle(for: ColorPickerViewController.self), compatibleWith: nil) else { return }

    imageView.isUserInteractionEnabled = true
    let size = image.size
    let data = image.cgImage!.dataProvider!.data
    for y in 0..<10 {
      let py: CGFloat = size.height/10 * CGFloat(y) + 5

      for x in 0..<12 {
        let px: CGFloat = size.width/12 * CGFloat(x) + 5

        let p = CGPoint(x: px, y: py)
        let color = image.getPixelColor(pos: p, in: data)
        colors.append(color)
      }
    }

    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    gesture.numberOfTapsRequired = 1
    gesture.numberOfTouchesRequired = 1
    imageView.addGestureRecognizer(gesture)
    
    
    let indicatorView = UIImageView(image: UIImage(named: delegate?.darkMode == true ? "paletteCursorDark" : "paletteCursor", in: Bundle(for: ColorPickerViewController.self), compatibleWith: nil)!.stretchableImage(withLeftCapWidth: 10, topCapHeight: 10))
    self.indicatorView = indicatorView
    imageView.addSubview(indicatorView)
    imageView.delegate = self
    adjustIndicator()

  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    imageView.setup(forParentViewController: self.parent!)
    
  }
  
  func adjustIndicator() {
    
    var idx: Int? = nil
    for hoge in 0 ..< colors.count {
      let color = colors[hoge]
      
      var convertDarkMode = false
      if #available(iOS 13.0, *) {
        if traitCollection.userInterfaceStyle == .dark && convertDarkColor {
          convertDarkMode = true
        }
      }
      if convertDarkMode {
        if #available(iOS 13.0, *) {
          let uicolor = UIColor(red: CGFloat(color[0]), green: CGFloat(color[1]), blue: CGFloat(color[2]), alpha: 1)
          let darkColor = PKInkingTool.convertColor(uicolor, from: .light, to: .dark)
          
          var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
          darkColor.getRed(&r, green: &g, blue: &b, alpha: &a)
          
          if Float(r) == delegate!.color[0] && Float(g) == delegate!.color[1] && Float(b) == delegate!.color[2] {
            idx = hoge
            break
          }
        }
      }else {
        
        if color[0] == delegate!.color[0] && color[1] == delegate!.color[1] && color[2] == delegate!.color[2] {
          idx = hoge
          break
        }
      }
    }
    
    if let idx = idx {
      indicatorView?.isHidden = false

      let yy = idx / 12
      let xx = idx - yy * 12
      
      let size = imageView.frame.size
      
      let dy: CGFloat = size.height/10
      let dx: CGFloat = size.width/12

      indicatorView?.frame = CGRect(x: dx * CGFloat(xx), y: dy * CGFloat(yy), width: dx, height: dy)
    }else {
      indicatorView?.isHidden = true
    }
  }
  
  
  
  @objc func tapAction(_ gest: UITapGestureRecognizer) {

    let loc = gest.location(in: imageView)

    guard let color = self.color(at: loc) else { return }
    delegate?.setRGBColor(color)
    adjustIndicator()
  }
  
  func color(at loc: CGPoint) -> SIMD4<Float>? {
    let size = imageView.frame.size
    
    let dy: CGFloat = size.height/10
    let dx: CGFloat = size.width/12
    
    let xx = Int(loc.x / dx)
    let yy = Int(loc.y / dy)
    
    let color = colors[xx + yy * 12]
    
    return color
  }
  
}

public class ColorPickerViewController: UIViewController, ComponentDelegate, UIScrollViewDelegate {
  public weak var delegate: ColorPickerDelegate?

  @IBOutlet weak var snipetView: AlphaSnippet!
  @IBOutlet weak var alphaSlider: AlphaSlider!
  @IBOutlet weak var scollView: UIScrollView!
  
  @IBOutlet weak var fav1: AlphaSnippet!
  @IBOutlet weak var fav2: AlphaSnippet!
  @IBOutlet weak var fav3: AlphaSnippet!
  @IBOutlet weak var fav4: AlphaSnippet!
  @IBOutlet weak var fav5: AlphaSnippet!
  @IBOutlet weak var fav6: AlphaSnippet!
  @IBOutlet weak var fav7: AlphaSnippet!
  @IBOutlet weak var deleteButton: UIButton!
  
  @IBOutlet weak var tipsLabel: UILabel!
  
  @IBOutlet weak var pageControl: UIPageControl!
  
  public var color: SIMD4<Float> = SIMD4<Float>(0,0,0,1)
  public var hasDeleteButton = false
  public var tag: Int = 0
  public var opaqueBackground = false
  public var convertDarkColor = false
  
  func setRGBColor(_ rgb: SIMD4<Float>) {
    color[0] = rgb[0]
    color[1] = rgb[1]
    color[2] = rgb[2]
    
    guard isViewLoaded else { return }
    
    alphaSlider.color = color

    if #available(iOS 13.0, *) {
      if traitCollection.userInterfaceStyle == .dark && convertDarkColor {
        let uicolor = UIColor(red: CGFloat(color[0]), green: CGFloat(color[1]), blue: CGFloat(color[2]), alpha: 1)
        let darkColor = PKInkingTool.convertColor(uicolor, from: .light, to: .dark)
        
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        darkColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        color[0] = Float(r)
        color[1] = Float(g)
        color[2] = Float(b)
      }
    }
    snipetView.myBackgroundColor = color
    
    delegate?.setColor(self, color: color)
  }
    
  var paletteViewController: ColorPaletteViewController!
  var wheelViewController: ColorWheelViewController!

  override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if #available(iOS 13.0, *) {
      if previousTraitCollection == nil || traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection!) {
        self.darkMode = traitCollection.userInterfaceStyle == .dark
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
  public var darkMode: Bool = false {
    didSet {
      alphaSlider?.darkMode = darkMode
    }
  }

  override public var preferredContentSize: CGSize {
    get {
      return CGSize(width: 280, height: 360)
    }
    set {
    }
  }
  
  public override func viewDidLayoutSubviews() {
    paletteViewController.view.frame = CGRect(x: 0, y: 0, width: scollView.frame.size.width, height: scollView.frame.size.height)
    scollView.contentSize = CGSize(width: scollView.frame.size.width * 2, height: scollView.frame.size.height)
    paletteViewController.adjustIndicator()
  }
  
  public static func viewController(color: SIMD4<Float>) -> ColorPickerViewController {
    let controller = UIStoryboard(name: "ColorPicker", bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")).instantiateInitialViewController() as! ColorPickerViewController
    controller.color = color
    return controller
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 13.0, *) {
      if opaqueBackground {
        self.view.backgroundColor = UIColor.tertiarySystemBackground
      }
    }
    guard let paletteViewController = storyboard?.instantiateViewController(withIdentifier: "ColorPaletteViewController") as? ColorPaletteViewController else { return } // UNKNOWN ERROR
    paletteViewController.delegate = self
    paletteViewController.convertDarkColor = convertDarkColor
    paletteViewController.view.frame = scollView.bounds
    scollView.addSubview(paletteViewController.view)
    addChild(paletteViewController)
    paletteViewController.didMove(toParent: self)
    self.paletteViewController = paletteViewController
    
    
    guard let wheelViewController = storyboard?.instantiateViewController(withIdentifier: "ColorWheelViewController") as? ColorWheelViewController else { return } // UNKNOWN ERROR
    wheelViewController.delegate = self
    wheelViewController.convertDarkColor = convertDarkColor
    wheelViewController.vertical = true
    var frame = scollView.bounds
    frame.origin.x = frame.size.width
    wheelViewController.view.frame = frame
    wheelViewController.view.isHidden = true
    scollView.addSubview(wheelViewController.view)
    addChild(wheelViewController)
    wheelViewController.didMove(toParent: self)
    self.wheelViewController = wheelViewController
    
    
    scollView.contentSize = CGSize(width: scollView.frame.size.width * 2, height: scollView.frame.size.height)
    alphaSlider.darkMode = darkMode
    alphaSlider.color = color
    
    let snippets: [AlphaSnippet] = [fav1, fav2, fav3, fav4, fav5, fav6, fav7, snipetView]
    
    snippets.forEach {
      $0.setup(forParentViewController: self)
      $0.addTarget(self, action: #selector(snippetDidClick(_:)), for: .touchUpInside)
      $0.addTarget(self, action: #selector(snippetGotColor(_:)), for: .applicationReserved)
      $0.convertDarkColor = convertDarkColor
    }
    snipetView.convertDarkColor = convertDarkColor
    snipetView.myBackgroundColor = color
    loadPresets()
    
    tipsLabel.isHidden = true
    tipsLabel.text = NSLocalizedString("Drag and drop swatches here", tableName: nil, bundle: Bundle(identifier: "com.catalystwo.MetalProject.ColorPicker")!, value: "", comment: "")
    tipsLabel.layer.cornerRadius = tipsLabel.frame.size.height/2
    tipsLabel.layer.shadowColor = UIColor.black.cgColor
    tipsLabel.layer.shadowRadius = 3
    tipsLabel.layer.shadowOpacity = 0.3
    tipsLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    if #available(iOS 13.0, *) {
      tipsLabel.backgroundColor = UIColor.systemBackground
    } else {
      tipsLabel.backgroundColor = .lightGray
    }
//    tipsLabel.isOpaque = true
    tipsLabel.superview?.bringSubviewToFront(tipsLabel)
    
    pageControl.currentPageIndicatorTintColor = view.tintColor
    
    if hasDeleteButton == false {
      deleteButton.isHidden = true
      let snippets: [AlphaSnippet] = [fav1, fav2, fav3, fav4, fav5, fav6, fav7]
      
      snippets.forEach {
        var frame = $0.frame
        frame.origin.x -= 17
        $0.frame = frame
      }

    }
  }
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    paletteViewController.adjustIndicator()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    savePresets()
  }
  
  func loadPresets() {
    let snippets: [AlphaSnippet] = [fav1, fav2, fav3, fav4, fav5, fav6, fav7]
    for n in 0..<snippets.count {
      let key = "ColorPicker_\(n)"

      if let value = UserDefaults.standard.object(forKey: key) as? [CGFloat] {
        
        let snippet = snippets[n]

        var color: SIMD4<Float> = SIMD4<Float>(0,0,0,0)
        
        color[0] = Float(value[0])
        color[1] = Float(value[1])
        color[2] = Float(value[2])
        color[3] = Float(value[3])
        snippet.myBackgroundColor = color
      }
    }
  }
  
  func savePresets() {
    let snippets: [AlphaSnippet] = [fav1, fav2, fav3, fav4, fav5, fav6, fav7]
    for n in 0..<snippets.count {
      let snippet = snippets[n]
      if let color = snippet.myBackgroundColor {
        let key = "ColorPicker_\(n)"
        let value: [CGFloat] = [CGFloat(color[0]), CGFloat(color[1]), CGFloat(color[2]), CGFloat(color[3])]
        UserDefaults.standard.set(value, forKey: key)
      }
    }
  }
  
  @objc func snippetDidClick(_ sender: AlphaSnippet) {
    if let newColor = sender.myBackgroundColor {
      delegate?.setColor(self, color: newColor)
      dismiss(animated: true, completion: nil)
    }else {
      tipsLabel.isHidden = false
      weak var label = tipsLabel

      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        UIView.animate(withDuration: 0.3, animations: {
          label?.alpha = 0
        }) { (_) in
          label?.isHidden = true
          label?.alpha = 1
        }
      }
    }
  }
  
  @objc func snippetGotColor(_ sender: AlphaSnippet) {
    if sender == snipetView, let newColor = sender.myBackgroundColor {
      color = newColor
      alphaSlider.color = newColor
      delegate?.setColor(self, color: color)
      paletteViewController.adjustIndicator()
      wheelViewController.updateColor()
    }
  }
  
  
  @IBAction func deleteColor(_ sender: Any) {
    delegate?.setColor(self, color: nil)
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func alphaSliderAction(_ sender: AlphaSlider) {
    
    var fcolor: SIMD4<Float> =  color
    fcolor[3] = sender.value
    color = fcolor
    
    snipetView.myBackgroundColor = color
    
//    if sender.isTracking == false {
      delegate?.setColor(self, color: color)
//    }
  }
  
  public var isTracking: Bool {
    alphaSlider.isTracking
  }
  
  @IBAction func pageControlChanged(_ sender: Any) {
    if pageControl.currentPage == 0 {
      scollView.setContentOffset(.zero ,animated: true)
    }else if pageControl.currentPage == 1 {
      scollView.setContentOffset(CGPoint(x: 300, y: 0) ,animated: true)
      wheelViewController.view.isHidden = false
      wheelViewController.updateColor()

    }
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if pageControl.currentPage == 0 {
      wheelViewController.view.isHidden = false
      wheelViewController.updateColor()

    }else if pageControl.currentPage == 1 {
      paletteViewController.adjustIndicator()
    }

  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if scrollView.contentOffset.x > preferredContentSize.width-1 {
      paletteViewController?.view.isHidden = true
      pageControl.currentPage = 1
      
    }else {
      paletteViewController?.view.isHidden = false
      pageControl.currentPage = 0

    }
  }
}



public extension UIImage {
  func getPixelColor(pos: CGPoint, in pixelDataBuf: CFData? = nil) -> SIMD4<Float> {
    
    let pixelData = pixelDataBuf ?? self.cgImage!.dataProvider!.data!
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
    let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
    
    let r = Float(data[pixelInfo]) / Float(255.0)
    let g = Float(data[pixelInfo+1]) / Float(255.0)
    let b = Float(data[pixelInfo+2]) / Float(255.0)
    let a = Float(data[pixelInfo+3]) / Float(255.0)
    
    return SIMD4<Float>(r, g, b, a)
  }
  
  func getPixelColori(pos: CGPoint, in pixelDataBuf: CFData? = nil) -> SIMD4<UInt8> {
    
    let pixelData = pixelDataBuf ?? self.cgImage!.dataProvider!.data!
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
    let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
    
    let r = data[pixelInfo]
    let g = data[pixelInfo+1]
    let b = data[pixelInfo+2]
    let a = data[pixelInfo+3]
    
    return SIMD4<UInt8>(r, g, b, a)
  }
  
  func getColorForPixel() -> UIImage {
    let imageWidth = self.cgImage!.width
    let imageHeight = self.cgImage!.height
    let imageRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
    
    let bitmapBytesForRow = Int(imageWidth * 4)
    let bitmapByteCount = bitmapBytesForRow * Int(imageHeight)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bitmapMemory = malloc(bitmapByteCount)
    let bitmapInformation = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue
    
    let colorContext = CGContext(data: bitmapMemory, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: bitmapBytesForRow, space: colorSpace, bitmapInfo: bitmapInformation)!
    
    colorContext.clear(imageRect)
    colorContext.draw(self.cgImage!, in: imageRect)
    let cgImage = colorContext.makeImage()!
    if bitmapMemory != nil {
      free(bitmapMemory!)
    }
    
    return UIImage(cgImage: cgImage )

    
//    let offset = 4 * (Int(imageWidth) * Int(point.y)) + Int(point.x)
//
//
//    let redComponent = CGFloat(data.load(fromByteOffset: offset, as: UInt8.self))/255.0
//    let greenComponent = CGFloat(data.load(fromByteOffset: offset+1, as: UInt8.self))/255.0
//    let blueComponent = CGFloat(data.load(fromByteOffset: offset+2, as: UInt8.self))/255.0
//    let alphaComponent = CGFloat(data.load(fromByteOffset: offset+3, as: UInt8.self))/255.0
//
//    if redComponent + greenComponent + blueComponent + alphaComponent != 0 {
//
//    }
//
//    free(bitmapMemory)
//    return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
  }
}
