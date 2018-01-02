//
//  CalendarCreatorView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 02/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter

class CalendarCreatorView: VPComponent {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    var color: UIColor = UIColor.blue {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    private var text: String = "" {
        didSet {
            textField.text = text
        }
    }
    
    open override func desiredheight() -> CGFloat  {
        return 100
    }
    
    convenience init(color: UIColor, name: String? = nil) {
        self.init(frame: CGRect.zero)
        self.color = color
        if name != nil {
            self.text = name!
        }
        commonInit()
    }
    
    override open func commonInit() {
        xibSetup()
        
        colorView.backgroundColor = color
        textField.text = text
        
        self.textField.delegate = self
        self.colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapColor(tap:))))
    }
    
    @objc private func tapColor(tap: UITapGestureRecognizer) {
        self.presenter?.nextPage()
    }
    
}

extension CalendarCreatorView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
