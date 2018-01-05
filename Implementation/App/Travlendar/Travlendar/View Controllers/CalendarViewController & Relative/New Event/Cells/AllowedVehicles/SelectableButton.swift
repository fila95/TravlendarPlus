//
//  SelectableButton.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class SelectableButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = backgroundCopy
            }
            else {
                self.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if isSelected {
                backgroundCopy = backgroundColor
            }
        }
    }
    
    private var backgroundCopy: UIColor?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundCopy = self.backgroundColor
        
        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        refresh()
    }
    
    private func refresh() {
        
        if isSelected {
            self.backgroundCopy = backgroundColor
        }
        else {
            self.backgroundColor = UIColor.lightGray
        }
        
        
        
    }
    
    @objc func tapped() {
        self.isSelected = !self.isSelected
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
