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
    
    func setAllowedVehicles(rep: String) {
        let a = Array(rep)
        walkButton.isSelected = a[0] == "1" ? true : false
        bikeButton.isSelected = a[1] == "1" ? true : false
        publicTransport.isSelected = a[2] == "1" ? true : false
        rideButton.isSelected = a[3] == "1" ? true : false
        carButton.isSelected = a[4] == "1" ? true : false
    }
    
    func getAllowedVehicles() -> String {
        var s = ""
        s += walkButton.isSelected ? "1" : "0"
        s += bikeButton.isSelected ? "1" : "0"
        s += publicTransport.isSelected ? "1" : "0"
        s += rideButton.isSelected ? "1" : "0"
        s += carButton.isSelected ? "1" : "0"
        return s
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
