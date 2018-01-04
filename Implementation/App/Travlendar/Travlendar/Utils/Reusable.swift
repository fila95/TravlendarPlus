//
//  Reusable.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit


protocol Reusable where Self: UITableViewCell {
    
    static var reuseId: String { get }
    static var nib: UINib? { get }
    
}
