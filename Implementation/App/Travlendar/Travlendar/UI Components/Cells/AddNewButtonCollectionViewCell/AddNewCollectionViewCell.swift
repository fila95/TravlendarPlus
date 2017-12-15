//
//  AddNewButtonCollectionViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import UIKit


class AddNewCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "addNewCollectionViewCell"
    
    @IBOutlet weak var textLabel: UILabel!
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                super.isHighlighted = true
                self.backgroundColor = UIColor(hue:0.99, saturation:0.72, brightness:0.90, alpha:1.00)
            } else if newValue == false {
                super.isHighlighted = false
                self.backgroundColor = UIColor(hue:0.99, saturation:0.72, brightness:0.99, alpha:1.00)
            }
        }
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                super.isSelected = true
                self.backgroundColor = UIColor(hue:0.99, saturation:0.72, brightness:0.90, alpha:1.00)
            } else if newValue == false {
                super.isSelected = false
                self.backgroundColor = UIColor(hue:0.99, saturation:0.72, brightness:0.99, alpha:1.00)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 17
        super.layoutSubviews()
    }
    
    func setText(text: String) {
        self.textLabel.text = text
    }
    
    
}
