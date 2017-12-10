//
//  Badge.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public struct Badge {
    
    static func reset() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    static func set(count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    private init() {}
}

