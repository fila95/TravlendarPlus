//
//  DPFont.swift
//  DatePicker
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//


import UIKit

public final class DPFont: NSObject {
    
    var fontName: String
    var fontSize: DPFontSize
    
    public init(name: String = "", size: DPFontSize = .medium) {
        
        self.fontName = name
        self.fontSize = size
    }
    
    
    
}

