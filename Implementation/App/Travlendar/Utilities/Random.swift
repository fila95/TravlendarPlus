//
//  Random.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public extension Int {
    public static func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    public static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min - 1))) + min
    }
}

public extension Double {
    public static func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    public static func random(min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
}

public extension Float {
    public static func random() -> Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    public static func random(min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
}

public extension CGFloat {
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}

public extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

public extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}

