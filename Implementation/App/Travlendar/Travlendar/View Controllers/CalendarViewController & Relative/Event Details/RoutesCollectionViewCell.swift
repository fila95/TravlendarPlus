//
//  TravelsCollectionViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 07/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class RoutesCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var travelContent: UIView!
    
    
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                super.isHighlighted = true
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.92, alpha:1.00)
            } else if newValue == false {
                super.isHighlighted = false
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.98, alpha:1.00)
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
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.92, alpha:1.00)
            } else if newValue == false {
                super.isSelected = false
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.98, alpha:1.00)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setRoute(travel: Routes) {
        
    }

}


extension RoutesCollectionViewCell: Reusable {
    static var reuseId: String {
        return "travelsCollectionViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "TravelsCollectionViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
