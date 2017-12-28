//
//  Delay.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

public func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when) {
        closure()
    }
}

