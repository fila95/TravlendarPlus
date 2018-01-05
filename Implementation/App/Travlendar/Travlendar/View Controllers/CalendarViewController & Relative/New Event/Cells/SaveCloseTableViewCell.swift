//
//  SaveCloseTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class SaveCloseTableViewCell: UITableViewCell, Reusable {
    
    var saveHandler: (() -> Void)?
    var closeHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var reuseId: String {
        return "saveCloseTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "SaveCloseTableViewCell", bundle: Bundle.main)
    }
    
    func setSavehandler(handler: @escaping (() -> Void)) {
        self.saveHandler = handler
    }
    
    func setClosehandler(handler: @escaping (() -> Void)) {
        self.closeHandler = handler
    }
    
    @IBAction func closeTap(_ sender: Any) {
        closeHandler?()
    }
    @IBAction func saveTap(_ sender: Any) {
        saveHandler?()
    }
    
}

