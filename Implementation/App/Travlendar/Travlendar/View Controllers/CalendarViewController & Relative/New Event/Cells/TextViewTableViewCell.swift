//
//  TextViewTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.textField.tintColor = UIColor.application
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setImage(image: UIImage) {
        fieldImage.image = image
    }
    
    func setText(text: String) {
        self.textField.text = text
    }
    
    func setPlaceholder(text: String) {
        self.textField.placeholder = text
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
