//
//  Utils.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 19/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import UIKit


public extension UIColor {
    
    static public var application: UIColor {
        get {
            return UIColor.init(hex: "FF4E4C")
        }
    }
    
}


public extension UIColor {
    /**
     Create a ligher color
     */
    public func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /**
     Create a darker color
     */
    public func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    /**
     Try to increase brightness or decrease saturation
     */
    public func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0,0)
                return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
        return self
    }
}
