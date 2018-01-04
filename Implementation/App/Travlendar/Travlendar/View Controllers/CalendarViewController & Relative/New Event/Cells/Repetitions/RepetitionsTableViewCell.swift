//
//  RepetitionsTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class RepetitionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRepetitions(rep: Int8) {
        
    }
    
}



extension RepetitionsTableViewCell: Reusable {
    
    static var reuseId: String {
        return "repetitionsTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "RepetitionsTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
