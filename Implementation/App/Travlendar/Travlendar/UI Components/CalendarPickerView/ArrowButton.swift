//
//  ArrowButton.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit


class ArrowButton: UIControl {
    
    enum Direction: String {
        case right
        case left
    }
    
    var direction: Direction = .left {
        didSet {
            arrowImage.image = UIImage.init(named: "arrow_" + direction.rawValue)
        }
    }
    private let arrowImage: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        arrowImage.image = UIImage.init(named: "arrow_" + direction.rawValue)
        arrowImage.contentMode = .center
        arrowImage.frame = CGRect.init(x: 5, y: 5, width: self.frame.size.width - 10, height: self.frame.size.height - 10)
        arrowImage.tintColor = UIColor.init(hex: "#BCBCBF")
        self.addSubview(arrowImage)
        
        self.backgroundColor = UIColor.init(hex: "#F7F8FC")
        self.layer.cornerRadius = 7
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrowImage.frame = CGRect.init(x: 5, y: 5, width: self.frame.size.width - 10, height: self.frame.size.height - 10)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor.init(hex: "#F7F8FC").darker(by: 10)
            }
            else {
                self.backgroundColor = UIColor.init(hex: "#F7F8FC")
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.init(hex: "#F7F8FC").darker(by: 10)
            }
            else {
                self.backgroundColor = UIColor.init(hex: "#F7F8FC")
            }
        }
    }
    
}
