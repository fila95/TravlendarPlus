//
//  CollectionHeaderView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 03/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier: String = "collectionHeaderView"
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
