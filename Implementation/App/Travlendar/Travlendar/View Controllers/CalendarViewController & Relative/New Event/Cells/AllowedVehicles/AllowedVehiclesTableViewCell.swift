//
//  AllowedVehiclesTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class AllowedVehiclesTableViewCell: UITableViewCell {

    @IBOutlet weak var walkButton: RoundedButton!
    @IBOutlet weak var bikeButton: RoundedButton!
    @IBOutlet weak var publicTransport: RoundedButton!
    @IBOutlet weak var rideButton: RoundedButton!
    @IBOutlet weak var carButton: RoundedButton!
    
    
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


extension AllowedVehiclesTableViewCell: Reusable {
    
    static var reuseId: String {
        return "allowedVehiclesTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "AllowedVehiclesTableViewCell", bundle: Bundle.main)
    }
    
}
