//
//  HexagonLabelView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit


@IBDesignable class HexagonLabelView: UIView {
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    @IBInspectable var text: String = "M" {
        didSet {
            self.label.text = text
        }
    }
    
    @IBInspectable var isSelected: Bool = false {
        didSet {
            if isSelected {
                imageView.tintColor = UIColor.init(hex: "1CD502")
            }
            else {
                imageView.tintColor = UIColor.init(hex: "E2E2E2")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        isSelected = false
        
        self.backgroundColor = UIColor.clear
        
        self.imageView.image = #imageLiteral(resourceName: "hexagon")
        self.imageView.contentMode = .center
        self.addSubview(self.imageView)
        
        self.label.backgroundColor = UIColor.clear
        self.label.textColor = UIColor.white
        self.label.textAlignment = .center
        self.label.text = self.text
        
        self.imageView.addSubview(self.label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        self.imageView.frame = self.bounds
        self.label.frame = self.imageView.bounds
    }
    
}
