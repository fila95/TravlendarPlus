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
    
    func setRoute(route: Routes) {
        for v in travelContent.subviews {
            v.removeFromSuperview()
        }
        
        var w: CGFloat = 30
        let w1: CGFloat = 39
        let h1: CGFloat = 21
        
        var hash: [TransportMean : Int] = [TransportMean : Int]()
        hash[.biking] = 0
        hash[.car] = 0
        hash[.public_transport] = 0
        hash[.sharing] = 0
        hash[.walking] = 0
        
        for t in route.travels {
            hash[t.transport_mean]! += t.time
        }
        
        
        for t in hash {
            if t.value != 0 {
                let image = UIImageView.init(frame: CGRect.init(x: w, y: (self.frame.size.height - h1)/2, width: w1, height: h1))
                image.image = t.key.image()
                self.travelContent.addSubview(image)
                
                w += w1 + 10
            }
            
        }
        
        
        self.titleLabel.text = "\(route.time / 60) minutes"
    }

}


extension RoutesCollectionViewCell: Reusable {
    static var reuseId: String {
        return "routesCollectionViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "RoutesCollectionViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
