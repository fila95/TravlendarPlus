//
//  Utils.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

extension UIColor {
    
    static var application: UIColor {
        get {
            return UIColor.init(hex: "FF4E4C")
        }
    }
    
}


extension UIColor {
    /**
     Create a ligher color
     */
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /**
     Create a darker color
     */
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    /**
     Try to increase brightness or decrease saturation
     */
    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
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


public extension UIColor {
    
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:   String = hex
        
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

public extension UIFont {
    
    public struct fonts {
        
        public static func AvenirNext(type: BoldType, size: CGFloat) -> UIFont {
            return UIFont.createFont(.AvenirNext, boldType: type, size: size)
        }
    }
    
    public static func system(type: BoldType, size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: self.getBoldTypeBy(boldType: type))
        } else {
            return self.createFont(.AvenirNext, boldType: type, size: size)
        }
    }
    
    public static func createFont(_ fontType: FontType, boldType: BoldType, size: CGFloat) -> UIFont {
        return UIFont.init(
            name: self.getFontNameBy(fontType: fontType) + self.getBoldTypeNameBy(boldType: boldType),
            size: size
            )!
    }
    
    private static func getFontNameBy(fontType: FontType) -> String {
        switch fontType {
        case .AvenirNext:
            return "AvenirNext"
        }
    }
    
    private static func getBoldTypeNameBy(boldType: BoldType) -> String {
        switch boldType {
        case .UltraLight:
            return "-UltraLight"
        case .Light:
            return "-Light"
        case .Medium:
            return "-Medium"
        case .Regular:
            return "-Regular"
        case .Bold:
            return "-Bold"
        case .DemiBold:
            return "-DemiBold"
        default:
            return "-Regular"
        }
    }
    
    
    @available(iOS 8.2, *)
    private static func getBoldTypeBy(boldType: BoldType) -> UIFont.Weight {
        switch boldType {
        case .UltraLight:
            return UIFont.Weight.ultraLight
        case .Light:
            return UIFont.Weight.light
        case .Medium:
            return UIFont.Weight.medium
        case .Regular:
            return UIFont.Weight.regular
        case .Bold:
            return UIFont.Weight.bold
        case .DemiBold:
            return UIFont.Weight.semibold
        default:
            return UIFont.Weight.regular
        }
    }
    
    public enum FontType {
        case AvenirNext
    }
    
    public enum BoldType {
        case Regular
        case Medium
        case Light
        case UltraLight
        case Bold
        case DemiBold
        case None
    }
}


