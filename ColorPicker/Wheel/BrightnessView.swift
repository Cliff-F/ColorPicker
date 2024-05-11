//
//  BrightnessView.swift
//  SwiftHSVColorPicker
//
//  Created by johankasperi on 2015-08-20.
//

import UIKit

class BrightnessView: AlphaSlider {
  
  override var color: SIMD4<Float> {
    set {
      
      background.components1 = [CGFloat(newValue[0]), CGFloat(newValue[1]), CGFloat(newValue[2]), 1]
      background.components2 = [0, 0, 0, 1]

      background.setNeedsDisplay()
    }
    get {
      return background.color
    }
  }
  
  override func setup() {
    super.setup()
    background.drawCheckers = false
  }
}
