//
//  TextViewTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



extension TextViewTableViewCell: Reusable {
    
    static var reuseId: String {
        return "textViewTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "TextViewTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
