//
//  SwitchTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSwitchOn(on: Bool) {
        switchView.isOn = on
    }
    
    func setTitle(text: String) {
        titleLabel.text = text
    }
    
}

extension SwitchTableViewCell: Reusable {
    
    static var reuseId: String {
        return "switchTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "SwitchTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
