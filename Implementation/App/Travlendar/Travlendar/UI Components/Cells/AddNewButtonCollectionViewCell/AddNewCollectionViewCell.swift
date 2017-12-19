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
    
    var nrm: UIColor = UIColor.application
    var sel: UIColor = UIColor.application.darker(by: 20)
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                super.isHighlighted = true
                self.backgroundColor = sel
            } else if newValue == false {
                super.isHighlighted = false
                self.backgroundColor = nrm
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
                self.backgroundColor = sel
            } else if newValue == false {
                super.isSelected = false
                self.backgroundColor = nrm
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
