//
//  SaveCloseTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class SaveCloseTableViewCell: UITableViewCell {

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

extension SaveCloseTableViewCell: Reusable {
    
    static var reuseId: String {
        return "saveCloseTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "SaveCloseTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
