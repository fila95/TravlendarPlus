//
//  HexagonLabelView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit


class HexagonLabelView: UIView {
    
    private let imageView = UIImageView()
    private let label = UILabel()

    
    enum TextType {
        case smaller
        case bigger
    }
    var textType: TextType = .smaller {
        didSet {
            self.updateFont()
        }
    }
    
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
    
    @IBInspectable var isSelectable: Bool = false {
        didSet {
            self.refreshSelectability()
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
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        
        self.label.backgroundColor = UIColor.clear
        self.label.textColor = UIColor.white
        self.label.textAlignment = .center
        self.label.text = self.text
        
        self.imageView.addSubview(self.label)
        
        updateFont()
        refreshSelectability()
    }
    
    private func refreshSelectability() {
        self.gestureRecognizers?.removeAll()
        
        if isSelectable {
            let tgr = UITapGestureRecognizer(target: self, action: #selector(selection))
            self.addGestureRecognizer(tgr)
        }
    }
    
    private func updateFont() {
        switch self.textType {
        case .smaller:
            self.label.font = UIFont.fonts.AvenirNext(type: .Medium, size: 10)
            break
        case .bigger:
            self.label.font = UIFont.fonts.AvenirNext(type: .Medium, size: 15)
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        self.imageView.frame = self.bounds
        self.label.frame = self.imageView.bounds
    }
    
    @objc private func selection() {
        self.isSelected = !self.isSelected
    }
    
    
}
