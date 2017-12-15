//
//  Types.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import UIKit


extension CGRect {
    
    var bottomXPosition: CGFloat {
        return self.origin.x + self.width
    }
    
    var bottomYPosition: CGFloat {
        return self.origin.y + self.height
    }
    
    var minSideSize: CGFloat {
        return min(self.width, self.height)
    }
    
    var isWidthLessThanHeight: Bool {
        return self.width < self.height
    }
}



extension Strideable {
    
    public mutating func setIfMore(when value: Self) {
        if self > value {
            self = value
        }
    }
    
    public mutating func setIfFewer(when value: Self) {
        if self < value {
            self = value
        }
    }
}

import UIKit

public extension UIImage {
    
    public func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.width, height: size.height)))
        let resizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    public class func drawFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
