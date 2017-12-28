//
//  Clamp.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

///Returns the input value clamped to the lower and upper limits.
public func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}


public extension CGFloat {
    public func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}

public extension Double {
    public func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Double {
        return Double(CGFloat(self).map(from: from, to: to))
    }
}

public extension Float {
    public func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Float {
        return Float(CGFloat(self).map(from: from, to: to))
    }
}
