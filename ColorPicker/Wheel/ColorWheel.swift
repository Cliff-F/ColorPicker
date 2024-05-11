//
//  ColorWheel.swift
//  SwiftHSVColorPicker
//
//  Created by johankasperi on 2015-08-20.
//

import UIKit

protocol ColorWheelDelegate: AnyObject {
  func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat)
}

class ColorWheel: UIControl {
  var color: UIColor!
  
  // Layer for the Hue and Saturation wheel
  var wheelLayer: CALayer!
  
  // Overlay layer for the brightness
//  var brightnessLayer: CAShapeLayer!
  var brightness: CGFloat = 1.0
  
  // Layer for the indicator
  var indicatorLayer: CAShapeLayer!
  var point: CGPoint!
  var indicatorCircleRadius: CGFloat = 12.0
  var indicatorColor: CGColor = UIColor.white.cgColor
  var indicatorBorderWidth: CGFloat = 2.0
  
  // Retina scaling factor
  let scale: CGFloat = 1
  let wheelEdgeMargin: CGFloat = 15

  weak var delegate: ColorWheelDelegate?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }

  init(frame: CGRect, color: UIColor!) {
    super.init(frame: frame)
    
    self.color = color
    clipsToBounds = false

    let baselayer = CALayer()
    baselayer.frame = self.bounds
    baselayer.backgroundColor = UIColor.black.cgColor
    layer.addSublayer(baselayer)
    
    // Layer for the Hue/Saturation wheel
    wheelLayer = CALayer()
    wheelLayer.frame = self.bounds
    wheelLayer.contents = createColorWheel(wheelLayer.frame.size)
    baselayer.addSublayer(wheelLayer)
//
//    // Layer for the brightness
    let brightnessLayer = CAShapeLayer()
    brightnessLayer.path = UIBezierPath(ovalIn: CGRect(x: wheelEdgeMargin, y: wheelEdgeMargin, width: self.frame.width - wheelEdgeMargin*2, height: self.frame.height - wheelEdgeMargin*2)).cgPath
//    self.layer.addSublayer(brightnessLayer)
    baselayer.mask = brightnessLayer

    // Layer for the indicator
    indicatorLayer = CAShapeLayer()
    indicatorLayer.strokeColor = indicatorColor
    indicatorLayer.lineWidth = indicatorBorderWidth
    indicatorLayer.fillColor = nil
    indicatorLayer.shadowOpacity = 0.2
    indicatorLayer.shadowRadius = 5
    indicatorLayer.shadowOffset = CGSize(width: 0, height: 2)
    self.layer.addSublayer(indicatorLayer)
    
    setViewColor(color);
  }
  
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    if isInsideWheel(touch.location(in: self)) == false { return false }
    indicatorCircleRadius = 18.0
    touchHandler(touch)
    return true
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

    touchHandler(touch)
    return true
  }
  

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    indicatorCircleRadius = 12.0
    drawIndicator()

  }

  override func cancelTracking(with event: UIEvent?) {
    super.cancelTracking(with: event)
    indicatorCircleRadius = 12.0
    drawIndicator()

  }
  
  
  func touchHandler(_ touch: UITouch) {
    // Set reference to the location of the touch in member point
      point = touch.location(in: self)
    
    let indicator = getIndicatorCoordinate(point)
    point = indicator.point
    var color = (hue: CGFloat(0), saturation: CGFloat(0))
    if !indicator.isCenter  {
      color = hueSaturationAtPoint(CGPoint(x: point.x, y: point.y))
      
      let hsv: HSV = (hue: color.hue, saturation: color.saturation, brightness: brightness, alpha: 1)
      let rgb: RGB = hsv2rgb(hsv)

      self.color = UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
    }else {
      let hsv: HSV = (hue: 0, saturation: 0, brightness: brightness, alpha: 1)
      let rgb: RGB = hsv2rgb(hsv)

      self.color = UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)

    }
    
    
    // Notify delegate of the new Hue and Saturation
    delegate?.hueAndSaturationSelected(color.hue, saturation: color.saturation)
    
    // Draw the indicator
    drawIndicator()
  }
  
  func drawIndicator() {
    // Draw the indicator
    if (point != nil) {
      indicatorLayer.path = UIBezierPath(roundedRect: CGRect(x: point.x-indicatorCircleRadius, y: point.y-indicatorCircleRadius, width: indicatorCircleRadius*2, height: indicatorCircleRadius*2), cornerRadius: indicatorCircleRadius).cgPath
      
      indicatorLayer.fillColor = self.color.cgColor
      indicatorLayer.removeAllAnimations()
    }
  }
  
  func isInsideWheel(_ coord: CGPoint) -> Bool {
    let dimension: CGFloat = min(wheelLayer.frame.width - wheelEdgeMargin * 2, wheelLayer.frame.height - wheelEdgeMargin * 2)
    let radius: CGFloat = dimension/2
    let wheelLayerCenter: CGPoint = CGPoint(x: wheelEdgeMargin + radius, y: wheelEdgeMargin + radius)
    
    let dx: CGFloat = coord.x - wheelLayerCenter.x
    let dy: CGFloat = coord.y - wheelLayerCenter.y
    let distance: CGFloat = sqrt(dx*dx + dy*dy)
    let margin: CGFloat = 20
    return (distance <= radius + margin)
  }
  
  func getIndicatorCoordinate(_ coord: CGPoint) -> (point: CGPoint, isCenter: Bool) {
    // Making sure that the indicator can't get outside the Hue and Saturation wheel
    
    let dimension: CGFloat = min(wheelLayer.frame.width - wheelEdgeMargin * 2, wheelLayer.frame.height - wheelEdgeMargin * 2)
    let radius: CGFloat = dimension/2
    let wheelLayerCenter: CGPoint = CGPoint(x: wheelEdgeMargin + radius, y: wheelEdgeMargin + radius)
    
    let dx: CGFloat = coord.x - wheelLayerCenter.x
    let dy: CGFloat = coord.y - wheelLayerCenter.y
    let distance: CGFloat = sqrt(dx*dx + dy*dy)
    var outputCoord: CGPoint = coord
    
    // If the touch coordinate is outside the radius of the wheel, transform it to the edge of the wheel with polar coordinates
    if (distance > radius) {
      let theta: CGFloat = atan2(dy, dx)
      outputCoord.x = radius * cos(theta) + wheelLayerCenter.x
      outputCoord.y = radius * sin(theta) + wheelLayerCenter.y
    }
    
    // If the touch coordinate is close to center, focus it to the very center at set the color to white
    let whiteThreshold: CGFloat = 3
    var isCenter = false
    if (distance < whiteThreshold) {
      outputCoord.x = wheelLayerCenter.x
      outputCoord.y = wheelLayerCenter.y
      isCenter = true
    }
    return (outputCoord, isCenter)
  }
  
  func createColorWheel(_ size: CGSize) -> CGImage {
    // Creates a bitmap of the Hue Saturation wheel
    let originalWidth: CGFloat = size.width 
    let originalHeight: CGFloat = size.height
    let dimension: CGFloat = min(originalWidth, originalHeight)
    let bufferLength: Int = Int(dimension * dimension * 4)
    
    let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
    CFDataSetLength(bitmapData, CFIndex(bufferLength))
    let bitmap = CFDataGetMutableBytePtr(bitmapData)
    
    for y in stride(from: CGFloat(0), to: dimension, by: CGFloat(1)) {
      for x in stride(from: CGFloat(0), to: dimension, by: CGFloat(1)) {
        var hsv: HSV = (hue: 0, saturation: 0, brightness: 0, alpha: 0)
        var rgb: RGB = (red: 0, green: 0, blue: 0, alpha: 0)
        
        let color = hueSaturationAtPoint(CGPoint(x: x, y: y))
        let hue = color.hue
        let saturation = color.saturation
        if (saturation <= 1.1) {
  
          hsv.hue = hue
          hsv.saturation = min(saturation, 1.0)
          hsv.brightness = 1.0
          hsv.alpha = 1.0
          rgb = hsv2rgb(hsv)
        }
        let offset = Int(4 * (x + y * dimension))
        bitmap?[offset] = UInt8(rgb.red*255)
        bitmap?[offset + 1] = UInt8(rgb.green*255)
        bitmap?[offset + 2] = UInt8(rgb.blue*255)
        bitmap?[offset + 3] = UInt8(rgb.alpha*255)
      }
    }
    
    // Convert the bitmap to a CGImage
    let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
    let dataProvider: CGDataProvider? = CGDataProvider(data: bitmapData)
    let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.last.rawValue)
    let imageRef: CGImage? = CGImage(width: Int(dimension), height: Int(dimension), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(dimension) * 4, space: colorSpace!, bitmapInfo: bitmapInfo, provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
    return imageRef!
  }
  
  func hueSaturationAtPoint(_ position: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
    // Get hue and saturation for a given point (x,y) in the wheel
    
    let c = (wheelLayer.frame.width - wheelEdgeMargin * 2) * scale / 2
    let dx = CGFloat(position.x - wheelEdgeMargin - c) / c
    let dy = CGFloat(position.y - wheelEdgeMargin - c) / c
    let d = sqrt(CGFloat (dx * dx + dy * dy))
    
    let saturation: CGFloat = d
    
    var hue: CGFloat
    if (d == 0) {
      hue = 0;
    } else {
      hue = acos(dx/d) / CGFloat.pi / 2.0
      if (dy > 0) {
       hue = 1.0 - hue
      }
    }
    return (hue, saturation)
  }
  
  func pointAtHueSaturation(_ hue: CGFloat, saturation: CGFloat) -> CGPoint {
    // Get a point (x,y) in the wheel for a given hue and saturation
    
    let dimension: CGFloat = min(wheelLayer.frame.width - wheelEdgeMargin * 2, wheelLayer.frame.height - wheelEdgeMargin * 2)
    let radius: CGFloat = saturation * dimension / 2
    let x = dimension / 2 + radius * cos(hue * CGFloat.pi * 2) + wheelEdgeMargin
    let y = dimension / 2 - radius * sin(hue * CGFloat.pi * 2) + wheelEdgeMargin
    return CGPoint(x: x, y: y)
  }
  
  func setViewColor(_ color: UIColor!) {
    // Update the entire view with a given color
    
    var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
    let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    if (!ok) {
      print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
    }
    self.color = color
    self.brightness = brightness
//    brightnessLayer.fillColor = UIColor(white: 0, alpha: 1.0-self.brightness).cgColor
    wheelLayer.opacity = Float(self.brightness)
    wheelLayer.removeAllAnimations()
    point = pointAtHueSaturation(hue, saturation: saturation)
    drawIndicator()
  }
  
  func setViewBrightness(_ _brightness: CGFloat) {
    // Update the brightness of the view
    
    var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
    let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    if (!ok) {
      print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
    }
    self.brightness = _brightness
//    brightnessLayer.fillColor = UIColor(white: 0, alpha: 1.0-self.brightness).cgColor
//    brightnessLayer.removeAllAnimations()
    wheelLayer.opacity = Float(self.brightness)
    wheelLayer.removeAllAnimations()
    self.color = UIColor(hue: hue, saturation: saturation, brightness: _brightness, alpha: 1.0)
    drawIndicator()
  }
}

