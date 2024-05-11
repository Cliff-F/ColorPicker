//
//  SwiftHSVColorPicker.swift
//  SwiftHSVColorPicker
//
//  Created by johankasperi on 2015-08-20.
//

import UIKit

open class SwiftHSVColorPicker: UIView, ColorWheelDelegate {
  var colorWheel: ColorWheel!
  var brightnessView: BrightnessView!
  weak var delegate: ComponentDelegate?
  var vertical = false
  open var color: UIColor! {
    didSet {
      
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      color.getRed(&red, green: &green, blue: &blue, alpha: nil)
      delegate?.setRGBColor(SIMD4<Float>(Float(red), Float(green), Float(blue), 1))
    }
  }
  var hue: CGFloat = 1.0
  var saturation: CGFloat = 1.0
  var brightness: CGFloat = 1.0
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.backgroundColor = UIColor.clear
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  open func setViewColor(_ color: UIColor) {
    var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
    let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    if (!ok) {
      print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
    }
    self.hue = hue
    self.saturation = saturation
    self.brightness = brightness
    self.color = color
    setup()
  }
  
  func setup() {
    clipsToBounds = false
    // Remove all subviews
    let views = self.subviews
    for view in views {
      view.removeFromSuperview()
    }
    
    let brightnessViewHeight: CGFloat = 26.0
    let bottomMargin: CGFloat = 20
    if vertical {
      
      // let color wheel get the maximum size that is not overflow from the frame for both width and height
      let colorWheelRadius = min(self.bounds.height/2, self.bounds.width/2 - brightnessViewHeight - bottomMargin)
      
      // let the all the subviews stay in the middle of universe horizontally
      let centeredX = self.bounds.width/2 - colorWheelRadius
      let centeredY = self.bounds.height/2 - colorWheelRadius

      // Init new ColorWheel subview
      colorWheel = ColorWheel(frame: CGRect(x: centeredX, y: centeredY, width: colorWheelRadius*2, height: colorWheelRadius*2), color: self.color)
      colorWheel.delegate = self
      // Add colorWheel as a subview of this view
      self.addSubview(colorWheel)
      
      // Init new BrightnessView subview
      brightnessView = BrightnessView(frame: CGRect(x: colorWheel.frame.maxX, y: centeredY, width: brightnessViewHeight , height: colorWheelRadius*2))
      brightnessView.vertical = true
      brightnessView.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]

    }else {
      // let color wheel get the maximum size that is not overflow from the frame for both width and height
      let colorWheelRadius = min(self.bounds.width/2, self.bounds.height/2 - brightnessViewHeight - bottomMargin)
      
      // let the all the subviews stay in the middle of universe horizontally
      let centeredX = self.bounds.width/2 - colorWheelRadius
      let centeredY = self.bounds.height/2 - colorWheelRadius

      // Init new ColorWheel subview
      colorWheel = ColorWheel(frame: CGRect(x: centeredX, y: centeredY, width: colorWheelRadius*2, height: colorWheelRadius*2), color: self.color)
      colorWheel.delegate = self
      // Add colorWheel as a subview of this view
      self.addSubview(colorWheel)
      
      // Init new BrightnessView subview
      brightnessView = BrightnessView(frame: CGRect(x: centeredX, y: colorWheel.frame.maxY, width: colorWheelRadius*2*2, height: brightnessViewHeight))
      brightnessView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    let brightestColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: 1, alpha: 1.0)
    brightestColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    brightnessView.color = SIMD4<Float>(Float(red), Float(green), Float(blue), 1)
    brightnessView.value = Float(brightness)
    brightnessView.addTarget(self, action: #selector(brightnessChanged(_:)), for: .valueChanged)
    // Add brightnessView as a subview of this view
    self.addSubview(brightnessView)
  }
  
  
  
  func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
    self.hue = hue
    self.saturation = saturation
    self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
    
    
    let brightestColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: 1, alpha: 1.0)

    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    
    brightestColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    brightnessView.color = SIMD4<Float>(Float(red), Float(green), Float(blue), 1)
  }
  
 @objc func brightnessChanged(_ sender: Any) {
  self.brightness = CGFloat(brightnessView.value)
    self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
    colorWheel.setViewBrightness(brightness)
  }
}
