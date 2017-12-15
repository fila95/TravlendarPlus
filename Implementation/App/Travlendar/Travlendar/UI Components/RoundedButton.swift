//
//  RoundedButton.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.7)
            } else {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.titleLabel?.font = UIFont.system(type: UIFont.BoldType.DemiBold, size: 16)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor(red:0.99, green:0.28, blue:0.31, alpha:1.00)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        if let superview = self.superview {
            var width = superview.frame.width - 40
            width.setIfMore(when: 335)
            self.setWidth(width)
        }
    }
}
