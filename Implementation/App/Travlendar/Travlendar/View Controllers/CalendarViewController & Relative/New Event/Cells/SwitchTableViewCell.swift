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
    
    private var switchHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
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
    
    func setSwitchChangedHandler(handler: @escaping (() -> Void)) {
        self.switchHandler = handler
    }
    
    @IBAction func switchDidChange() {
        switchHandler?()
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
