//
//  Font.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

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

