//
//  Utilities.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation



// Time in seconds
func delay(time: Double, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
        block()
    })
}
