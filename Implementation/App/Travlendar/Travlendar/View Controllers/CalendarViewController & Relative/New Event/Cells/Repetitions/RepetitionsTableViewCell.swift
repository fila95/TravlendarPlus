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
    
    @IBOutlet weak var day1: HexagonLabelView!
    @IBOutlet weak var day2: HexagonLabelView!
    @IBOutlet weak var day3: HexagonLabelView!
    @IBOutlet weak var day4: HexagonLabelView!
    @IBOutlet weak var day5: HexagonLabelView!
    @IBOutlet weak var day6: HexagonLabelView!
    @IBOutlet weak var day7: HexagonLabelView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRepetitions(rep: String) {
        let a = Array(rep)
        day1.isSelected = a[0] == "1" ? true : false
        day2.isSelected = a[1] == "1" ? true : false
        day3.isSelected = a[2] == "1" ? true : false
        day4.isSelected = a[3] == "1" ? true : false
        day5.isSelected = a[4] == "1" ? true : false
        day6.isSelected = a[5] == "1" ? true : false
        day7.isSelected = a[6] == "1" ? true : false
    }
    
    func setRepetitions(rep: Int8) {
        day1.isSelected = rep & 0b01000000 == 0b01000000 ? true : false
        day2.isSelected = rep & 0b00100000 == 0b00100000 ? true : false
        day3.isSelected = rep & 0b00010000 == 0b00010000 ? true : false
        day4.isSelected = rep & 0b00001000 == 0b00001000 ? true : false
        day5.isSelected = rep & 0b00000100 == 0b00000100 ? true : false
        day6.isSelected = rep & 0b00000010 == 0b00000010 ? true : false
        day7.isSelected = rep & 0b00000001 == 0b00000001 ? true : false
    }
    
    func setTitle(text: String) {
        titleLabel.text = text
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
