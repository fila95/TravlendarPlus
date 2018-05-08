//
//  RoundedButton.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import UIKit

enum RoundedButtonStyle {
    case normal
    case muted
}

class RoundedButton: UIButton {
    
    var style: RoundedButtonStyle = .normal {
        didSet {
            applyStyle()
        }
    }
    
    var loading: Bool = false {
        didSet {
            applyLoading()
        }
    }
    
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.7)
            } else {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
    
    private let activityIndicator = UIActivityIndicatorView()
    
    init() {
        super.init(frame: CGRect.zero)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        applyStyle()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
    }
    
    private func applyStyle() {
        switch style {
        case .normal:
            self.titleLabel?.font = UIFont.fonts.AvenirNext(type: .Medium, size: 18)
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor(red:0.99, green:0.28, blue:0.31, alpha:1.00)
            self.activityIndicator.activityIndicatorViewStyle = .white
            break
            
        case .muted:
            self.titleLabel?.font = UIFont.fonts.AvenirNext(type: .Medium, size: 14)
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.clear
            self.activityIndicator.activityIndicatorViewStyle = .gray
            break
        }
    }
    
    private func applyLoading() {
        DispatchQueue.main.async {
            if self.loading {
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                
                self.titleLabel?.alpha = 0.0
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                self.titleLabel?.alpha = 1.0
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.frame = self.bounds
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
