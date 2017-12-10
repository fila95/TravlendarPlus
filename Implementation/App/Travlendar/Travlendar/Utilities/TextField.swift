//
//  TextField.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

extension UITextField {
    
    var isEmptyText: Bool {
        get {
            if self.text == "" {
                return true
            }
            
            if self.text == nil {
                return true
            }
            
            return false
        }
    }
}

